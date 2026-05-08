# Disclaimer

This document supplements (does **not** override) the [LICENSE](./LICENSE). For the legally binding terms, the LICENSE prevails.

## No warranty

The AXIS-26 specification (`AXIS-26.md`, CC BY 4.0) and the reference plugin / adapters / scripts in this repository (Apache 2.0) are provided **"AS IS"**, without warranty of any kind, express or implied — including but not limited to warranties of merchantability, fitness for a particular purpose, non-infringement, or correctness. **Use at your own risk.**

## The specification is opinionated synthesis, not received truth

AXIS-26 is the result of synthesizing patterns from many sources (listed in §11.2 and the Acknowledgments). It is one coherent integration; it is not the only correct integration. The conformance tiers (Minimal, Standard, Full) signal *adoption* of this particular synthesis, not *quality* or *correctness* of your engineering. Conformance to AXIS-26 does not guarantee that your software is good, safe, secure, or fit for purpose.

## Citations are point-in-time

The studies, papers, vendor benchmarks, and regulatory references cited in §1.1, §10, §11, and the appendices were accurate as of the v0.0.1 release date (2026-05-08). They may be revised, retracted, or superseded. Implementers are responsible for verifying current sources before relying on the underlying claims (productivity numbers, security incident rates, regulatory effective dates, employment statistics, etc.).

## No regulatory pre-certification

AXIS-26 mentions specific regulatory frameworks (EU AI Act, GDPR, HIPAA, SOC 2, PCI-DSS) by name to scope where the high-risk gating applies. **AXIS-26 does not provide regulatory pre-certification, audit readiness, or legal compliance assurance.** Conforming to AXIS-26 does not satisfy any regulator's requirements on its own. Jurisdiction-specific mapping is the implementer's responsibility — see §F.2 FAQ "What about regulated industries?".

## Vendor names are examples, not endorsements

The specification and the reference plugin mention vendor and product names — Anthropic, Claude Code, OpenAI, Codex CLI, Cursor, Aider, Google Gemini, Linear, Jira, GitHub Projects, Braintrust, Promptfoo, Snyk, Semgrep, Helicone, Langfuse, Backstage, Port, Booking.com, METR, DX, Faros AI, ThoughtWorks, Endor Labs, Stanford, Deloitte, IT Revolution Press, Anthropic Skills/Hooks/Plugins, AGENTS.md spec authors, RFC editors, MITRE, W3C — among others. **None of these organizations endorse AXIS-26 or this repository.** All trademarks and service marks remain the property of their respective owners. Mentions are descriptive (to enable interoperability or to cite prior art); they are not endorsements in either direction.

## The reference plugin executes shell scripts in your environment

Installing `axis-core` enables four shell hooks that run on Claude Code lifecycle events (`SessionStart`, `PreToolUse`, `PostToolUse`, `Stop`). They are short, POSIX-portable, and audited — but they are still arbitrary shell scripts that execute as your user with your permissions. **Review `axis-core/hooks/*.sh` before installing.** The same applies to any adapter you install and any MCP server you opt into.

## No automatic data exfiltration

By design, the plugin does not phone home, collect telemetry, or send any data to the maintainers or any third party. Optional MCP integrations (Linear, Braintrust, Snyk) are **opt-in** and send data only to the vendor you configure. See `axis-core/templates/mcp.example.json`.

## The Constitution template is a starting point

`axis-core/templates/constitution.md` lists 12 CWE Top 25 entries and a small WCAG matrix as a *starter subset*. Production use **must** extend the table to cover all CWE Top 25 entries reachable in your threat model, plus any regulatory mappings (GDPR, HIPAA, etc.) — and document any exclusions in a Security ADR per §4.2. The reference template is not a substitute for a security review.

## AI-authored content

Portions of this repository — including drafts of the reference plugin, adapters, and supporting documentation — were authored or co-authored with AI assistance. The maintainers have reviewed all content for correctness; nevertheless, AI-authored content can contain subtle errors. Bug reports and corrections via the Issue templates in `.github/ISSUE_TEMPLATE/` are welcomed.

## Contact

Questions about this disclaimer: file a GitHub Issue using the **Question** template. Concerns that require private discussion: see `SECURITY.md` for the disclosure channel.
