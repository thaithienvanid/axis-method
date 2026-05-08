---
# Replace MM / NNN / DD with real digits before committing.
# Appendix A.2 regex: id ^[0-9]{4}-[0-9]{2}-[0-9]{3}-[a-z0-9-]+$ ; created/updated format: date.
id: 2026-05-001-short-slug
risk: moderate              # set by routing.yaml; locked at Specify entry (§6.4)
status: drafting
owner: pod-name
priority: medium
ai_authored: false
constitution: v0.0.1
created: 2026-05-08
updated: 2026-05-08
---

# Proposal: [short title]

## Intake

Source: [Feature request | Bug | Tech debt | Internal tooling | Experimentation | Migration | Security | Compliance | Production incident | Strategic]
Originator: [role / person / linked ticket]
Linked: [ticket IDs, incident IDs]

## Intent

[1–3 sentences describing what the user or system gains from this change.]

## Risk Decision

[Why this risk level was assigned. Cite the rule that fired in routing.yaml (override / marker / glob / default). If overridden, document direction and approver.]

## Scope

In:
- [bullet]

Out:
- [bullet]

Touched paths:
- [glob]

## Skills

Pinned at Specify entry per AXIS-26 §6.6:

- ears-coach @ 0.0.1
- cwe-scanner @ 0.0.1
- risk-router @ 0.0.1
- multi-spec-conflict @ 0.0.1
- eval-author @ 0.0.1

## Acceptance for G1

- [ ] Cross-reference scan clean (multi-spec-conflict).
- [ ] Eval skeleton present under `evals/`.
- [ ] Risk decision recorded.
- [ ] Two-key approvers named (if risk: high).
