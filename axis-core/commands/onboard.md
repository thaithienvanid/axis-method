---
description: One-time onboarding. Generate an initial /specs/<cap>/spec.md from existing code, ADRs, and tests (AXIS-26 §6.6).
argument-hint: "<capability-name>"
allowed-tools: Read Write Bash(git:*) Bash(find:*) Bash(grep:*) Skill(ears-coach)
---

# /axis:onboard — Initial Capability Spec Generation

Generate `/specs/$ARGUMENTS/spec.md` by scanning code, ADRs, and tests for the capability `$ARGUMENTS`. The output MUST be marked `status: draft` until reviewed and pod-signed (§6.6).

## Process

1. Identify the capability's source paths (ask the user if ambiguous — paths matter for routing).
2. Scan source for public API surfaces, test files for behavior assertions, and ADRs (`/docs/adr/**` or `/adr/**`) for prior decisions.
3. Draft an EARS-formatted capability spec via the `ears-coach` skill, covering Ubiquitous, Event-Driven, State-Driven, Unwanted-Behavior, Optional sections.
4. Cross-reference against existing capability specs to avoid duplicate requirement IDs.
5. Write `/specs/$ARGUMENTS/spec.md`. Capability specs use the inline header style from Appendix B.3 (Appendix A.2 frontmatter is for Task Records and Change Record proposals, not capability specs):

```markdown
# Capability: <Capability Name>
Status: draft | Owner: <pod> | Constitution: v<version> | Risk: <inferred>

## Ubiquitous
...
## Event-Driven
...
## State-Driven
...
## Unwanted-Behavior
...
## Optional
...

## Acceptance Evals
- evals/<slug>.yaml

## Non-Goals
- <bullet>
```

`Status: draft` MUST remain until the spec is pod-signed (§6.6 capability spec lifecycle).

6. Stop. Do **not** mark the spec `active`; that requires a Change through Specify per §6.6 capability spec lifecycle.

## Refuses to

- Run twice on the same capability without explicit confirmation (onboarding is one-time per capability).
- Create capability specs outside `/specs/<cap>/` layout.
- Backfill MUST principles into the Constitution; that requires `/axis:amend`.
