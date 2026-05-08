# Security Policy

This file is the GitHub-reserved vulnerability disclosure policy. The engineering security architecture document for projects adopting AXIS-26 is `THREAT-MODEL.md` (AXIS-26 §2.4) — those are different documents. Don't conflate them.

For the specification's normative security requirements (skill injection, secret/PII exposure, vendor and harness dependence, regulatory binding, apprentice-rung erosion), see [AXIS-26 §10 — Security Considerations](./AXIS-26.md#10-security-considerations).

## Reporting a vulnerability

**Do not file public GitHub issues for security findings.**

Report privately via [GitHub Private Vulnerability Reporting](https://github.com/thaithienvanid/axis-method/security/advisories/new). Include:

1. Affected component: specification, plugin, or specific file/path.
2. Reproduction steps or proof-of-concept.
3. Impact assessment (confidentiality / integrity / availability).
4. Suggested remediation if known.

We aim to respond within 5 business days.

## Scope

In scope:

- The `axis-core` plugin: hooks, commands, skills, agents, templates.
- Any code in `.claude-plugin/` that executes on plugin install.
- Codex plugin metadata in `.codex-plugin/`.
- Examples in `axis-core/templates/` if they execute on use.

Out of scope:

- Vulnerabilities in third-party MCP servers (Linear, Braintrust, Snyk) — report to the respective vendors. The plugin does not auto-load these (see `axis-core/README.md`).
- Specification ambiguity — file an issue or AP per [`CONTRIBUTING.md`](./CONTRIBUTING.md).
- Vulnerabilities in user-authored downstream content (their `constitution.md`, evals, hooks).

## Plugin-specific risk surface

Per AXIS-26 §10:

- **Skill injection.** Skills are executable instructions in natural language. Liu et al. (2026) found 26.1% of surveyed skills contained at least one exploitable vulnerability. We treat skills as code: signed commits, peer review, version pinning, periodic adversarial audit.
- **Hook command execution.** All four hooks under `axis-core/hooks/` execute as shell commands in the user's environment. They run as the user, with the user's permissions. Review them before installing — they are short and auditable. Hooks never call out to the network and never read or write outside the project tree.
- **Template injection.** Templates under `axis-core/templates/` are copied into user repositories. They are static Markdown / YAML / JSON; no executable content.
- **MCP servers.** None auto-loaded. Opt-in via `axis-core/templates/mcp.example.json`. Each opt-in vendor has its own threat model.

## Disclosure timeline

- **Day 0** — vulnerability reported via private advisory.
- **Day 5** — acknowledgement and triage decision.
- **Day 30** — fix in branch (or revised timeline communicated).
- **Day 90** — public disclosure with credit, unless extended by mutual agreement or active exploitation requires faster disclosure.
