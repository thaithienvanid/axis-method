# Changelog

All notable changes to **AXIS-26** (the specification) and **`axis-core`** (the reference plugin) are recorded here.

The specification follows semantic versioning per AXIS-26 §9.1. During the `0.x` line, compatibility is best-effort and breaking changes may still occur. The `axis-core` plugin tracks the specification line it implements; `axis-core` `0.x` conforms to AXIS-26 `0.x`.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

- No changes yet.

## [0.0.1] — 2026-05-08

### Specification

- **AXIS-26 v0.0.1** released. CC BY 4.0. Initial public release of the specification.
  - 11 normative sections + Appendix A (normative schemas) + Appendices B–F (informative).
  - Three conformance tiers: Minimal, Standard, Full.
  - Five-phase lifecycle (Specify → Build → Verify → Deploy → Observe) with three gates (G1 Approve, G2 Validate, G3 Evaluate).
  - Three risk levels (low / moderate / high) with deterministic routing via `.axis/routing.yaml`.
  - Brownfield delta protocol with EARS-formatted requirements.
  - Repository-canonical control plane under `.axis/`; SaaS gateways are sync-only.
  - Canonical G1 Approve/G2 Validate/G3 Evaluate, deployment, and emergency record paths; schemas cover `g1-approve.md`, `g2-validate-report.json`, `evals/g3-evaluate-report.json`, `deployment-record.md`, and `emergency-record.md`.
  - Reference conformance runner at `scripts/axis-conformance.py`.

### Plugin (`axis` 0.0.1)

- Plugin name: `axis` (reference implementation directory: `axis-core/`). Slash commands resolve as `/axis:<verb>` per AXIS-26 §2.3–§2.4.
- 7 slash commands: `/axis:route`, `/axis:specify`, `/axis:build`, `/axis:verify`, `/axis:deploy`, `/axis:onboard`, `/axis:amend`.
- 7 skills: `axis-lifecycle`, `ears-coach`, `cwe-scanner`, `risk-router`, `multi-spec-conflict`, `eval-author`, `drift-detector`.
- 3 subagents: `specifier`, `verifier`, `drift-watcher`.
- 4 lifecycle hooks: `SessionStart`, `PreToolUse(CWE)`, `PostToolUse(routing)`, `Stop(G3 Evaluate gate)`.
- Templates for `constitution.md`, `AGENTS.md`, `routing.yaml`, `proposal.md`, `delta.md`, `low-risk-task.md`, `task-plan.md`, G1/G2/G3 reports, deployment and emergency records, `evals/config.yaml`, optional `mcp.example.json`.
- Codex plugin manifest at `axis-core/.codex-plugin/plugin.json`; Claude Code remains the hook/slash-command implementation, while Codex consumes the workflow through skills plus Git pre-commit.
- Public marketplace install: `/plugin marketplace add thaithienvanid/axis-method` then `/plugin install axis@axis-method`.
- Free by default. No paid third-party service is required or auto-loaded. Optional integrations (Linear, Braintrust, Snyk) are documented as opt-in templates.

### Multi-tool adapters

- `adapters/cursor/` — `.cursor/rules/axis-26.mdc` rule + slash-command notes.
- `adapters/codex/` — Codex CLI auto-loads `AGENTS.md`; one-shot prompt invocations documented.
- `adapters/gemini/commands/*.toml` — seven Gemini CLI custom commands (`/specify`, `/build`, `/verify`, `/deploy`, `/route`, `/onboard`, `/amend`).
- `adapters/aider/` — `.aider.conf.yml` with auto-lint wired to the CWE scanner; CONVENTIONS.md mapping.
- `scripts/init.sh` — tool-agnostic bootstrap. Flags: `--cursor`, `--gemini`, `--aider`, `--git-hooks`, `--force`.
- `docs/PORTABILITY.md` — full per-tool support matrix and gates-via-Git-pre-commit fallback.

### Governance and disclosure

- `README.md` — overview, install-by-tool matrix, repository layout, Quick Start (with normative §1.2 cross-reference), license summary, project status, disclaimer.
- `CONTRIBUTING.md` rewritten with the full §9.3 framework: Bug / Question / Proposal-seed Issue templates, AP lifecycle (`draft → discussion → final → accepted | rejected | withdrawn`), AP template, two-implementation rule, decision matrix, IP terms, and current governance roster (BDFL, maintainer team, Technical Committee transition criteria).
- `CODE_OF_CONDUCT.md` — Contributor Covenant 2.1 per §9.3.
- `SECURITY.md` — GitHub-reserved vulnerability disclosure policy; cross-references AXIS-26 §10 for the spec's normative security positions and §2.4 for the SECURITY.md vs THREAT-MODEL.md split.
- `.github/ISSUE_TEMPLATE/` — Bug, Question, Proposal-seed YAML forms + `config.yml` redirecting security to private advisory.
- `.github/REPO-METADATA.md` — repository description, topics, and homepage canonical metadata applicable via UI, CLI, or REST.
- `ap/` directory established (empty at `0.0.1`; first APs filed once external implementers arrive).
- `DISCLAIMER.md` — explicit "AS IS" disclaimer, opinionated-synthesis caveat, no regulatory pre-certification, vendor-name non-endorsement, hook-script audit reminder, AI-authored-content disclosure. Referenced from spec §1.3.

### Audit and verification

- Bibliography keys [`DX-AI`] and [`FAROS-2026`] cited consistently in §1.1 and §F.2 (replacing earlier broken `[DX-LONGITUDINAL]` / `[FAROS-WHIPLASH]` placeholders).
- Conformance runner: routing.yaml validated against Appendix A.1 with PyYAML when available (regex fallback retains the same depth); S3 enforces ADDED/MODIFIED/REMOVED markers in `delta.md`; F2 requires `.axis/drift/` content or the drift-detector skill alongside a capability spec; F5 requires ≥2 versioned skills (Constitution principle 6); S1 honors the §6.6 greenfield exception (delta.md not required until the first capability spec lands).
