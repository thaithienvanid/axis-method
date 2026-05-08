#!/usr/bin/env bash
# pre-tool-use-cwe.sh — AXIS-26 §C.4 PreToolUse hook.
# Runs the CWE scanner on edits at risk moderate or high before the edit lands.
# Per §6.3 risk low is exempt from G2 Validate CWE checks.
set -euo pipefail

# `jq` is required to read the hook input. Fail soft — never abort the parent.
if ! command -v jq >/dev/null 2>&1; then
  printf 'axis-core: jq not found; PreToolUse(CWE) hook is a no-op.\n' >&2
  exit 0
fi

INPUT=$(cat)
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // .tool // empty')
PATH_ARG=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .arguments.path // empty')

# Only fire for editing tools.
case "$TOOL" in
  Edit|Write|MultiEdit|str_replace|create_file) ;;
  *) exit 0 ;;
esac

[[ -z "$PATH_ARG" ]] && exit 0

REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ABS_PATH="$PATH_ARG"
if [[ "$ABS_PATH" != /* ]]; then
  ABS_PATH="$REPO_ROOT/$PATH_ARG"
fi
REL_PATH="${ABS_PATH#$REPO_ROOT/}"

# Rank risk levels explicitly. Lex sort would order moderate > low > high; that's wrong.
risk_rank() {
  case "$1" in
    high)     echo 3 ;;
    moderate) echo 2 ;;
    low)      echo 1 ;;
    *)        echo 0 ;;
  esac
}

# Resolve current work risk = max(active Change/Task Record risks). If no active
# record exists, fall back to `default` in routing.yaml. `|| true` keeps grep
# no-match from aborting the pipeline.
RISK=""
HIGHEST_RANK=0
if compgen -G "$REPO_ROOT/.axis/changes/*/proposal.md" > /dev/null; then
  for prop in "$REPO_ROOT"/.axis/changes/*/proposal.md; do
    status=$(grep -E '^status:' "$prop" 2>/dev/null | head -1 | awk '{print $2}' || true)
    case "$status" in
      drafting|building|verifying|deploying|blocked|"") ;;
      *) continue ;;
    esac
    r=$(grep -E '^risk:' "$prop" 2>/dev/null | head -1 | awk '{print $2}' || true)
    rank=$(risk_rank "$r")
    if (( rank > HIGHEST_RANK )); then
      HIGHEST_RANK=$rank
      RISK=$r
    fi
  done
fi
if compgen -G "$REPO_ROOT/.axis/tasks/*.md" > /dev/null; then
  for task in "$REPO_ROOT"/.axis/tasks/*.md; do
    status=$(grep -E '^status:' "$task" 2>/dev/null | head -1 | awk '{print $2}' || true)
    case "$status" in
      drafting|building|verifying|deploying|blocked|"") ;;
      *) continue ;;
    esac
    r=$(grep -E '^risk:' "$task" 2>/dev/null | head -1 | awk '{print $2}' || true)
    rank=$(risk_rank "$r")
    if (( rank > HIGHEST_RANK )); then
      HIGHEST_RANK=$rank
      RISK=$r
    fi
  done
fi
if [[ -z "$RISK" && -f "$REPO_ROOT/.axis/routing.yaml" ]]; then
  RISK=$(grep -E '^default:' "$REPO_ROOT/.axis/routing.yaml" 2>/dev/null | awk '{print $2}' || true)
fi

# Risk low (or unresolved): skip per §6.3.
case "$RISK" in
  low|"") exit 0 ;;
esac

# Principle 7 (§4.1): refuse the edit if no CWE rule files are configured at moderate/high.
if ! compgen -G "$REPO_ROOT/.axis/cwe/*" > /dev/null; then
  jq -n '{
    decision: "block",
    reason: "AXIS-26 §4.1 principle 7: no .axis/cwe/ rule files configured. Add CWE Top 25 mappings to constitution.md and project rules to .axis/cwe/ before editing at risk moderate or high."
  }'
  exit 0
fi

# Run Semgrep if available; otherwise fall through (CI must catch).
if command -v semgrep >/dev/null 2>&1; then
  if ! semgrep --quiet --config="$REPO_ROOT/.axis/cwe/" --error "$ABS_PATH" 2>/dev/null; then
    jq -n --arg path "$REL_PATH" '{
      decision: "block",
      reason: ("AXIS-26 G2 Validate: CWE violation in " + $path + ". Fix the underlying issue; do not suppress the scanner.")
    }'
    exit 0
  fi
fi

exit 0
