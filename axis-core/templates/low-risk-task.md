---
# Drop at .axis/tasks/<id>.md as a low-risk Task Record (AXIS-26 §3.1 M5, §7.1).
# Replace placeholders before committing — A.2 regex requires real digits.
id: 2026-05-001-example-low-task          # ^[0-9]{4}-[0-9]{2}-[0-9]{3}-[a-z0-9-]+$
risk: low
status: drafting
owner: pod-name
constitution: v0.0.1
created: 2026-05-08
updated: 2026-05-08
priority: medium
ai_authored: false
---

# [Short title]

## Intake

Source: [Feature request | Bug | Tech debt | Internal tooling | Experimentation | Migration | Security | Compliance | Production incident | Strategic]
Originator: [role / person / linked ticket]

## Intent

[1–2 sentences: what changes, who benefits.]

## Scope

In:
- [bullet]

Out:
- [bullet]

Touched paths:
- [glob]

## Tasks

<!-- Task Plan: executable checklist. Requirements remain canonical in Acceptance. -->

- [ ] [step]
- [ ] [step]

## Acceptance

[Inline acceptance check sufficient at risk low. G2 Validate is the only mandatory gate (§6.3); G1 Approve/G3 Evaluate not required. Auto-merge permitted if `routing.yaml.risks.low.auto_merge: true`.]

## G2 Validate Evidence

- Decision: [pass | fail]
- Checks: [lint/typecheck/security scan command or reason not applicable]
- Blocking findings: [none | list findings]
