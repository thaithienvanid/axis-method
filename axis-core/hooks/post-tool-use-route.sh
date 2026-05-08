#!/usr/bin/env bash
# post-tool-use-route.sh — surface mid-flight risk escalation when an edit touches a higher-risk
# glob OR a file/capability carrying a higher-risk marker. Implements the §6.4 precedence:
#   (1) frontmatter override  > (2) markers  > (3) globs  > (4) default.
# This hook covers (2) and (3); (1) and (4) live at /axis:specify entry.
# Note: the spec's §C.2 hook-to-gate table does not list PostToolUse; this hook is named in
# the §C.1 plugin file inventory and serves as a defense against silent under-routing (§6.4
# "Mid-flight risk upgrades require an explicit upward override").
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  printf 'axis-core: jq not found; PostToolUse(routing) hook is a no-op.\n' >&2
  exit 0
fi

INPUT=$(cat)
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // .tool // empty')
PATH_ARG=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .arguments.path // empty')

case "$TOOL" in
  Edit|Write|MultiEdit|str_replace|create_file) ;;
  *) exit 0 ;;
esac
[[ -z "$PATH_ARG" ]] && exit 0

REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ROUTING="$REPO_ROOT/.axis/routing.yaml"
[[ -f "$ROUTING" ]] || exit 0
ABS_PATH="$PATH_ARG"
if [[ "$ABS_PATH" != /* ]]; then
  ABS_PATH="$REPO_ROOT/$PATH_ARG"
fi

# Find the highest-risk open Change Record or Task Record in drafting/building.
rank() {
  case "$1" in
    low) echo 1 ;;
    moderate) echo 2 ;;
    high) echo 3 ;;
    *) echo 0 ;;
  esac
}

CURRENT_RISK=""
CURRENT_RANK=0
ACTIVE_RECORDS=0
for dir in "$REPO_ROOT"/.axis/changes/*/; do
  [[ -d "$dir" ]] || continue
  status=$(grep -E '^status:' "$dir/proposal.md" 2>/dev/null | head -1 | awk '{print $2}' || true)
  if [[ "$status" == "drafting" || "$status" == "building" ]]; then
    risk=$(grep -E '^risk:' "$dir/proposal.md" 2>/dev/null | head -1 | awk '{print $2}' || true)
    risk_rank=$(rank "$risk")
    ACTIVE_RECORDS=$((ACTIVE_RECORDS + 1))
    if (( risk_rank > CURRENT_RANK )); then
      CURRENT_RISK="$risk"
      CURRENT_RANK="$risk_rank"
    fi
  fi
done
for task in "$REPO_ROOT"/.axis/tasks/*.md; do
  [[ -f "$task" ]] || continue
  status=$(grep -E '^status:' "$task" 2>/dev/null | head -1 | awk '{print $2}' || true)
  if [[ "$status" == "drafting" || "$status" == "building" ]]; then
    risk=$(grep -E '^risk:' "$task" 2>/dev/null | head -1 | awk '{print $2}' || true)
    risk_rank=$(rank "$risk")
    ACTIVE_RECORDS=$((ACTIVE_RECORDS + 1))
    if (( risk_rank > CURRENT_RANK )); then
      CURRENT_RISK="$risk"
      CURRENT_RANK="$risk_rank"
    fi
  fi
done
(( ACTIVE_RECORDS == 0 )) && exit 0
[[ -z "$CURRENT_RISK" ]] && exit 0          # malformed frontmatter — let G2 Validate catch it later.
[[ "$CURRENT_RISK" == "high" ]] && exit 0   # already at top — nothing to escalate.

# Extract a YAML list that may be either block-form ("- item" lines)
# or inline-array form (`key: ["a", "b"]`). Args: <key-name> <parent-key>.
extract_list() {
  local key="$1" parent="$2"
  awk -v key="$key" -v parent="$parent" '
    $0 ~ "^[[:space:]]*" parent ":[[:space:]]*$" { in_p = 1; next }
    in_p && $0 ~ "^[[:space:]]*" key ":[[:space:]]*\\[" {
      sub(/^[^\[]*\[/, ""); sub(/\].*$/, "")
      n = split($0, a, /,/)
      for (i = 1; i <= n; i++) {
        gsub(/^[[:space:]]*"?|"?[[:space:]]*$/, "", a[i])
        if (a[i] != "") print a[i]
      }
      next
    }
    in_p && $0 ~ "^[[:space:]]*" key ":[[:space:]]*$" { in_b = 1; next }
    in_b && /^[[:space:]]*-/ { gsub(/^[[:space:]]*-[[:space:]]*"?|"?[[:space:]]*$/, ""); print; next }
    in_b && /^[^[:space:]-]/ { in_b = 0 }
    in_p && /^[^[:space:]]/ { in_p = 0; in_b = 0 }
  ' "$ROUTING"
}

REL_PATH="${ABS_PATH#$REPO_ROOT/}"
GLOB_HIT=""
GLOB_RISK=""
ROUTE_RISK=""
ROUTE_RANK=0

match_globs_for_risk() {
  local risk="$1"
  local glob
  while IFS= read -r glob; do
    [[ -z "$glob" ]] && continue
    case "$REL_PATH" in
      $glob) printf '%s' "$glob"; return 0 ;;
    esac
  done <<< "$(extract_list glob "$risk")"
  return 1
}

for risk in high moderate; do
  if GLOB_HIT=$(match_globs_for_risk "$risk"); then
    GLOB_RISK="$risk"
    ROUTE_RISK="$risk"
    ROUTE_RANK=$(rank "$risk")
    break
  fi
done

# (2) Markers declared under risks.<risk>.markers, e.g. "pii: true", "regulated: true".
# A marker fires when the touched file (or its capability spec) declares it.
MARKER_HIT=""
MARKER_RISK=""
MARKER_RANK=0
if [[ -f "$ABS_PATH" ]]; then
  for risk in high moderate; do
    markers=$(extract_list markers "$risk")
    while IFS= read -r marker; do
      [[ -z "$marker" ]] && continue
      if grep -qF "$marker" "$ABS_PATH" 2>/dev/null; then
        MARKER_HIT="$marker"
        MARKER_RISK="$risk"
        MARKER_RANK=$(rank "$risk")
        break
      fi
    done <<< "$markers"
    [[ -n "$MARKER_HIT" ]] && break
  done
fi

if (( MARKER_RANK > ROUTE_RANK )); then
  ROUTE_RISK="$MARKER_RISK"
  ROUTE_RANK="$MARKER_RANK"
fi

if (( ROUTE_RANK > CURRENT_RANK )); then
  reason="AXIS-26 §6.4: edit to '$REL_PATH' would route $ROUTE_RISK"
  [[ -n "$GLOB_HIT" && "$GLOB_RISK" == "$ROUTE_RISK" ]] && reason+=" via glob '$GLOB_HIT'"
  if [[ -n "$MARKER_HIT" && "$MARKER_RISK" == "$ROUTE_RISK" ]]; then
    reason+=" via marker '$MARKER_HIT'"
  fi
  reason+=" but the highest active work record risk is '$CURRENT_RISK'. Upward override required (any pod member). Record the override in the primary record before continuing."
  jq -n --arg msg "$reason" \
    '{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": $msg } }'
fi

exit 0
