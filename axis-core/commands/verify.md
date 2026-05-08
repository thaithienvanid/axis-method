---
description: Run G3 Evaluate — behavior evals plus deterministic constitutional scan — against a moderate/high Change Record eval suite (AXIS-26 §6.2, §8.1, §8.2).
argument-hint: "<change-id>"
allowed-tools: Read Write Edit Bash Skill(eval-author) Skill(cwe-scanner)
---

# /axis:verify — G3 Evaluate

Run the Change Record's eval suite and the constitutional scan. Outcome is pass / fail against the threshold for the change's risk level. Low-risk Task Records do not require this command; they use inline acceptance and G2 Validate evidence unless a project opts into additional evals.

## Thresholds (§8.2 — floors; implementations MAY raise, MUST NOT lower)

| Risk | Behavior pass rate | Latency p95 | Constitutional |
|------|---|---|---|
| low (optional G3 only) | ≥95% | — | 0 MUST violations |
| moderate | ≥98% | within 10% of baseline | 0 MUST; SHOULD requires ADR |
| high | ≥99.5% | within 5% of baseline | 0 violations; full CWE Top 25 clear; threat model signed; canary stable |

(All four high-risk constitutional conditions are required — omitting any one is a §8.2 floor violation.)

## Re-run policy (§8.3)

LLM-judge evals are non-deterministic. A G3 Evaluate run = N executions:

- N ≥ 3 RECOMMENDED at risk high.
- N = 1 acceptable only for optional low-risk evals.
- At risk moderate, use the project's configured re-run count; do not silently relax it.
- Decision uses **median** pass rate across runs.

## Process

1. Resolve the Change Record risk from frontmatter; reject if status is not `building` or `verifying`.
2. Discover eval files under `.axis/changes/$ARGUMENTS/evals/` grouped by category: Functional, Security, Performance, Accessibility, Drift (§8.3).
3. Execute the suite N times per the re-run policy. Use the configured runner (Braintrust, Promptfoo, or local) — read `.axis/evals/config.yaml` for runner configuration.
4. Run the deterministic constitutional scan (CWE rules from `constitution.md`).
5. At risk high: confirm the threat model is signed (Security ADR present and current).
6. Emit a G3 Evaluate report under `.axis/changes/<id>/evals/g3-evaluate-report.json` using Appendix A.4 and `.axis/templates/g3-evaluate-report.json` when present; otherwise use `axis-core/templates/g3-evaluate-report.json`. Include pass rate per run, median, latency, constitutional scan, threshold, and decision.
7. **Decision**:
   - Pass → set `status: deploying`; the Deploy phase walks the environment list (§6.7).
   - Fail (eval) → set `status: verifying`; surface the failing tests; recommend either Build fix or Specify revision (§6.1 backwards transition allowed).
   - Fail (constitutional MUST) → block; require fix. Never advance.

## Anti-patterns

- Eval theater: thresholds set so nothing fails (§D.5). Counter: κ-validate LLM-judge rubrics quarterly; run eval-of-evals (§8.3).
- Single-run G3 Evaluate at moderate or high.
- Hand-waving "constitutional scan passed" without producing the report.
