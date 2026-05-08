# Delta

This file expresses the change as ADDED / MODIFIED / REMOVED requirements against existing capability specs (AXIS-26 §6.6). Use exactly these section markers.

Capability: [/specs/<cap>/spec.md]

---

### ADDED Requirement REQ-NNN

[Use one EARS template:
- The <system> SHALL <action>.
- WHEN <trigger>, the <system> SHALL <action>.
- WHILE <state>, the <system> SHALL <action>.
- IF <trigger>, THEN the <system> SHALL <action>.
- WHERE <feature flag>, the <system> SHALL <action>.]

Acceptance eval: `evals/functional/<slug>.yaml`

---

### MODIFIED Requirement REQ-NNN

[Cite the existing requirement ID. Quote the prior text, then state the new text in EARS.]

Prior:
> The system SHALL <old action>.

New:
> The system SHALL <new action>.

Acceptance eval: `evals/functional/<slug>.yaml`

---

### REMOVED Requirement REQ-NNN

Reason: [why]
Deprecation ADR: [/docs/adr/ADR-NNNN-...md]

---
