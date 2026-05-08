# AGENTS.md

Tool-portable agent context. Loaded by Claude Code, Cursor, Codex CLI, Gemini CLI. Length cap: 300 lines (AXIS-26 §3.1 M2).

## Project Overview

[1–2 sentences: what the project does and its primary users.]

## Stack / Build / Test

- Languages: [list]
- Framework: [list]
- Install: `[command]`
- Dev: `[command]`
- Test: `[command]`
- Lint: `[command]`
- Type-check: `[command]`

## Constitution

Governed by `./constitution.md` v0.0.1. The version pinned in each Task Record or Change Record frontmatter (`constitution:`) is the version that change was authored against (Appendix A.2). All MUST principles are non-negotiable and block G2 Validate.

## Risk Routing

Risk is determined deterministically by `.axis/routing.yaml` per AXIS-26 §6.4. Use `/axis:route` to classify.

## Skills Available

The AXIS bootstrap installs reusable skills under `/skills/`:

- `ears-coach` — EARS requirement authoring and review.
- `axis-lifecycle` — AXIS command workflow coordinator.
- `cwe-scanner` — CWE Top 25 deterministic checks at G2 Validate.
- `risk-router` — Deterministic risk classification.
- `multi-spec-conflict` — G1 Approve cross-reference scan.
- `eval-author` — Functional/Security/Performance/Accessibility/Drift evals.
- `drift-detector` — Continuous drift detection in Observe.

Project-specific skills also go under `/skills/<name>/SKILL.md`.

## Commands

- `/axis:route` — Classify risk for a Change.
- `/axis:specify` — Phase 1; author a low-risk Task Record or moderate/high Change Record.
- `/axis:build` — Phase 2; implement code, tests, migrations.
- `/axis:verify` — G3 Evaluate; run evals + constitutional scan.
- `/axis:deploy` — Phase 4; walk environment list.
- `/axis:onboard` — Generate initial capability spec.
- `/axis:amend` — Constitution amendment with ADR.

## Don't

- Don't bypass G2 Validate with `--no-verify` or commit hooks turned off.
- Don't edit `delta.md` requirements during Build — go back to Specify (§6.1).
- Don't single-person two-key approve at risk high (§6.2).
- Don't make the optional Linear/Jira gateway authoritative for status — repository is canonical (§7.3).
- Don't suppress CWE scanner findings without a linked Security ADR.
