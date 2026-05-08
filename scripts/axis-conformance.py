#!/usr/bin/env python3
"""AXIS-26 reference conformance runner.

Implements §3.4. Checks invariants M1–M5, S1–S5, F1–F5 against a repository
and emits one of {Minimal, Standard, Full, Non-conforming} plus the failing
invariants. Greenfield repos (no `specs/*/spec.md`) are handled per the §6.6
greenfield bootstrap rule: the first Change MAY omit `delta.md`.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


STATUS_VALUES = {
    "drafting",
    "building",
    "verifying",
    "deploying",
    "live",
    "blocked",
    "archived",
}
END_TO_END_CHANGE_STATUSES = {"verifying", "deploying", "live", "archived"}
END_TO_END_TASK_STATUSES = {"live", "archived"}
G3_THRESHOLD_FLOORS = {"low": 0.95, "moderate": 0.98, "high": 0.995}
HIGH_RISK_CONSTITUTIONAL_CHECKS = ("cwe_top25_clear", "threat_model_signed", "canary_stable")
PRINCIPLES = [
    "Spec is canonical; code is derived.",
    "Verification is the budget; building is cheap.",
    "Risk routes rigor.",
    "Brownfield is default; deltas are first-class.",
    "Tool-portable; vendor-replaceable; model-fungible.",
    "Skills are versioned IP, audited as code.",
    "Security and accessibility are constitutional, not features.",
]


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return ""


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def line_count(path: Path) -> int:
    text = read(path)
    return 0 if not text else len(text.splitlines())


def has_frontmatter_value(text: str, key: str, values: set[str] | None = None) -> bool:
    match = re.search(rf"(?m)^{re.escape(key)}:\s*([A-Za-z0-9_.-]+)\s*$", text)
    if not match:
        return False
    return values is None or match.group(1) in values


def routing_yaml_valid(path: Path) -> tuple[bool, str]:
    """Validate routing.yaml against AXIS-26 Appendix A.1.

    Uses PyYAML when available for true structural validation; falls back to a
    deeper structural regex when PyYAML is not installed. Both paths verify
    nested presence of `risks.{low,moderate,high}` rather than just top-level keys.
    """
    text = read(path)
    if not text:
        return False, "missing"
    try:
        import yaml  # type: ignore

        try:
            data = yaml.safe_load(text)
        except yaml.YAMLError as exc:
            return False, f"invalid YAML: {exc}"
        if not isinstance(data, dict):
            return False, "top-level must be a mapping"
        for key in ("version", "default", "risks"):
            if key not in data:
                return False, f"missing top-level key '{key}'"
        if data["default"] not in ("low", "moderate", "high"):
            return False, f"default must be one of low/moderate/high, got {data['default']!r}"
        risks = data.get("risks") or {}
        if not isinstance(risks, dict):
            return False, "risks must be a mapping"
        for level in ("low", "moderate", "high"):
            if level not in risks:
                return False, f"risks.{level} missing"
            if not isinstance(risks[level], dict):
                return False, f"risks.{level} must be a mapping"
        return True, "ok"
    except ImportError:
        required_top = [
            (r"(?m)^version:\s*\S", "version"),
            (r"(?m)^default:\s*(low|moderate|high)\s*$", "default in low/moderate/high"),
            (r"(?m)^risks:\s*$", "risks block"),
        ]
        for pattern, label in required_top:
            if not re.search(pattern, text):
                return False, f"missing {label}"
        for level in ("low", "moderate", "high"):
            block_re = rf"(?ms)^[ \t]+{level}:[ \t]*\n((?:[ \t]+[^\n]+\n)+)"
            if not re.search(block_re, text):
                return False, f"risks.{level} missing or empty"
        return True, "ok"


def valid_g2_report(path: Path, risk: str | None = None, expected_change_id: str | None = None) -> bool:
    data = load_json(path)
    if not data:
        return False
    if data.get("gate") != "G2" or data.get("decision") not in {"pass", "fail"}:
        return False
    if risk and data.get("risk") != risk:
        return False
    if not data.get("change_id") or not data.get("generated_at"):
        return False
    if expected_change_id and data.get("change_id") != expected_change_id:
        return False
    if not isinstance(data.get("checks"), list) or not isinstance(data.get("blocking_findings"), list):
        return False
    # Operational invariant (documented at §6.2.1): a passing G2 cannot carry
    # blocking findings. Non-blocking informational findings would belong in a
    # different array; A.3 does not specify one, so we treat any entry in
    # `blocking_findings` as gate-blocking by definition.
    if data.get("decision") == "pass" and data.get("blocking_findings"):
        return False
    return True


def json_decision(path: Path) -> str | None:
    data = load_json(path)
    decision = data.get("decision")
    return decision if isinstance(decision, str) else None


def valid_g3_report(path: Path, risk: str | None = None, expected_change_id: str | None = None) -> bool:
    data = load_json(path)
    if not data:
        return False
    if data.get("gate") != "G3" or data.get("decision") not in {"pass", "fail"}:
        return False
    if risk and data.get("risk") != risk:
        return False
    required = ("change_id", "generated_at", "runner", "rerun_count", "behavior_pass_rate", "threshold")
    if any(key not in data for key in required):
        return False
    if expected_change_id and data.get("change_id") != expected_change_id:
        return False
    scan = data.get("constitutional_scan")
    if not isinstance(scan, dict):
        return False
    if "must_violations" not in scan or "should_violations" not in scan:
        return False
    try:
        pass_rate = float(data["behavior_pass_rate"])
        threshold = float(data["threshold"])
        must_violations = int(scan["must_violations"])
    except (TypeError, ValueError):
        return False
    effective_risk = risk or data.get("risk")
    floor = G3_THRESHOLD_FLOORS.get(effective_risk)
    if floor is not None and threshold < floor:
        return False
    if data.get("decision") == "pass" and pass_rate < threshold:
        return False
    if data.get("decision") == "pass" and must_violations != 0:
        return False
    if data.get("decision") == "pass" and effective_risk == "high":
        if not all(scan.get(key) is True for key in HIGH_RISK_CONSTITUTIONAL_CHECKS):
            return False
    return True


def frontmatter_block(text: str) -> str:
    match = re.match(r"^---\n(.*?)\n---", text, re.S)
    return match.group(1) if match else ""


def frontmatter_scalar(frontmatter: str, key: str) -> str | None:
    match = re.search(rf"(?m)^{re.escape(key)}:\s*([^\n#]+?)\s*$", frontmatter)
    return match.group(1).strip().strip('"\'') if match else None


def frontmatter_list(frontmatter: str, key: str) -> list[str]:
    match = re.search(rf"(?ms)^{re.escape(key)}:\s*\n((?:\s+-\s*[^\n]+\n?)*)", frontmatter)
    if not match:
        return []
    return [item.strip().strip('"\'') for item in re.findall(r"(?m)^\s+-\s*(\S.*)$", match.group(1))]


def valid_g1_approve(path: Path, risk: str | None = None, expected_change_id: str | None = None) -> bool:
    frontmatter = frontmatter_block(read(path))
    if not frontmatter:
        return False
    required = ("change_id:", "gate: G1", "decision: approved", "approved_at:", "approvers:")
    if not all(item in frontmatter for item in required):
        return False
    if expected_change_id and frontmatter_scalar(frontmatter, "change_id") != expected_change_id:
        return False
    if risk == "high":
        approvers = frontmatter_list(frontmatter, "approvers")
        if len(set(approvers)) < 2:
            return False
    return True


def valid_low_task_record(path: Path) -> bool:
    text = read(path)
    if not text:
        return False
    frontmatter = frontmatter_block(text)
    if not frontmatter:
        return False
    if frontmatter_scalar(frontmatter, "id") != path.stem:
        return False
    if frontmatter_scalar(frontmatter, "risk") != "low":
        return False
    status = frontmatter_scalar(frontmatter, "status")
    if status not in END_TO_END_TASK_STATUSES:
        return False
    required_sections = (
        "## Intake",
        "## Intent",
        "## Scope",
        "## Tasks",
        "## Acceptance",
        "## G2 Validate Evidence",
    )
    if not all(section in text for section in required_sections):
        return False
    return bool(re.search(r"(?mi)^-\s*Decision:\s*pass\s*$", text))


def has_minimal_change_record(root: Path) -> bool:
    for task in (root / ".axis" / "tasks").glob("*.md"):
        if valid_low_task_record(task):
            return True

    for proposal in (root / ".axis" / "changes").glob("*/proposal.md"):
        change_dir = proposal.parent
        text = read(proposal)
        if not has_frontmatter_value(text, "status", END_TO_END_CHANGE_STATUSES):
            continue
        risk_match = re.search(r"(?m)^risk:\s*(low|moderate|high)\s*$", text)
        risk = risk_match.group(1) if risk_match else None
        g2_path = change_dir / "g2-validate-report.json"
        if valid_g2_report(g2_path, risk, change_dir.name) and json_decision(g2_path) == "pass":
            return True
    return False


def moderate_high_changes(root: Path) -> list[Path]:
    result: list[Path] = []
    for proposal in (root / ".axis" / "changes").glob("*/proposal.md"):
        if has_frontmatter_value(read(proposal), "risk", {"moderate", "high"}):
            result.append(proposal.parent)
    return result


def is_greenfield(root: Path) -> bool:
    """Greenfield repo per §6.6: no capability specs yet exist."""
    return not any(root.glob("specs/*/spec.md"))


def delta_uses_brownfield_markers(path: Path) -> bool:
    """§6.6: a delta.md MUST use exactly the ADDED/MODIFIED/REMOVED markers."""
    text = read(path)
    if not text:
        return False
    return bool(
        re.search(r"(?m)^###\s+ADDED\s+Requirement\b", text)
        or re.search(r"(?m)^###\s+MODIFIED\s+Requirement\b", text)
        or re.search(r"(?m)^###\s+REMOVED\s+Requirement\b", text)
    )


def requirements_are_ears(root: Path) -> bool:
    paths = list(root.glob("specs/*/spec.md")) + [
        path / "delta.md" for path in moderate_high_changes(root) if (path / "delta.md").exists()
    ]
    if not paths:
        return False
    ears = re.compile(r"(?m)^\s*(-\s*)?(The|WHEN|WHILE|IF|WHERE)\b.+\bSHALL\b.+")
    return all(ears.search(read(path)) for path in paths)


def eval_thresholds_enforced(root: Path) -> bool:
    text = read(root / ".axis" / "evals" / "config.yaml")
    if not text:
        return False
    floors = {"low": "0.95", "moderate": "0.98", "high": "0.995"}
    return all(
        re.search(rf"(?s)^\s+{risk}:\s*.*?behavior_pass_rate:\s*{re.escape(value)}", text, re.M)
        for risk, value in floors.items()
    )


def any_markdown_contains(root: Path, markers: tuple[str, ...]) -> bool:
    for path in root.rglob("*.md"):
        text = read(path)
        if any(marker in text for marker in markers):
            return True
    return False


def drift_detection_operational(root: Path) -> bool:
    """F2: drift detection operational on at least one capability.

    Two acceptance signals:
      (a) `.axis/drift/` directory contains at least one drift report; OR
      (b) the reference `drift-detector` skill exists AND at least one capability
          spec exists (so there is something to monitor).
    Filename heuristics alone are rejected — they let "drift_test.md" pass.
    """
    drift_dir = root / ".axis" / "drift"
    if drift_dir.is_dir() and any(p for p in drift_dir.rglob("*") if p.is_file()):
        return True
    has_skill = (root / "skills" / "drift-detector" / "SKILL.md").exists()
    has_capability = any(root.glob("specs/*/spec.md"))
    return has_skill and has_capability


def shared_skills_library(root: Path) -> bool:
    """F5: shared skills library distinct from M4.

    M4 only requires one skill to exist. F5 (Constitution principle 6: skills are
    versioned IP) requires at least 2 skills with `version:` frontmatter. This
    distinguishes a one-off skill from a maintained library.
    """
    versioned = 0
    for skill in root.glob("skills/*/SKILL.md"):
        text = read(skill)
        match = re.match(r"^---\s*\n(.*?)\n---", text, re.S)
        if match and re.search(r"(?m)^version:\s*\S+", match.group(1)):
            versioned += 1
            if versioned >= 2:
                return True
    return False


def find_failures(root: Path) -> list[str]:
    failures: list[str] = []

    constitution = read(root / "constitution.md")
    if not constitution or not all(principle in constitution for principle in PRINCIPLES):
        failures.append("M1: constitution.md must declare all seven AXIS-26 principles.")
    if not all(header in constitution for header in ("## MUST", "## SHOULD", "## MAY")):
        failures.append("M1: constitution.md must classify constraints as MUST, SHOULD, and MAY.")

    agents = root / "AGENTS.md"
    if not agents.exists() or line_count(agents) > 300:
        failures.append("M2: AGENTS.md must exist at repo root and be <=300 lines.")

    routing_ok, routing_reason = routing_yaml_valid(root / ".axis" / "routing.yaml")
    if not routing_ok:
        failures.append(
            f"M3: .axis/routing.yaml must validate against the AXIS-26 Appendix A.1 schema ({routing_reason})."
        )

    if not any(root.glob("skills/*/SKILL.md")):
        failures.append("M4: at least one /skills/<name>/SKILL.md must exist.")

    if not has_minimal_change_record(root):
        failures.append("M5: at least one Change Record or low-risk Task Record must preserve lifecycle and G2 Validate evidence.")

    greenfield = is_greenfield(root)
    s1_required = ["proposal.md", "design.md", "tasks.md", "g1-approve.md", "g2-validate-report.json"]
    if not greenfield:
        # Brownfield: delta.md is required by S1 + §6.6 protocol.
        s1_required.insert(1, "delta.md")

    for change_dir in moderate_high_changes(root):
        proposal_text = read(change_dir / "proposal.md")
        risk_match = re.search(r"(?m)^risk:\s*(moderate|high)\s*$", proposal_text)
        risk = risk_match.group(1) if risk_match else None
        missing = [name for name in s1_required if not (change_dir / name).exists()]
        if (
            missing
            or not any((change_dir / "evals").glob("*"))
            or not valid_g1_approve(change_dir / "g1-approve.md", risk, change_dir.name)
            or not valid_g2_report(change_dir / "g2-validate-report.json", risk, change_dir.name)
        ):
            note = " (greenfield: delta.md not required)" if greenfield else ""
            failures.append(
                f"S1: {change_dir.relative_to(root)} must contain valid proposal, "
                f"{'design' if greenfield else 'delta+design'}, Task Plan, G1 Approve evidence, "
                f"G2 Validate report, and evals{note}."
            )
            break

    if not requirements_are_ears(root):
        if greenfield:
            # In a true greenfield with no specs and no deltas, S2 is vacuously
            # satisfied — there is nothing to grade. Skip the failure.
            pass
        else:
            failures.append("S2: delta.md and /specs/*/spec.md requirements must use EARS form.")

    # S3: brownfield delta protocol enforced.
    # Greenfield is allowed by §6.6; S3 is vacuously true until the first
    # capability spec lands. Once a spec exists, every change's delta.md
    # MUST use the ADDED/MODIFIED/REMOVED markers.
    if not greenfield:
        for change_dir in moderate_high_changes(root):
            delta_path = change_dir / "delta.md"
            if delta_path.exists() and not delta_uses_brownfield_markers(delta_path):
                failures.append(
                    f"S3: {change_dir.relative_to(root)}/delta.md must use the ADDED/MODIFIED/REMOVED Requirement markers per §6.6."
                )
                break

    if not eval_thresholds_enforced(root):
        failures.append("S4: .axis/evals/config.yaml must enforce AXIS-26 §8.2 threshold floors.")

    for change_dir in moderate_high_changes(root):
        proposal_text = read(change_dir / "proposal.md")
        risk_match = re.search(r"(?m)^risk:\s*(moderate|high)\s*$", proposal_text)
        risk = risk_match.group(1) if risk_match else None
        if not valid_g3_report(change_dir / "evals" / "g3-evaluate-report.json", risk, change_dir.name):
            failures.append(f"S4: {change_dir.relative_to(root)}/evals/g3-evaluate-report.json must be valid G3 Evaluate evidence.")
            break

    if not any_markdown_contains(root, ("DX Core 4", "MTTV", "Mean Time to Verification")):
        failures.append("S5: DX Core 4 metrics and MTTV tracking must be visible.")

    for filename in (
        "PRODUCT.md",
        "DESIGN.md",
        "BACKEND.md",
        "INFRA.md",
        "THREAT-MODEL.md",
        "DOMAIN.md",
        "RUNBOOK.md",
    ):
        if not (root / filename).exists():
            failures.append(f"F1: {filename} must exist.")
            break

    if not drift_detection_operational(root):
        failures.append(
            "F2: drift detection must be operational — populate `.axis/drift/` "
            "or install the drift-detector skill alongside at least one capability spec."
        )

    if not any_markdown_contains(root, ("ai_authored",)):
        failures.append("F3: AI-attributed change failure tracking must be present.")

    if not any_markdown_contains(root, ("Constitution Review",)):
        failures.append("F4: quarterly Constitution Review evidence or ADR must be present.")

    if not shared_skills_library(root):
        failures.append(
            "F5: shared skills library must contain at least two versioned "
            "skills (SKILL.md frontmatter `version:`); see Constitution principle 6."
        )

    return failures


def tier_from_failures(failures: list[str]) -> str:
    failed = {failure.split(":", 1)[0] for failure in failures}
    if any(code.startswith("M") for code in failed):
        return "Non-conforming"
    if any(code.startswith("S") for code in failed):
        return "Minimal"
    if any(code.startswith("F") for code in failed):
        return "Standard"
    return "Full"


def main() -> int:
    parser = argparse.ArgumentParser(description="Run AXIS-26 conformance checks.")
    parser.add_argument("repo", nargs="?", default=".", help="repository path to check")
    parser.add_argument("--json", action="store_true", help="emit JSON")
    args = parser.parse_args()

    root = Path(args.repo).resolve()
    failures = find_failures(root)
    tier = tier_from_failures(failures)

    if args.json:
        print(json.dumps({"tier": tier, "failures": failures}, indent=2))
    else:
        print(tier)
        if failures:
            print("Failing invariants:")
            for failure in failures:
                print(f"- {failure}")
    return 0 if tier != "Non-conforming" else 1


if __name__ == "__main__":
    sys.exit(main())
