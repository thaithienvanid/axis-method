---
description: Enter the Specify phase. Author a low-risk Task Record or moderate/high Change Record (AXIS-26 §6.1, §6.6).
argument-hint: "<short-slug-describing-the-change>"
allowed-tools: Read Write Edit Bash(git:*) Bash(date:*) Bash(mkdir:*) Skill(ears-coach) Skill(risk-router) Skill(multi-spec-conflict) Skill(eval-author)
---

# /axis:specify — Phase 1 (Specify)

Begin a new Change for `$ARGUMENTS`. Output: a delta spec, design, and eval suite whose depth scales with risk (§6.3).

## Process

1. **Mint a change ID** in the form `YYYY-MM-NNN-<slug>` (§2.4). Use the next free `NNN` for the current year-month across `.axis/changes/` and `.axis/tasks/`.
2. **Run `/axis:route`** to determine `risk` from `.axis/routing.yaml` (§6.4). Risk is locked at Specify entry.
3. **Create the artifact, layout depends on risk** (§6.10, §7.1, §3.1 M5). AXIS uses one Task Plan concept in two layouts:
   - **risk: low** → Task Record: single file `.axis/tasks/<id>.md` with frontmatter (Appendix A.2) plus sections `## Intake`, `## Intent`, `## Scope`, `## Tasks`, `## Acceptance`, and `## G2 Validate Evidence`. No `proposal.md`, no `delta.md`, no `evals/` directory required; inline acceptance and G2 Validate evidence are sufficient. Use `.axis/templates/low-risk-task.md` when present; otherwise use `axis-core/templates/low-risk-task.md`.
   - **risk: moderate or high** → directory `.axis/changes/<id>/` with:
     - `proposal.md` (frontmatter per Appendix A.2; sections `## Intake`, `## Intent`, `## Risk Decision`, `## Scope`, `## Skills`).
     - `delta.md` — only ADDED / MODIFIED `<ID>` / REMOVED `<ID>` markers (§6.6). Use EARS templates (Ubiquitous, Event-Driven, State-Driven, Unwanted-Behavior, Optional). Delegate phrasing to the `ears-coach` skill.
     - `design.md` — implementation strategy; trade-offs; affected capability specs.
     - `tasks.md` — Task Plan that Build will execute. Use `.axis/templates/task-plan.md` when present; otherwise use `axis-core/templates/task-plan.md`.
     - `g1-approve.md` — G1 Approve evidence (required before Build; two distinct approvers at risk high).
     - `evals/` — Functional, Security, Performance, Accessibility, Drift evals (§8.3) appropriate to risk.
4. **Greenfield bootstrap** (§6.6): if no `/specs/<cap>/spec.md` exists for the impacted capability, the change MAY define it directly in `proposal.md` and `design.md`; `delta.md` is only required once the first capability spec exists.
5. **For risk moderate/high only, run cross-reference scan** (§6.6) via the `multi-spec-conflict` skill across all open `.axis/changes/*` and `/specs/*`. Block at G1 Approve if:
   - two open changes modify the same requirement ID,
   - EARS clauses contradict an existing requirement,
   - downstream capabilities reference the modified requirement,
   - two open changes touch the same code paths.
6. **Pin skill versions** under `## Skills` (§6.6 skill version pinning). For low risk, record any relevant skill versions in the Task Record if the task depends on a non-default skill.
7. **For low risk, stop after writing the Task Record**. Report that `/axis:build` may execute it after confirming inline acceptance criteria and G2 Validate evidence requirements.
8. **For risk moderate/high, pause for G1 Approve**. Emit a clear summary of which approvals are needed:
   - moderate: pod review.
   - high: two-key approval, distinct individuals (§6.2). Default key pair table:
     - security/PII/auth → Pod Lead + Security or Privacy Officer
     - regulated → Pod Lead + Legal or Compliance counsel
     - infra/migrations → Pod Lead + Platform Engineer or ARE
     - payments → Pod Lead + Finance Officer or PCI-DSS reviewer
9. After human G1 Approve evidence is recorded in `g1-approve.md`, set `status: building` in frontmatter and stop. Build is `/axis:build`.

## Anti-patterns to refuse

- Authoring requirements outside EARS at risk moderate or high (§S2).
- Rewriting `/specs/<cap>/spec.md` outside the brownfield delta protocol (§S3).
- Moving a moderate/high change to `building` without a G1 Approve record.
- Single-person two-key approval at risk high.
