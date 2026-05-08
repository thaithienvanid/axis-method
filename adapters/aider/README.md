# Aider adapter

Aider reads `CONVENTIONS.md` plus any files declared under `read:` in `.aider.conf.yml`.

## Install

```bash
./scripts/init.sh /path/to/your/repo --aider
```

This installs:

- Standard AXIS-26 control plane (Constitution, AGENTS.md, `.axis/commands/`, `.axis/templates/`, routing.yaml, evals config).
- `.aider.conf.yml` with `read: constitution.md, AGENTS.md` so they load on every Aider session.
- A `CONVENTIONS.md` symlink → `AGENTS.md` for tools that look there.
- `auto-lint: true` wired to the CWE scanner (requires `semgrep` and `.axis/cwe/` rules).

## Gates

`auto-commits: false` is mandatory in AXIS-26 — agents MUST NOT commit unless G2 Validate has passed. Aider's lint step runs the CWE scanner; if it fails, fix the issue and re-stage rather than suppressing.

For G3 Evaluate, wire `test-cmd:` to your eval runner (Braintrust, Promptfoo, pytest, jest) — see `.axis/templates/evals-config.yaml` for thresholds after bootstrap.

## Differences from Claude Code

- **Skills, subagents** — not supported by Aider. Use the SKILL.md bodies as context paste-ins.
- **Slash commands** — Aider's `/commands` are fixed; use `.axis/commands/*.md` bodies as one-shot prompts.
- **Hooks** — Aider's `auto-lint` covers G2 Validate deterministic checks. Routing escalation (PostToolUse) has no Aider equivalent; use Git pre-commit (`./scripts/init.sh --aider --git-hooks`).
