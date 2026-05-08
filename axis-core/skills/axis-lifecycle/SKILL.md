---
name: axis-lifecycle
description: Use when running AXIS-26 lifecycle work in Codex or any skill-aware agent, including requests equivalent to /axis:specify, /axis:build, /axis:verify, /axis:deploy, /axis:onboard, /axis:amend, or /axis:route.
version: 0.0.1
---

# AXIS Lifecycle

This skill adapts the AXIS-26 command workflow to Codex and other skill-aware agents. Codex does not need slash commands to execute AXIS; treat `/axis:*` text from the user as intent, load the matching command body, and carry out the workflow with normal agent tools.

## Command Mapping

Use project-local command bodies under `.axis/commands/` when present. If the project has not been bootstrapped with command copies, use these plugin command bodies as the source of truth:

| User intent | Command body |
|---|---|
| `/axis:route` or risk classification | `../../commands/route.md` |
| `/axis:specify` or "specify this change" | `../../commands/specify.md` |
| `/axis:build` or "build this change" | `../../commands/build.md` |
| `/axis:verify`, "run G3", or "run G3 Evaluate" | `../../commands/verify.md` |
| `/axis:deploy` or deployment promotion | `../../commands/deploy.md` |
| `/axis:onboard` or initial capability spec | `../../commands/onboard.md` |
| `/axis:amend` or Constitution amendment | `../../commands/amend.md` |

## Codex Execution Rules

1. Read `constitution.md`, `AGENTS.md`, `.axis/routing.yaml`, and the relevant command body before changing files.
2. Preserve AXIS precedence: Constitution > AGENTS.md > skills > inline reasoning.
3. For moderate or high risk work, apply the supporting skills when relevant:
   - `risk-router` for deterministic risk classification.
   - `ears-coach` for requirements.
   - `multi-spec-conflict` for G1 Approve cross-reference checks.
   - `eval-author` for eval suites and thresholds.
   - `cwe-scanner` for G2 Validate and G3 Evaluate security review.
   - `drift-detector` for Observe-phase checks.
4. Codex has no automatic lifecycle hook surface in this plugin. Use `scripts/init.sh <repo> --git-hooks` for deterministic G2 Validate checks outside Claude Code.
5. Do not mark a moderate/high change `building` until G1 Approve evidence is recorded. Do not mark a moderate/high change `live` until G3 Evaluate evidence is present. Low-risk Task Records may advance to `live` after inline acceptance and G2 Validate evidence are complete.

## Outputs

Keep outputs repository-canonical:

- Low-risk Task Record: `.axis/tasks/<id>.md`, including a Task Plan and inline G2 Validate evidence.
- Moderate/high Change Record: `.axis/changes/<id>/proposal.md`, `delta.md`, `design.md`, `tasks.md` Task Plan, `g1-approve.md`, `g2-validate-report.json`, and `evals/g3-evaluate-report.json`.
- Deployment promotion: also record `.axis/changes/<id>/deployment-record.md`.
- Emergency changes: also record `.axis/changes/<id>/emergency-record.md`.
- Capability specs: `/specs/<cap>/spec.md`.
- Constitution amendments: ADR plus updated `constitution.md` version.
