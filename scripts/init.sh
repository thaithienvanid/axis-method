#!/usr/bin/env bash
# init.sh — Tool-agnostic AXIS-26 bootstrap.
# Drops Constitution, AGENTS.md, reusable AXIS skills, commands, templates,
# .axis/routing.yaml, and .axis/evals/config.yaml into a target repository
# regardless of which AI tool you use.
#
# Usage: ./scripts/init.sh <target-repo-path> [--cursor] [--gemini] [--aider] [--git-hooks]
#
# AXIS-26 Quick Start (§1.2): roughly two hours from clone to Minimal conformance.
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"
shift || true

if [[ -z "$TARGET" || "$TARGET" == "-h" || "$TARGET" == "--help" ]]; then
  cat <<'EOF'
Usage: init.sh <target-repo-path> [flags]

Flags:
  --cursor      Also install Cursor adapter (.cursor/rules + .cursorrules)
  --gemini      Also install Gemini CLI adapter (~/.gemini/commands TOML)
  --aider       Also install Aider adapter (.aider.conf.yml + CONVENTIONS.md symlink)
  --git-hooks   Install plugin hooks as .git/hooks/pre-commit (for non-Claude-Code tools)
  --force       Overwrite existing files (default: skip if present)
EOF
  exit 1
fi

[[ -d "$TARGET" ]] || { echo "error: target $TARGET does not exist" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

INSTALL_CURSOR=0
INSTALL_GEMINI=0
INSTALL_AIDER=0
INSTALL_GIT_HOOKS=0
FORCE=0

for flag in "$@"; do
  case "$flag" in
    --cursor)    INSTALL_CURSOR=1 ;;
    --gemini)    INSTALL_GEMINI=1 ;;
    --aider)     INSTALL_AIDER=1 ;;
    --git-hooks) INSTALL_GIT_HOOKS=1 ;;
    --force)     FORCE=1 ;;
    *) echo "unknown flag: $flag" >&2; exit 1 ;;
  esac
done

copy() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && $FORCE -eq 0 ]]; then
    printf 'skip   %s (exists; rerun with --force to overwrite)\n' "$dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  printf 'wrote  %s\n' "$dst"
}

copy_dir() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && $FORCE -eq 0 ]]; then
    printf 'skip   %s (exists; rerun with --force to overwrite)\n' "$dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" ]]; then
    rm -rf "$dst"
  fi
  cp -R "$src" "$dst"
  printf 'wrote  %s\n' "$dst"
}

# --- Tier 1: tool-agnostic core (always installed) -------------------------
copy "$PLUGIN_ROOT/axis-core/templates/constitution.md"  "$TARGET/constitution.md"
copy "$PLUGIN_ROOT/axis-core/templates/AGENTS.md"        "$TARGET/AGENTS.md"
copy "$PLUGIN_ROOT/axis-core/templates/routing.yaml"     "$TARGET/.axis/routing.yaml"
copy "$PLUGIN_ROOT/axis-core/templates/evals-config.yaml" "$TARGET/.axis/evals/config.yaml"
copy_dir "$PLUGIN_ROOT/axis-core/commands" "$TARGET/.axis/commands"
copy_dir "$PLUGIN_ROOT/axis-core/templates" "$TARGET/.axis/templates"

for skill_dir in "$PLUGIN_ROOT"/axis-core/skills/*; do
  [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]] || continue
  copy_dir "$skill_dir" "$TARGET/skills/$(basename "$skill_dir")"
done

mkdir -p "$TARGET/.axis/changes" "$TARGET/.axis/tasks"
[[ -f "$TARGET/.axis/.gitkeep" ]] || touch "$TARGET/.axis/.gitkeep"

# Intentionally NOT creating .axis/cwe/ — its absence makes pre-tool-use-cwe.sh
# block edits at risk moderate or high until the user authors actual CWE rules
# (AXIS-26 §4.1 principle 7). Creating it empty would silently bypass G2.

# --- Tier 2: per-tool adapters (opt-in) ------------------------------------
if (( INSTALL_CURSOR )); then
  copy "$PLUGIN_ROOT/adapters/cursor/axis-26.mdc" "$TARGET/.cursor/rules/axis-26.mdc"
  copy_dir "$PLUGIN_ROOT/axis-core/commands" "$TARGET/.cursor/commands"
  if [[ ! -e "$TARGET/.cursorrules" || $FORCE -eq 1 ]]; then
    ln -sf AGENTS.md "$TARGET/.cursorrules"
    printf 'wrote  %s -> AGENTS.md\n' "$TARGET/.cursorrules"
  fi
fi

if (( INSTALL_GEMINI )); then
  if [[ -d "$PLUGIN_ROOT/adapters/gemini/commands" ]]; then
    mkdir -p "$HOME/.gemini/commands"
    for cmd in "$PLUGIN_ROOT/adapters/gemini/commands"/*.toml; do
      [[ -e "$cmd" ]] || continue
      copy "$cmd" "$HOME/.gemini/commands/$(basename "$cmd")"
    done
  fi
fi

if (( INSTALL_AIDER )); then
  copy "$PLUGIN_ROOT/adapters/aider/aider.conf.yml" "$TARGET/.aider.conf.yml"
  if [[ ! -e "$TARGET/CONVENTIONS.md" || $FORCE -eq 1 ]]; then
    ln -sf AGENTS.md "$TARGET/CONVENTIONS.md"
    printf 'wrote  %s -> AGENTS.md\n' "$TARGET/CONVENTIONS.md"
  fi
fi

if (( INSTALL_GIT_HOOKS )); then
  if [[ -d "$TARGET/.git" ]]; then
    # The Claude Code hook (pre-tool-use-cwe.sh) reads tool-event JSON on stdin
    # and would silently no-op as a git pre-commit. Use the dedicated shim that
    # speaks the git pre-commit protocol while preserving §6.4 risk routing
    # and §4.1 principle-7 enforcement.
    cat > "$TARGET/.git/hooks/pre-commit" <<EOF
#!/usr/bin/env bash
    # AXIS-26 G2 Validate via Git pre-commit (for tools without native hooks).
exec "$PLUGIN_ROOT/scripts/git-pre-commit.sh"
EOF
    chmod +x "$TARGET/.git/hooks/pre-commit"
    printf 'wrote  %s/.git/hooks/pre-commit\n' "$TARGET"
  else
    printf 'warn   %s is not a git repository; skipping --git-hooks\n' "$TARGET" >&2
  fi
fi

cat <<EOF

------------------------------------------------------------------------------
AXIS-26 bootstrap complete in: $TARGET

Next steps:
  1. Edit constitution.md to declare your project's MUST/SHOULD/MAY rules.
  2. Edit .axis/routing.yaml glob lists to match your codebase.
  3. If you enabled --git-hooks, add project Semgrep rules under .axis/cwe/
     before committing moderate/high work, or route the first bootstrap task low.
  4. Open your AI tool of choice and run a first Change through Specify -> Build
     -> Verify -> Deploy -> Observe (AXIS-26 §6.1).
  5. After one Change ships end-to-end, your repo satisfies Minimal conformance
     (§3.1 M1-M5).

Tool-specific notes:
  * Claude Code:  /plugin marketplace add thaithienvanid/axis-method
                  /plugin install axis-core@axis-method
  * Codex:        install axis-core as a Codex plugin for skill discovery;
                  AGENTS.md still works as a fallback.
  * Cursor:       add --cursor for project rules and slash commands.
  * Gemini CLI:   add --gemini for command TOMLs.
  * Aider:        add --aider for conf + conventions.
  * Other tools:  point your tool at AGENTS.md.

See docs/PORTABILITY.md for the full matrix.
------------------------------------------------------------------------------
EOF
