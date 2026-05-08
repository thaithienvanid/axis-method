# Codex adapter

`axis-core` includes a Codex plugin manifest at `axis-core/.codex-plugin/plugin.json` and a local marketplace entry at `.agents/plugins/marketplace.json`. Codex clients that support repo-local marketplaces can discover `axis-core` from that file. Once installed, the plugin exposes the AXIS skills, including `axis-lifecycle`, which maps `/axis:*`-equivalent requests to project-local command bodies under `.axis/commands/`, falling back to `axis-core/commands/`.

For a target repository, still bootstrap the AXIS control plane:

```bash
./scripts/init.sh /path/to/your/repo --git-hooks
codex
```

Codex also reads `AGENTS.md` natively, so a repo remains usable without the plugin. The plugin improves invocation and consistency by making the AXIS skills discoverable to Codex.

## Lifecycle equivalents

Codex does not use Claude-style user-defined slash commands. Use natural prompts; the `axis-lifecycle` skill loads the matching command body:

```text
Run AXIS specify for my-feature.
Build AXIS change 2026-05-001-my-feature.
Verify AXIS change 2026-05-001-my-feature.
Deploy AXIS change 2026-05-001-my-feature.
Route AXIS change 2026-05-001-my-feature.
Onboard capability user-export.
Amend the AXIS Constitution for tighten-pii-policy.
```

Without the plugin, use the bootstrapped command bodies as one-shot prompts:

```bash
codex "$(cat .axis/commands/specify.md) — slug: my-feature"
codex "$(cat .axis/commands/build.md) — change: 2026-05-001-my-feature"
codex "$(cat .axis/commands/verify.md) — change: 2026-05-001-my-feature"
codex "$(cat .axis/commands/deploy.md) — change: 2026-05-001-my-feature"
codex "$(cat .axis/commands/route.md) — change: 2026-05-001-my-feature"
codex "$(cat .axis/commands/onboard.md) — capability: user-export"
codex "$(cat .axis/commands/amend.md) — slug: tighten-pii-policy"
```

## Skills

With the plugin installed, Codex can discover the skills under `axis-core/skills/`:

- `axis-lifecycle` — lifecycle coordinator for `/axis:*`-equivalent work.
- `risk-router` — deterministic risk classification.
- `ears-coach` — EARS requirement authoring and review.
- `multi-spec-conflict` — G1 Approve cross-reference checks.
- `eval-author` — eval design and threshold checks.
- `cwe-scanner` — G2 Validate/G3 Evaluate security scan guidance.
- `drift-detector` — Observe-phase drift checks.

Without the plugin, reference those `SKILL.md` bodies in your prompt as needed.

## Gates

Codex has no Claude-style plugin hook surface. Install the same deterministic enforcement via Git pre-commit:

```bash
./scripts/init.sh /path/to/your/repo --git-hooks
```

This wires `scripts/git-pre-commit.sh` into `.git/hooks/pre-commit` so G2 Validate fires at commit time. G3 Evaluate runs in CI as a shell command against your eval suite.

## Symphony orchestration

OpenAI's Symphony spec for Codex orchestration is out of scope at AXIS-26 v0.0.1. AXIS-26 future release will likely add a Symphony binding under §6.9 multi-agent coordination.
