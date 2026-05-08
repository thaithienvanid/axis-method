#!/usr/bin/env bash
# stop-eval-gate.sh — AXIS-26 §C.2 Stop hook
# Reminds the agent to run /axis:verify (G3) before declaring a Build complete.
set -euo pipefail

# `jq` is required to emit the block decision. Fail soft — never abort the
# parent session if jq is missing.
if ! command -v jq >/dev/null 2>&1; then
  printf 'axis-core: jq not found; Stop(eval-gate) hook is a no-op.\n' >&2
  exit 0
fi

REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Look for any change in 'building' status whose tasks.md is fully checked.
PENDING=""
for dir in "$REPO_ROOT"/.axis/changes/*/; do
  [[ -d "$dir" ]] || continue
  status=$(grep -E '^status:' "$dir/proposal.md" 2>/dev/null | head -1 | awk '{print $2}')
  [[ "$status" == "building" ]] || continue

  tasks_file="$dir/tasks.md"
  [[ -f "$tasks_file" ]] || continue

  # Treat checkboxes "- [ ]" as outstanding work; "- [x]" as done.
  # `grep -c` exits 1 on zero matches but still prints the count; `|| true`
  # masks the failure without doubling stdout.
  outstanding=$(grep -cE '^- \[ \]' "$tasks_file" 2>/dev/null || true)
  if [[ "${outstanding:-0}" -eq 0 ]]; then
    PENDING="$(basename "$dir")"
    break
  fi
done

if [[ -n "$PENDING" ]]; then
  jq -n --arg id "$PENDING" \
    '{ "decision": "block",
       "reason": ("Change " + $id + " is fully built but has not run G3 Evaluate. Run /axis:verify before stopping. AXIS-26 §6.2 requires G3 Evaluate before Deploy.") }'
  exit 0
fi

exit 0
