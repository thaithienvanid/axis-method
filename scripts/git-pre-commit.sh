#!/usr/bin/env bash
# git-pre-commit.sh — AXIS-26 G2 Validate via Git pre-commit hook.
#
# Why this exists: axis-core/hooks/pre-tool-use-cwe.sh expects Claude Code's
# tool-event JSON on stdin. Git's pre-commit hook receives no such input — so
# wiring the Claude hook directly into .git/hooks/pre-commit produces a silent
# no-op (the script reads empty stdin, finds no tool name, exits 0). This shim
# replaces the Claude-hook protocol with the git-pre-commit protocol while
# preserving the same §6.4 risk-routing precedence and §4.1 principle-7
# enforcement.
#
# Behavior:
#   1. Resolve risk = max(active Change/Task Record risks, default in routing.yaml).
#   2. At risk: low (§6.3) — skip CWE hook enforcement.
#   3. Otherwise require .axis/cwe/ to exist with at least one rule file.
#   4. Run Semgrep against staged files; non-zero exit blocks the commit.
#
# Install via: scripts/init.sh <repo> --git-hooks
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

# Risk levels ranked numerically so we pick the max.
risk_rank() {
  case "$1" in
    high) echo 3 ;;
    moderate) echo 2 ;;
    low) echo 1 ;;
    *) echo 0 ;;
  esac
}

RISK=""
HIGHEST=0
if compgen -G ".axis/changes/*/proposal.md" > /dev/null; then
  for prop in .axis/changes/*/proposal.md; do
    status=$(grep -E '^status:' "$prop" 2>/dev/null | head -1 | awk '{print $2}' || true)
    case "$status" in
      drafting|building|verifying|deploying|blocked|"") ;;
      *) continue ;;
    esac
    r=$(grep -E '^risk:' "$prop" 2>/dev/null | head -1 | awk '{print $2}' || true)
    rank=$(risk_rank "$r")
    if (( rank > HIGHEST )); then HIGHEST=$rank; RISK=$r; fi
  done
fi
if compgen -G ".axis/tasks/*.md" > /dev/null; then
  for task in .axis/tasks/*.md; do
    status=$(grep -E '^status:' "$task" 2>/dev/null | head -1 | awk '{print $2}' || true)
    case "$status" in
      drafting|building|verifying|deploying|blocked|"") ;;
      *) continue ;;
    esac
    r=$(grep -E '^risk:' "$task" 2>/dev/null | head -1 | awk '{print $2}' || true)
    rank=$(risk_rank "$r")
    if (( rank > HIGHEST )); then HIGHEST=$rank; RISK=$r; fi
  done
fi
if [[ -z "$RISK" && -f .axis/routing.yaml ]]; then
  RISK=$(grep -E '^default:' .axis/routing.yaml 2>/dev/null | awk '{print $2}' || true)
fi

# Risk low (or unresolved): skip per §6.3.
case "$RISK" in
  low|"") exit 0 ;;
esac

# Principle 7 (§4.1): require a CWE rule directory with at least one rule.
if ! compgen -G ".axis/cwe/*" > /dev/null; then
  cat >&2 <<EOF
AXIS-26 G2 Validate — commit blocked.

Reason: §4.1 principle 7 requires CWE Top 25 mappings, but no .axis/cwe/
rules are configured. This repo is at risk: $RISK.

Fix: add CWE Top 25 mappings to constitution.md and project-specific Semgrep
rules under .axis/cwe/, then retry the commit. To temporarily downgrade to
risk: low (and skip this hook), see AXIS-26 §6.4 override-downward rules.
EOF
  exit 1
fi

# Run Semgrep on staged files only. Without semgrep installed we abort with a
# clear message rather than silently pass — at risk moderate or high, "no
# scanner ran" is not equivalent to "scanner found nothing".
if ! command -v semgrep >/dev/null 2>&1; then
  cat >&2 <<EOF
AXIS-26 G2 Validate — commit blocked.

Reason: 'semgrep' is not installed but this repo is at risk: $RISK and has
.axis/cwe/ rules. Install semgrep (https://semgrep.dev) or temporarily
downgrade risk to low.
EOF
  exit 1
fi

mapfile -d '' STAGED < <(git diff --cached --name-only -z --diff-filter=ACMR)
[[ ${#STAGED[@]} -eq 0 ]] && exit 0

if ! semgrep --quiet --config=.axis/cwe/ --error "${STAGED[@]}" 2>&1; then
  cat >&2 <<EOF

AXIS-26 G2 Validate — commit blocked.

Reason: Semgrep flagged a CWE violation in staged files. Fix the underlying
issue; do NOT suppress the scanner without a linked Security ADR.
EOF
  exit 1
fi

exit 0
