# Cursor adapter

Two ways to run AXIS-26 inside Cursor:

## Option A — automatic (recommended)

```bash
./scripts/init.sh /path/to/your/repo --cursor
```

This installs:

- `.cursor/rules/axis-26.mdc` — always-applied project rule that loads the Constitution, AGENTS.md, and risk routing into every Cursor request.
- `.cursor/commands/*.md` — project slash commands copied from `axis-core/commands/`.
- `.cursorrules` symlink → `AGENTS.md` for older Cursor versions.

## Option B — manual

1. Copy `axis-26.mdc` to `<your-repo>/.cursor/rules/axis-26.mdc`.
2. Copy `axis-core/commands/*.md` to `<your-repo>/.cursor/commands/`.
3. (Optional, older Cursor) `ln -s AGENTS.md .cursorrules`.

## Slash commands

Cursor 0.42+ supports project slash commands at `.cursor/commands/`. `init.sh --cursor` installs them automatically. For manual setup, copy the tool-agnostic command bodies:

```bash
mkdir -p .cursor/commands
cp axis-core/commands/*.md .cursor/commands/
```

The commands will appear in Cursor's slash-command palette as `/specify`, `/build`, `/verify`, etc. The `<plugin>:<verb>` form is defined in §2.4 (File and Naming Conventions); §2.3 reserves the `axis-` *plugin-package* prefix in public marketplaces. Cursor's tooling does not currently support namespaced slash commands — implementations MAY extend §2.4 conventions (so dropping the `axis:` prefix is fine) but MUST NOT contradict them. Conformance is unaffected: §3.1–§3.3 invariants check repository state, not slash-command names.

## Gates and hooks

Cursor does not have a native pre-tool-use hook surface. To enforce G2 Validate (CWE scan) in Cursor:

```bash
./scripts/init.sh /path/to/your/repo --cursor --git-hooks
```

This installs `scripts/git-pre-commit.sh` as `.git/hooks/pre-commit`. Unlike the Claude Code hook (which speaks tool-event JSON), the Git shim runs Semgrep against staged files directly and refuses the commit on any §4.1 principle-7 violation. G3 Evaluate runs in CI regardless of editor — no Cursor-specific work needed.
