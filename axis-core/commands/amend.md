---
description: Propose a Constitution amendment with a mandatory ADR (AXIS-26 §4.3).
argument-hint: "<short-amendment-slug>"
allowed-tools: Read Write Edit Bash(git:*) Bash(date:*)
---

# /axis:amend — Constitution Amendment

The Constitution follows semantic versioning (§4.3). Every amendment requires an ADR documenting motivation, alternatives, decision, consequences, and migration plan.

## Bump rules (§4.3)

- **MAJOR** — change to a MUST principle.
- **MINOR** — added SHOULD principle, expanded CWE/WCAG mapping.
- **PATCH** — editorial fix.

## Process

1. Read `constitution.md`. Identify the current version.
2. Determine the bump level from the proposed change. If it touches a MUST principle, this is MAJOR — confirm explicitly with the user.
3. Create `/docs/adr/ADR-NNNN-$ARGUMENTS.md` with sections: Status, Context, Decision, Consequences, Alternatives Considered, Migration Plan.
4. Update `constitution.md`:
   - Bump the version line.
   - Apply the textual change.
   - Record the change under an `## Amendment Log` section with date and ADR link.
5. Reference the ADR from any affected `/specs/<cap>/spec.md` and `.axis/changes/*` that depend on the changing principle.
6. Surface in the next Constitution Review (quarterly minimum at Standard+, §D.8).

## MAJOR-bump guardrails

- BDFL-with-consensus governance during 0.x; Technical Committee after the governance transition criteria are met (§9.2).
- Two-implementation rule (§9.3) does not apply to a single project's Constitution but is recommended when the constitution is shared across repos.
- All open Changes whose `constitution:` frontmatter pins a pre-amendment version MUST be re-evaluated; no auto-rebase.
