# Tool Portability

AXIS-26 principle 5 (§4.1) is **tool-portable, vendor-replaceable, model-fungible**. The spec itself works with any agent that reads `AGENTS.md` and Markdown. The `axis-core` plugin is the **Claude Code** harness; equivalent harnesses for other tools are scaffolded under [`adapters/`](../adapters).

## What's portable across all tools

These artifacts are plain Markdown / YAML / JSON and work identically in every harness:

| Artifact | Format | Consumed by |
|---|---|---|
| `constitution.md` | Markdown + tables | All — loaded as project context |
| `AGENTS.md` | [AGENTS.md spec](https://agents.md) | Claude Code, Codex CLI, Cursor, Gemini CLI, Aider, others |
| `.axis/commands/*.md` | Markdown command bodies | Any tool as prompt bodies; Cursor as project slash commands |
| `.axis/templates/*` | Markdown / YAML / JSON templates | Any tool when creating lifecycle evidence |
| `.axis/routing.yaml` | YAML (Appendix A.1) | Tool-agnostic; consumed by hooks/CI |
| `.axis/changes/<id>/*.md` | Markdown | Tool-agnostic |
| `/specs/<cap>/spec.md` | EARS Markdown (§B.3) | Tool-agnostic |
| `/skills/<name>/SKILL.md` | [Anthropic SKILL.md format](https://github.com/anthropics/skills) | Claude Code natively; other tools as system prompts |

**Bottom line**: run the bootstrap, point your agent at `AGENTS.md`, and you have AXIS-26 conformance signal regardless of which agent you use.

## Per-tool setup

### Claude Code (full plugin — hooks, slash commands, subagents, marketplace install)

```text
/plugin marketplace add thaithienvanid/axis-method
/plugin install axis@axis-method
```

You get `/axis:specify`, `/axis:build`, `/axis:verify`, `/axis:deploy`, `/axis:onboard`, `/axis:amend`, `/axis:route` plus four lifecycle hooks (G2 Validate CWE scan, G3 Evaluate gate, routing escalation, session context).

See [`axis-core/README.md`](../axis-core/README.md).

### Codex (OpenAI)

`axis-core` includes a Codex plugin manifest at `axis-core/.codex-plugin/plugin.json` and a local marketplace entry at `.agents/plugins/marketplace.json`. Codex clients that support repo-local marketplaces can discover `axis-core` from that file. After installation, bootstrap your target repository:

```bash
./scripts/init.sh /path/to/your/repo --git-hooks
codex
```

Codex also reads `AGENTS.md` natively, so it can still use the bootstrapped control plane without the plugin. Lifecycle equivalents are documented in [`adapters/codex/README.md`](../adapters/codex/README.md).

### Cursor

Cursor reads project rules from `.cursor/rules/*.mdc`. The adapter at [`adapters/cursor/`](../adapters/cursor) provides:

- `.cursor/rules/axis-26.mdc` — always-on rule that loads the Constitution, AGENTS.md, and routing.yaml.
- `.cursor/commands/*.md` — project slash commands copied from `axis-core/commands/`.
- `.cursorrules` — fallback for older Cursor versions; symlink to `AGENTS.md`.

```bash
./scripts/init.sh /path/to/your/repo --cursor
```

### Gemini CLI

Gemini CLI reads `AGENTS.md` (or `GEMINI.md`) and supports custom commands via TOML files in `~/.gemini/commands/`. The adapter at [`adapters/gemini/`](../adapters/gemini) provides TOML versions of the seven `/axis:*` commands.

```bash
./scripts/init.sh /path/to/your/repo --gemini
```

### Aider

Aider reads `CONVENTIONS.md` and project markdown. The adapter at [`adapters/aider/`](../adapters/aider) provides a `.aider.conf.yml` snippet that loads the Constitution and AGENTS.md as conventions, plus a `CONVENTIONS.md` symlink target.

```bash
./scripts/init.sh /path/to/your/repo --aider
```

### Other tools (Continue, Cline, Goose, RA.Aid, …)

If your tool reads any of these, you're 80% there:

- A project-level Markdown context file → point at `AGENTS.md`.
- A rules / conventions directory → symlink `constitution.md` and `AGENTS.md`.
- MCP servers → see [`axis-core/templates/mcp.example.json`](../axis-core/templates/mcp.example.json) (opt-in; all paid).

Open a PR adding an adapter under `adapters/<your-tool>/` — that's how the portability matrix grows.

## Hook automation: not portable today

The Claude Code plugin includes four lifecycle hooks (`SessionStart`, `PreToolUse`, `PostToolUse`, `Stop`) that run shell scripts on agent events. **No other tool currently exposes an equivalent hook surface.** The plugin replicates G2 Validate via:

- **Cursor / Codex / others** — install the same checks as **Git pre-commit hooks** (Husky, `pre-commit` framework, or plain `.git/hooks/pre-commit`). The CWE scan is deterministic, so it can run independently of the agent harness.
- `./scripts/init.sh <repo> --git-hooks` installs `scripts/git-pre-commit.sh` into `.git/hooks/pre-commit` of a target repo when you cannot use Claude Code hooks.

The G3 Evaluate gate runs as CI in any environment — it's a shell command against your eval suite.

## Conformance is harness-agnostic

The conformance test (§3.4) checks repository state, not which agent edited the files:

```bash
python3 scripts/axis-conformance.py /path/to/your/repo
```

A repo authored entirely in Cursor with no Claude Code plugin can pass Minimal/Standard/Full conformance just as cleanly as a Claude Code repo. The plugin is a convenience, not a gate.
