---
description: Enter the Build phase. Implement the change against the approved spec, with G2 Validate CWE checks firing on edits and project deterministic checks handled by CI/task scripts (AXIS-26 §6.1, §6.2).
argument-hint: "<change-id>"
allowed-tools: Read Write Edit MultiEdit Bash(git:*) Bash(npm:*) Bash(pnpm:*) Bash(yarn:*) Bash(pytest:*) Bash(cargo:*) Bash(go:*) Bash(make:*) Bash(semgrep:*) Skill(cwe-scanner)
---

# /axis:build — Phase 2 (Build)

Implement `$ARGUMENTS` from either risk-routed layout:

- Low risk Task Record: `.axis/tasks/$ARGUMENTS.md`.
- Moderate/high Change Record: `.axis/changes/$ARGUMENTS/`.

Pre-conditions:

- Low risk: frontmatter has `risk: low`; no G1 Approve is required.
- Moderate/high: status is `building` (G1 Approve has passed).
- All declared `depends_on:` entries have reached `verifying` or later (§6.9).

## Process

1. **Resolve the layout**. If `.axis/tasks/$ARGUMENTS.md` exists, treat it as a low-risk Task Record. Otherwise require `.axis/changes/$ARGUMENTS/`.
2. **Refuse to start** if the risk/status pre-conditions fail or if a `depends_on:` is not yet at `verifying`.
3. **Walk the Task Plan**, marking each item in progress one at a time. For low risk, the Task Plan is the `## Tasks` section. For moderate/high, it is `tasks.md`.
4. **Edit code, tests, migrations, IaC** to satisfy the canonical requirement source: `## Acceptance` for low risk, `delta.md` for moderate/high. Every requirement must trace to at least one test or acceptance check.
5. **G2 Validate checks fire automatically on each edit** via the `pre-tool-use-cwe.sh` hook. Type checks, AST anti-patterns, and project lints run through the project's CI or task scripts. Do not bypass; investigate failures.
6. **Constitution precedence** (§4.2): Constitution > AGENTS.md > skills > inline reasoning. If a MUST is at risk, stop and surface — do not "fix" by lowering rigor.
7. **Skill upgrades during Build** must be reflected by re-pinning under `proposal.md` `## Skills` (§6.6) for moderate/high changes.
8. **Apprentice protection** (§10): if this is a high-risk Change and an L1/L2 is the originator, ensure mentor pairing is recorded.
9. Emit G2 Validate evidence:
   - Low risk: update the `## G2 Validate Evidence` section in `.axis/tasks/$ARGUMENTS.md`.
   - Moderate/high: emit `.axis/changes/$ARGUMENTS/g2-validate-report.json` using Appendix A.3 and `.axis/templates/g2-validate-report.json` when present; otherwise use `axis-core/templates/g2-validate-report.json`.
10. When the Task Plan is complete and deterministic checks are clean:
   - Low risk: set `status: live` or `archived` after inline acceptance is satisfied.
   - Moderate/high: set `status: verifying` and call `/axis:verify`.

## What this phase does NOT do

- It does not run behavior evals for moderate/high changes — that is G3 Evaluate, owned by `/axis:verify`.
- It does not promote moderate/high changes to environments — that is `/axis:deploy`.
- It does not modify `delta.md` requirements without re-entering Specify (§6.1 backwards transition).
- It does not convert a low-risk Task Record to a moderate/high Change Record silently; risk upgrades must re-enter Specify.
