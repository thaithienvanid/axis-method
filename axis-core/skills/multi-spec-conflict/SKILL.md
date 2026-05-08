---
name: multi-spec-conflict
description: Cross-reference scan across all open changes and capability specs at G1 Approve to detect conflicting requirements, contradictory EARS clauses, and shared code-path collisions (AXIS-26 §6.6).
version: 0.0.1
---

# Multi-Spec Conflict

At G1 Approve, before a change is approved, run a cross-reference scan across `.axis/changes/*` and `/specs/*`. The scan MUST flag (§6.6):

1. Two open changes modifying the same requirement ID.
2. EARS clauses that contradict an existing requirement.
3. Capabilities downstream that reference the modified requirement.
4. Two open changes touching the same code paths (`risks.high.glob`, `risks.moderate.glob`, or `risks.low.glob` matches), regardless of spec-level overlap.

Conflicts MUST be resolved before G1 Approve by sequencing, merging, or rejection.

## Process

1. Enumerate open changes: any `.axis/changes/*/proposal.md` whose `status` is in `{drafting, building, verifying, deploying}`.
2. For the candidate change:
   - Parse `delta.md` for ADDED / MODIFIED `<ID>` / REMOVED `<ID>` markers.
   - For each MODIFIED `<ID>`, search all open changes for the same ID — collision (1).
   - Parse all SHALL clauses; pairwise compare against `/specs/*/spec.md` clauses — contradiction (2).
   - For each MODIFIED `<ID>`, grep `/specs/` for downstream references — produce a downstream-impact list (3).
3. Compute touched code paths from `## Scope` and `tasks.md`. For every other open change, intersect path sets — overlap (4).
4. Emit a structured report:

```json
{
  "change_id": "<id>",
  "conflicts": [
    {"type": "id_collision", "id": "<REQ-ID>", "with": "<other-change-id>"},
    {"type": "ears_contradiction", "spec": "<path>", "requirement": "<text>"},
    {"type": "downstream_reference", "spec": "<path>", "requirement_id": "<REQ-ID>"},
    {"type": "path_overlap", "paths": ["<glob>"], "with": "<other-change-id>"}
  ],
  "decision": "ok | block-G1"
}
```

5. If conflicts are present, refuse G1 Approve advance until each conflict has either:
   - a sequencing decision (one change waits for the other; record a `depends_on:`),
   - a merge (one change subsumes the other),
   - or an explicit rejection ADR.

## Anti-patterns

- "We'll resolve in code review." G1 Approve is the resolution point.
- Auto-merging deltas that share an ID — that is a spec defect, not a Git conflict.
