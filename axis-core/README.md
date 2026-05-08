# axis-core

Reference plugin for **AXIS-26 v0.0.1** (Agentic eXecutable Intent Specification). The Claude Code manifest provides slash commands, subagents, and hooks. The Codex manifest exposes the same method through skills, including a lifecycle coordinator for `/axis:*`-equivalent work.

For other tools — Cursor, Gemini CLI, Aider — see [`../adapters/`](../adapters) and [`../docs/PORTABILITY.md`](../docs/PORTABILITY.md). The spec artifacts (Constitution, AGENTS.md, routing.yaml, EARS specs, SKILL.md) are tool-agnostic Markdown / YAML; lifecycle hooks remain Claude Code-specific, with Git pre-commit as the portable fallback.

## What you get

```
axis-core/
├── .claude-plugin/plugin.json    # Claude Code manifest + hook bindings
├── .codex-plugin/plugin.json     # Codex manifest + skill discovery
├── commands/                     # /axis:route, specify, build, verify, deploy, onboard, amend
├── skills/                       # axis-lifecycle, ears-coach, cwe-scanner,
│                                 #   risk-router, multi-spec-conflict,
│                                 #   eval-author, drift-detector
├── agents/                       # specifier, verifier, drift-watcher
├── hooks/                        # session-start, pre-tool-use-cwe,
│                                 #   post-tool-use-route, stop-eval-gate
├── templates/                    # constitution.md, AGENTS.md, routing.yaml,
│                                 #   proposal.md, delta.md, low-risk-task.md,
│                                 #   task-plan.md,
│                                 #   g1-approve.md, g2-validate-report.json,
│                                 #   g3-evaluate-report.json,
│                                 #   deployment-record.md, emergency-record.md,
│                                 #   evals-config.yaml, mcp.example.json
└── README.md
```

## Cost & third-party dependencies

**The plugin is free and self-contained.** Installing it costs nothing beyond your AI coding tool access. It does not auto-load any paid third-party service.

- **Required at runtime:** nothing beyond a POSIX shell and `jq` (already standard in Claude Code environments).
- **Recommended (free, open source):** [`semgrep`](https://semgrep.dev) for the CWE scanner hook. At risk moderate/high, hooks fail closed when no `.axis/cwe/` rule files exist. After rules exist, Claude Code's interactive hook degrades gracefully if Semgrep is missing; the Git pre-commit shim blocks until Semgrep is installed.
- **Optional integrations (paid third-party — opt-in):** Linear (gateway sync §7.3), Braintrust (eval infra §8), Snyk (SAST §6.2). See [`templates/mcp.example.json`](./templates/mcp.example.json). Copy the entries you want into your *project's* `.mcp.json` — not into the plugin — and set the env vars. Free substitutes for each vendor are listed in AXIS-26 Appendix D.3 ("Tooling Stack") and in the example file.

Per AXIS-26 principle 5 (tool-portable, vendor-replaceable, model-fungible), the plugin does not endorse or require any specific vendor.

## Install

### Claude Code

Clone the plugin into a Claude Code marketplace directory or reference it directly from a `.claude-plugin/marketplace.json`:

```bash
mkdir -p ~/.claude/plugins
cp -r axis-core ~/.claude/plugins/
```

Then in your target repository, drop the reusable commands, templates, and skills into place (Quick Start, AXIS-26 §1.2 — about two hours):

```bash
/path/to/axis-method/scripts/init.sh .
```

You now satisfy Minimal conformance once a first Change has flowed through the lifecycle (M1–M5 in AXIS-26 §3.1).

### Codex

Codex clients that support repo-local marketplaces can discover `axis-core` from [`../.agents/plugins/marketplace.json`](../.agents/plugins/marketplace.json). The Codex manifest is [`./.codex-plugin/plugin.json`](./.codex-plugin/plugin.json) and exposes the skills under [`./skills/`](./skills/).

Codex does not use Claude-style slash commands or plugin hooks. Use normal prompts such as:

```text
Run AXIS specify for my-feature.
Build AXIS change 2026-05-001-my-feature.
Verify AXIS change 2026-05-001-my-feature.
```

The `axis-lifecycle` skill maps those requests to the command bodies under [`./commands/`](./commands/). For deterministic G2 checks in Codex-managed repos, install the portable Git hook:

```bash
/path/to/axis-method/scripts/init.sh /path/to/your/repo --git-hooks
```

## Lifecycle map

| Phase | Claude command / Codex intent | Gate | Owner |
|---|---|---|---|
| Specify | `/axis:specify <slug>` / "Run AXIS specify" | G1 Approve for moderate/high; two-key at high | Pod + Agent Fleet |
| Build | `/axis:build <id>` / "Build AXIS change" | G2 Validate (deterministic hook or Git pre-commit) | Agent Fleet |
| Verify | `/axis:verify <id>` / "Verify AXIS change" | G3 Evaluate (eval + constitutional scan) | ARE + LLM-judge |
| Deploy | `/axis:deploy <id>` / "Deploy AXIS change" | environment list + G3 Evaluate re-run per environment | Pod Lead |
| Observe | (drift-watcher agent) | continuous | ARE |

Adjacent commands:

- `/axis:route <id>` — show the deterministic risk classification.
- `/axis:onboard <capability>` — generate an initial `/specs/<cap>/spec.md` from existing code.
- `/axis:amend <slug>` — Constitution amendment with mandatory ADR.

## Hook-to-gate mapping

Per AXIS-26 §C.2:

| Lifecycle event | Hook | Function |
|---|---|---|
| Session start | `SessionStart` → `session-start.sh` | Load Constitution + AGENTS.md; surface open Change Records, Task Records, and risk |
| G1 Approve | manual, human | Pod approves `proposal.md` + `evals/`; two-key at risk high |
| G2 Validate | `PreToolUse` → `pre-tool-use-cwe.sh` | CWE scanner via Semgrep on edits at risk moderate or high; type checks and additional lints run in CI/project scripts |
| G2 Validate cont'd | `PostToolUse` → `post-tool-use-route.sh` | Catch silent risk escalation; require explicit upward override |
| G3 Evaluate | `Stop` → `stop-eval-gate.sh` | Block agent stop until G3 Evaluate has run for fully-built Changes |
| Deploy | external CI/CD | Canary, blue/green, traffic ramp |
| Observe | `drift-watcher` agent | Schema diff, telemetry fingerprint, ADR-vs-code scan |

## Conformance

Following the templates and running one Change end-to-end produces a **Minimal**-conforming repository (§3.1). To reach **Standard** (§3.2):

- Express requirements in EARS form (`ears-coach`).
- Enforce the brownfield delta protocol (`multi-spec-conflict` runs at G1 Approve).
- Configure `.axis/evals/config.yaml` thresholds at the floors in §8.2.
- Track DX Core 4 + MTTV in your dashboard.

For **Full** (§3.3), add the F1 cross-cutting context files (`PRODUCT.md`, `DESIGN.md`, `BACKEND.md`, `INFRA.md`, `THREAT-MODEL.md`, `DOMAIN.md`, `RUNBOOK.md`), turn on `drift-watcher`, and hold quarterly Constitution Reviews (§D.8).

## Tool portability

- Slash commands and templates are plain Markdown; `scripts/init.sh` copies them to `.axis/commands/` and `.axis/templates/` so non-plugin harnesses have local prompt bodies and artifact shapes. Codex consumes the plugin copies through the `axis-lifecycle` skill when the plugin is installed.
- Skills follow the `SKILL.md` standard — directly consumable by Skill-aware harnesses.
- The `.axis/` control plane is plain Markdown + YAML; no SaaS dependency.

## Anti-patterns refused by this plugin

- Eval theater (thresholds set so nothing fails) — `eval-author` enforces the §8.2 floors and the κ-validation cadence.
- One-size-fits-all rigor — `risk-router` and `routing.yaml` make rigor a function of code, not stakeholder.
- SaaS-as-truth control plane — `.axis/` is canonical; gateway sync is mirror-only (§7.3).
- Spec poisoning — skills are versioned, signed, and reviewed; `cwe-scanner` flags injection patterns (§10).
- Single-person two-key approval — `/axis:specify` and `/axis:deploy` refuse it at risk high (§6.2).

## Versioning

The plugin is versioned independently from the AXIS-26 specification but tracks the specification line it implements. `axis-core` `0.x` conforms to AXIS-26 `0.x`.

## License

Apache 2.0.
