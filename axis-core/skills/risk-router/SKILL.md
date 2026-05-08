---
name: risk-router
description: Resolve the risk level for a change deterministically from .axis/routing.yaml using AXIS-26 §6.4 precedence. Activate at /axis:specify entry and whenever a risk decision is in question.
version: 0.0.1
---

# Risk Router

Risk classifies *rigor* (blast radius, security, scope), not priority. The same code change always receives the same rigor regardless of who requested it (§6.4).

## Precedence (highest first)

1. Explicit `risk:` override in the primary record frontmatter.
2. Markers on touched files or capabilities (`pii: true`, `regulated: true`, …).
3. Path glob matches under `risks.high.glob`, then `risks.moderate.glob`, then `risks.low.glob`.
4. The `default` from `.axis/routing.yaml`.

When multiple rules match, **highest wins**.

## Process

1. Load and validate `.axis/routing.yaml` against Appendix A.1.
2. Collect touched files: `git diff --name-only <base>...HEAD`. If pre-Build, fall back to the `## Scope` section in the primary record (`proposal.md` for Change Records, `.axis/tasks/<id>.md` for Task Records).
3. Read primary record frontmatter for an explicit `risk:` and any markers.
4. For each path: walk `risks.high.glob` first, then `risks.moderate.glob`, then `risks.low.glob`.
5. Combine with precedence rules; take the highest.
6. **Lock at Specify entry**. Do NOT re-route an in-flight change unless an explicit upward override is recorded.

## Override discipline

- Upward override: any pod member.
- Downward override: only Pod Lead or ARE; reversible; documented in the primary record.
- Mid-flight upgrade requires an explicit upward override entry.

## Anti-patterns

- Routing by stakeholder priority. Routing is properties of code, not work-item urgency.
- Silently downgrading risk to skip G3 Evaluate.
- Letting a `routing.yaml` edit re-classify in-flight changes.

## Output

```json
{
  "change_id": "<id>",
  "resolved_risk": "low | moderate | high",
  "rule_fired": "<override | marker:<name> | glob:<pattern> | default>",
  "locked_at": "<ISO timestamp>"
}
```
