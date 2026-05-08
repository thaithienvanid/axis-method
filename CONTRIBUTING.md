# Contributing to AXIS-26

Thank you for your interest in contributing to AXIS-26. This document covers the operational details of contribution. The normative governance framework lives in §9.3 of the specification itself.

## Quick start

| If you want to... | Do this |
|---|---|
| Report a bug or contradiction in the spec | Open a [GitHub Issue](#filing-issues) using the **Bug** template |
| Ask a question | Open a GitHub Issue using the **Question** template |
| Fix a typo or clarify wording | Open a Pull Request directly |
| Propose a substantive change | File an [AP — AXIS Proposal](#axis-proposals-ap) |
| Adopt AXIS-26 in your organization | Skim §1.2 (Quick Start) and §3 (Conformance) of the spec |
| Implement an AXIS-26 conforming tool | Read `axis-26/reference` and §3.4 (Conformance Test) |

## Before you contribute

1. Read the specification end-to-end at least once. Most questions are answered there.
2. Search existing Issues and APs to avoid duplication.
3. For substantive proposals, read §9 of the spec to understand the versioning and governance model.

## Filing Issues

Issue templates are provided in `.github/ISSUE_TEMPLATE/`. Choose the template that matches your contribution:

- **Bug** — defect in the specification text (contradiction, ambiguity, broken cross-reference, schema error)
- **Question** — clarification request; "I think the spec says X but I'm not sure"
- **Proposal seed** — early-stage idea before filing a full AP

Issues are triaged within 7 days by the maintainer team. Bugs are typically resolved by Pull Request. Questions are answered inline and may seed a clarification PR. Proposal seeds are escalated to AP if substantive.

## Pull Requests

For editorial changes (typos, formatting, clarification of unambiguous wording), file a PR directly without an Issue. PR conventions:

- Branch name: `editorial/<short-description>` or `fix/<issue-number>`
- Commit messages: imperative mood, ≤72 character subject, optional body explaining *why*
- One logical change per PR; large changes should be broken into a series
- PR description references the related Issue (`Closes #N`) or AP (`Implements AP-NNNN`)

PRs touching normative clauses (any MUST, SHALL, SHOULD, MAY) require a corresponding AP unless the change is purely editorial (clarifying wording without changing meaning).

## AXIS Proposals (AP)

An AP is a numbered Markdown document proposing a substantive change to the specification. APs live in `/ap/` of the specification's repository.

### When to file an AP

| Change type | Needs AP? |
|---|---|
| Typo, formatting, broken link | No — direct PR |
| Clarifying wording without changing meaning | No — direct PR |
| Adding a worked example or FAQ entry | No — direct PR |
| Changing the meaning of an existing MUST/SHALL/SHOULD/MAY clause | **Yes** |
| Adding a new normative clause | **Yes** + reference implementation |
| Adding a new schema field | **Yes** |
| Removing or deprecating a normative clause | **Yes** + migration path |
| Bumping the spec MAJOR version | **Yes** + 30-day comment period |

### AP lifecycle

```
draft  →  discussion  →  final  →  accepted    (merged into spec at next MINOR or MAJOR)
                              \→  rejected     (closed with rationale)
                              \→  withdrawn    (author withdraws)
```

- **draft**: AP is being written. Title prefix `[DRAFT]` in the filename until ready.
- **discussion**: AP is filed and open for community comment. Minimum 14 days for substantive APs; minimum 30 days for new normative features or MAJOR bumps.
- **final**: Comment period closed. AP is in maintainer review for accept/reject decision.
- **accepted**: AP is merged. Spec changes propagate at the next MINOR (for additive) or MAJOR (for breaking) release.
- **rejected**: Maintainer team has decided not to incorporate. Rationale is recorded in the AP itself.
- **withdrawn**: Author withdraws before decision.

### AP template

```markdown
# AP-NNNN: [Short descriptive title]

- **Status:** draft | discussion | final | accepted | rejected | withdrawn
- **Author(s):** [Name(s)]
- **Created:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD
- **Targets:** [spec section(s) affected, e.g., §6.2, A.1]
- **Replaces:** [AP number(s) if applicable]
- **Replaced by:** [AP number(s) if applicable]

## Motivation
What problem is this proposal solving? Why does the current spec fall short?

## Proposal
Describe the change. Include exact wording for normative clauses where applicable.

## Alternatives considered
What other approaches were evaluated? Why were they rejected?

## Consequences
What does this change for implementers? For the conformance test? For the schema?

## Migration path
How do existing implementations migrate? Is this a breaking change? At what version does it land?

## Implementation
Reference implementation status. For new normative features, two interoperable implementations are required before advancing from `proposed` to `standard`.

## Open questions
Unresolved questions for the comment period to address.
```

### AP numbering

APs are numbered sequentially in submission order, zero-padded to four digits: `AP-0001`, `AP-0002`, ... Numbers are assigned by the maintainer team upon initial filing. Numbers are never reused even for rejected or withdrawn APs.

## Implementation requirement (two-implementation rule)

A new normative feature in AXIS-26 advances through three statuses:

1. **proposed** — accepted via AP, in the spec at the next MINOR/MAJOR release, but flagged as `proposed`.
2. **standard** — promoted to standard status after **two independent, interoperable implementations** have demonstrated the feature in production.
3. **deprecated** — replaced by a successor; documented migration path.

The reference implementation in `axis-26/reference` is the editorial baseline and does not count toward the two. The two implementations must come from at least two unrelated organizations and must demonstrate interoperability — for example, both correctly enforce the new constitutional rule, or both correctly route via the new schema field.

## Decision-making

| Decision type | Decision-maker | Quorum / consensus |
|---|---|---|
| Editorial PR merge | Any maintainer | None — single approval suffices |
| Bug-fix PR merge | Any maintainer | None — single approval suffices |
| Substantive AP accept/reject | Maintainer team | Consensus (no objection from any maintainer) |
| Breaking AP accept/reject | BDFL during 0.x; Technical Committee after governance transition | BDFL decision; later, ⅔ majority of TC |
| Maintainer team additions/removals | BDFL during 0.x | BDFL decision |

Disagreements that cannot resolve by consensus escalate to the BDFL during 0.x. The Technical Committee assumes this role after the governance transition criteria are met, with a documented transition checklist published as an AP.

## Governance current state

- **BDFL:** Van Hoang ([@thaithienvanid](https://github.com/thaithienvanid)) for the duration of the AXIS-26 `0.x` line, per §9.2.
- **Maintainer team:** v0.0.1 ships with the BDFL as the sole maintainer. Additional maintainers are invited as adoption grows; nominations open via the Question Issue template once a contributor has merged at least one substantive PR. Roster changes are recorded in commit history on this file.
- **Technical Committee:** Not yet seated. Per §9.2, stewardship transitions to a Technical Committee upon adoption at Standard or Full by **three unrelated organizations**. A formal transition checklist will be filed as an AP at that point. Until then, contested decisions fall to the BDFL.
- **Governance review cadence:** This section is reviewed at the quarterly Constitution Review (§F4) and at every MINOR-or-greater spec release.

## Communication channels

- **GitHub Issues:** primary channel for bugs, questions, proposal seeds
- **GitHub Discussions:** for community discussion not tied to a specific Issue or AP
- **Mailing list:** [TBD upon publication]
- **Office hours / monthly call:** [TBD upon publication]

## Code of Conduct

All participation in the AXIS-26 community is governed by the [Contributor Covenant 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/) or its successor.

Reports of Code of Conduct violations may be filed via GitHub or by emailing the maintainer team. Violations are addressed by the maintainer team; the BDFL reviews escalations and final decisions.

## Intellectual property

By contributing to AXIS-26, you agree that:

- Specification text contributions are licensed under [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/).
- Reference implementation and code-sample contributions are licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0).
- You retain copyright in your contributions.
- You grant the AXIS-26 project a perpetual, worldwide, royalty-free license to incorporate your contribution under the licenses above.
- Where you are aware of patents or other proprietary rights related to your contribution, you SHOULD disclose them in the AP or PR description.

## Recognition

Contributors are credited in the spec's `Acknowledgments` section and in the per-AP author field. Significant contributors may be invited to join the maintainer team.

## Questions about this document

If anything in this document is unclear, file an Issue using the **Question** template. Improvements to `CONTRIBUTING.md` itself follow the editorial PR path described above.
