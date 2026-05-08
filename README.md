# axis-method

> **AXIS-26 v0.0.1** is a risk-gated, spec-driven control plane for AI coding agents. It gives agents a shared lifecycle, repository-canonical specs, security checks, eval gates, and portable commands that work across Claude Code, Codex, Cursor, Gemini CLI, Aider, and any tool that reads `AGENTS.md`.

AXIS-26 is for teams that want agent speed without losing control of requirements, risk, verification, deployment evidence, and drift.

- **Specification:** [AXIS-26.md](./AXIS-26.md) — CC BY 4.0
- **Reference plugin:** [axis-core/](./axis-core) — Claude Code + Codex manifests, Apache 2.0
- **Adapters:** [adapters/](./adapters) — Cursor, Codex, Gemini CLI, Aider
- **Bootstrap:** [scripts/init.sh](./scripts/init.sh) — installs the portable control plane into any repo
- **Portability:** [docs/PORTABILITY.md](./docs/PORTABILITY.md)

## Why AXIS-26

AI agents can implement faster than most teams can keep specs, tests, reviews, and release evidence aligned. AXIS-26 makes that work explicit:

- The spec is canonical; code follows it.
- Risk determines rigor, not opinion or urgency.
- Requirements use EARS so agents and reviewers can test them.
- Build work is gated by deterministic checks.
- Behavior is verified through evals before deploy.
- Deployment and emergency changes leave auditable records.
- The control plane is plain Markdown, YAML, JSON, shell, and Python.

AXIS is not a replacement for Spec Kit, BMAD, OpenSpec, or your SDLC. It is the governance layer that makes those styles safer for agentic delivery.

## How It Works

Every change moves through one lifecycle:

| Phase | Main artifact | Gate |
|---|---|---|
| **Specify** | `.axis/tasks/<id>.md` for low risk, or `.axis/changes/<id>/proposal.md`, `delta.md`, `design.md`, `tasks.md` for moderate/high | **G1 Approve** for moderate/high; two-key at high risk |
| **Build** | Code, tests, migrations, IaC | **G2 Validate** — deterministic checks, CWE/security review |
| **Verify** | `.axis/changes/<id>/evals/g3-evaluate-report.json` | **G3 Evaluate** — behavior evals + constitutional scan for moderate/high |
| **Deploy** | `deployment-record.md`, optional `emergency-record.md` | Environment promotion with G3 re-run for moderate/high |
| **Observe** | Drift evidence, follow-up changes | Runtime/spec drift detection |

Low-risk work can collapse into a single `.axis/tasks/<id>.md` Task Record with inline G2 evidence. Moderate and high-risk work use a full `.axis/changes/<id>/` Change Record with a `tasks.md` Task Plan.

## Quick Start

Clone this repo, then bootstrap AXIS into the project you want agents to work on:

```bash
git clone https://github.com/thaithienvanid/axis-method.git
cd <your-project>
/path/to/axis-method/scripts/init.sh .
```

This installs `constitution.md`, `AGENTS.md`, `.axis/commands/`, `.axis/templates/`, `.axis/routing.yaml`, `.axis/evals/config.yaml`, and reusable `skills/`.

Then customize:

1. Edit `constitution.md` for your project's MUST / SHOULD / MAY rules.
2. Edit `.axis/routing.yaml` so file globs route to `low`, `moderate`, or `high`.
3. Run a first change through Specify -> Build -> Verify -> Deploy -> Observe.

## Install by Tool

| Tool | Command | What you get |
|---|---|---|
| **Claude Code** | `/plugin marketplace add thaithienvanid/axis-method`<br>`/plugin install axis@axis-method` | Slash commands (`/axis:specify`, etc.), skills, subagents, lifecycle hooks |
| **Codex** | Discover `axis` from [.agents/plugins/marketplace.json](./.agents/plugins/marketplace.json) (Codex CLI loads the manifest automatically), then `scripts/init.sh <repo> --git-hooks` to install Git pre-commit G2 checks | Codex skills, `AGENTS.md` fallback, Git pre-commit G2 checks |
| **Cursor** | `scripts/init.sh <repo> --cursor --git-hooks` | Project rules, project slash commands, Git pre-commit G2 checks |
| **Gemini CLI** | `scripts/init.sh <repo> --gemini` | `AGENTS.md` context and 7 TOML slash commands |
| **Aider** | `scripts/init.sh <repo> --aider` | `.aider.conf.yml`, `CONVENTIONS.md`, lint hook wiring |
| **Other agents** | `scripts/init.sh <repo>` | Portable Markdown/YAML control plane through `AGENTS.md` |

The repository state is canonical. Conformance does not depend on which agent edited the files.

## What Gets Installed

```text
constitution.md                 Project rules and constitutional constraints
AGENTS.md                       Agent operating instructions
.axis/routing.yaml              Risk routing by file path and change type
.axis/evals/config.yaml         G3 Evaluate thresholds and runner config
.axis/commands/*.md             Portable lifecycle command bodies
.axis/templates/*               Proposal, Task Plan, gate, deployment templates
skills/*/SKILL.md               Reusable agent skills
```

Optional adapter flags add tool-specific files such as `.cursor/rules/`, `.cursor/commands/`, `~/.gemini/commands/`, `.aider.conf.yml`, and `.git/hooks/pre-commit`.

## Commands

The reference workflow exposes seven command bodies:

| Command | Purpose |
|---|---|
| `/axis:route` | Classify risk from `.axis/routing.yaml` |
| `/axis:specify` | Create a low-risk Task Record or moderate/high Change Record |
| `/axis:build` | Implement the approved change |
| `/axis:verify` | Run G3 Evaluate |
| `/axis:deploy` | Promote through configured environments |
| `/axis:onboard` | Create an initial capability spec from existing code |
| `/axis:amend` | Amend the Constitution through an ADR-backed process |

Tools that do not support custom slash commands can use the files under `.axis/commands/` as prompt bodies.

## Conformance

AXIS-26 defines three conformance tiers:

| Tier | Meaning |
|---|---|
| **Minimal** | Constitution, `AGENTS.md`, risk routing, at least one skill, and one change with G2 evidence |
| **Standard** | Adds EARS requirements, brownfield delta protocol, eval thresholds, DX Core 4 / MTTV tracking |
| **Full** | Adds cross-cutting context files, drift detection, AI-attributed failure tracking, Constitution review, shared skills library |

Run the reference checker:

```bash
python3 scripts/axis-conformance.py /path/to/your/repo
```

## Repository Layout

```text
axis-method/
├── AXIS-26.md                    # Specification
├── axis-core/                    # Claude Code + Codex reference plugin
├── adapters/                     # Cursor, Codex, Gemini CLI, Aider
├── scripts/                      # Bootstrap and conformance runner
├── docs/PORTABILITY.md           # Tool portability matrix
├── ap/                           # AXIS Proposals
└── .github/                      # Issue templates and repo metadata
```

## Cost and Dependencies

AXIS is free by default. The reference plugin and adapters do not require paid third-party services.

Recommended free tooling:

- `semgrep` for CWE/security checks, especially when installing the Git pre-commit shim.
- Your existing test runner for deterministic verification.
- Promptfoo, pytest, Jest, or similar tools for local eval execution.

Optional integrations such as Linear, Braintrust, and Snyk are documented in [axis-core/templates/mcp.example.json](./axis-core/templates/mcp.example.json) and are opt-in.

## Project Status

AXIS-26 is at **v0.0.1**. The current scope is a single repository with portable adapters and a reference plugin. Multi-repo governance, enterprise segregation of duties, and richer CI/CD bindings are future extensions.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for editorial, bug, substantive, feature, and deprecation paths. Plugin and adapter changes should follow the lifecycle AXIS teaches: file a change, specify it, build it, verify it, then submit a PR.

Security issues go through [SECURITY.md](./SECURITY.md), not public issues.

## License

- Specification text: **CC BY 4.0**
- Reference plugin, adapters, scripts, and templates: **Apache 2.0**

See [LICENSE](./LICENSE).

## Disclaimer

AXIS-26 is an opinionated engineering method, not regulatory pre-certification. Vendor names are not endorsements. The reference plugin executes shell hooks in your environment; review [axis-core/hooks/](./axis-core/hooks) before installing.
