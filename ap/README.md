# AXIS Proposals (AP)

This directory holds **AXIS Proposals** — numbered Markdown documents that propose substantive changes to the AXIS-26 specification.

Per AXIS-26 §9.3 and `CONTRIBUTING.md`, an AP is required for any change that:

- modifies the meaning of an existing MUST / SHALL / SHOULD / MAY clause
- adds a new normative clause (also requires a reference implementation)
- adds, modifies, or removes an Appendix A schema field
- removes or deprecates a normative clause (also requires a migration path)
- bumps the spec MAJOR version

Editorial changes (typos, clarifications, formatting) bypass the AP process and go straight to PR.

## Filing an AP

1. Open a **Proposal seed** Issue using `.github/ISSUE_TEMPLATE/proposal-seed.yml` to gather early feedback. (Skip this step only if your proposal is uncontroversial and well-formed.)
2. Once the maintainer team assigns you an AP number, create `ap/AP-NNNN-<short-name>.md` using the template in `CONTRIBUTING.md`.
3. Open the PR with the AP file. PR description: `Files AP-NNNN: <title>`.
4. Status starts at `draft`. The maintainer team moves it through `discussion → final → accepted | rejected | withdrawn`.

## Comment periods

- Substantive APs: ≥ 14 days in `discussion`.
- New normative features and MAJOR bumps: ≥ 30 days in `discussion`.

## Numbering

APs are numbered sequentially in submission order, zero-padded to four digits (`AP-0001`, `AP-0002`, …). Numbers are never reused, even for rejected or withdrawn proposals.

## No APs filed yet

This directory is empty at v0.0.1 release. The first APs will be filed once the spec gathers external implementers.
