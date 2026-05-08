# Gemini CLI adapter

Gemini CLI reads `AGENTS.md` (or `GEMINI.md`) for project context and supports user-defined slash commands as TOML files in `~/.gemini/commands/`.

## Install

```bash
./scripts/init.sh /path/to/your/repo --gemini
```

This installs:

- The standard AXIS-26 control plane (`constitution.md`, `AGENTS.md`, `.axis/commands/`, `.axis/templates/`, `.axis/routing.yaml`, `.axis/evals/config.yaml`).
- Seven slash command TOMLs in `~/.gemini/commands/`: `/specify`, `/build`, `/verify`, `/deploy`, `/route`, `/onboard`, `/amend`.

## Manual install

```bash
mkdir -p ~/.gemini/commands
cp adapters/gemini/commands/*.toml ~/.gemini/commands/
```

Then in a Gemini CLI session, `/specify <slug>` etc. are available.

## Gates

Gemini CLI does not have a native pre-tool-use hook surface. Install Git pre-commit:

```bash
./scripts/init.sh /path/to/your/repo --gemini --git-hooks
```

## Differences from Claude Code

- **Skills** — Gemini CLI does not invoke `SKILL.md` files automatically. Reference them by passing the relevant SKILL.md content into the prompt when authoring requirements (`ears-coach`), reviewing diffs (`cwe-scanner`), etc.
- **Subagents** — no equivalent. The plugin's three subagents (`specifier`, `verifier`, `drift-watcher`) are Markdown system prompts; copy their bodies into Gemini system instructions if you want long-running agents in those roles.
- **Hooks** — not supported. Use Git pre-commit and CI for G2 Validate / G3 Evaluate enforcement.

The repository state and conformance test (§3.4) are agent-agnostic.
