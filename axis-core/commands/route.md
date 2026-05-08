---
description: Classify a change's risk level deterministically from .axis/routing.yaml (AXIS-26 §6.4).
argument-hint: "<change-id-or-path>"
allowed-tools: Read Bash(grep:*) Bash(cat:*) Bash(yq:*) Bash(find:*)
---

# /axis:route — Risk Routing

Determine the risk level for the change identified by `$ARGUMENTS`.

Apply the precedence in AXIS-26 §6.4 (highest first):

1. Explicit `risk:` override in primary record frontmatter.
2. Markers on touched files or capabilities (`pii: true`, `regulated: true`, …).
3. Path glob matches under `risks.high.glob`, then `risks.moderate.glob`, then `risks.low.glob`.
4. The `default` risk level in `.axis/routing.yaml`.

When multiple risks match, **highest wins** (§6.4).

## Steps

1. Read `.axis/routing.yaml` (validate against schema in Appendix A.1).
2. Locate the change: `.axis/changes/$ARGUMENTS/proposal.md` or `.axis/tasks/$ARGUMENTS.md`.
3. Read primary record frontmatter for an explicit `risk:` override and any markers (`pii`, `regulated`).
4. Resolve the touched code paths from `git diff --name-only` against the change's base branch (or the `## Scope` section if no diff yet).
5. Match paths against `risks.high.glob`, then `risks.moderate.glob`, then `risks.low.glob`.
6. Apply precedence; emit the resolved risk and the rule that fired.
7. If the resolved risk differs from the frontmatter and the override is downward, refuse the downgrade until the rule and approver are recorded in the primary record (`proposal.md` for Change Records, `.axis/tasks/<id>.md` for Task Records) per §6.4.

Risk classification is locked at Specify entry. Do **not** re-route an in-flight Change unless explicitly instructed (§6.4).

## Output

```
risk: <low|moderate|high>
matched_rule: <glob | marker | override | default>
locked_at: <Specify entry timestamp>
```
