#!/usr/bin/env bash
# session-start.sh — AXIS-26 §C.2 SessionStart hook.
# Loads constitution.md, AGENTS.md, .axis/routing.yaml, and a one-line summary
# of open Change Records and Task Records into the agent's additionalContext
# (NOT to the user terminal).
set -euo pipefail

REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# `jq` is required by all four AXIS-26 hooks. Fail soft, don't abort the session.
if ! command -v jq >/dev/null 2>&1; then
  printf 'axis-core: jq not found; SessionStart hook is a no-op.\n' >&2
  exit 0
fi

# Read each file (best-effort) into a single context blob.
read_file() {
  local label="$1" path="$2"
  [[ -f "$path" ]] || return 0
  printf '\n--- %s (%s) ---\n' "$label" "${path#$REPO_ROOT/}"
  cat "$path"
}

CONTEXT=$(
  printf 'AXIS-26 v0.0.1 session context loaded.\n'
  read_file "Constitution"      "$REPO_ROOT/constitution.md"
  read_file "AGENTS.md"         "$REPO_ROOT/AGENTS.md"
  read_file "routing.yaml"      "$REPO_ROOT/.axis/routing.yaml"
  read_file "evals/config.yaml" "$REPO_ROOT/.axis/evals/config.yaml"

  if compgen -G "$REPO_ROOT/.axis/changes/*/proposal.md" > /dev/null; then
    printf '\n--- Open Change Records ---\n'
    for prop in "$REPO_ROOT"/.axis/changes/*/proposal.md; do
      change_id=$(basename "$(dirname "$prop")")
      status=$(grep -E '^status:' "$prop" 2>/dev/null | head -1 | awk '{print $2}')
      risk=$(grep -E '^risk:'   "$prop" 2>/dev/null | head -1 | awk '{print $2}')
      printf '  %s  risk=%s  status=%s\n' "$change_id" "${risk:-unknown}" "${status:-unknown}"
    done
  fi

  if compgen -G "$REPO_ROOT/.axis/tasks/*.md" > /dev/null; then
    printf '\n--- Open Task Records ---\n'
    for task in "$REPO_ROOT"/.axis/tasks/*.md; do
      task_id=$(basename "$task" .md)
      status=$(grep -E '^status:' "$task" 2>/dev/null | head -1 | awk '{print $2}')
      risk=$(grep -E '^risk:'   "$task" 2>/dev/null | head -1 | awk '{print $2}')
      # Skip archived records. `continue` inside a case inside a $(...) subshell
      # crashes bash 3.2 (macOS default shell), so invert the predicate.
      if [[ "$status" != "archived" ]]; then
        printf '  %s  risk=%s  status=%s\n' "$task_id" "${risk:-unknown}" "${status:-unknown}"
      fi
    done
  fi
)

jq -n --arg ctx "$CONTEXT" \
  '{ hookSpecificOutput: { hookEventName: "SessionStart", additionalContext: $ctx } }'
