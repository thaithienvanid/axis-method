---
description: Walk a moderate/high Change Record through the environment list declared per risk level in routing.yaml (AXIS-26 §6.7).
argument-hint: "<change-id>"
allowed-tools: Read Write Edit Bash(git:*) Bash(gh:*)
---

# /axis:deploy — Phase 4 (Deploy)

Walk a moderate/high Change Record through `routing.yaml.risks.<risk>.environments`. Promotion between environments is gated by **G3 Evaluate re-running for each environment** (§6.7). Low-risk Task Records do not use this command.

## Default environment lists (§6.7, Appendix B.4)

```yaml
risks:
  moderate: { environments: [staging, prod] }
  high:     { environments: [staging, canary, prod] }
```

## Process

1. Refuse if `status` is not `deploying`. G3 Evaluate must have passed.
2. Refuse if any `depends_on:` is not yet `live` (§6.9).
3. For each environment in order:
   - Promote the artifact (or flip the feature flag).
   - Set frontmatter `environment: <env>`.
   - Re-run G3 Evaluate at this environment's `eval_threshold`.
   - Honor `auto_promote: true` (advance without human) or `auto_promote: false` (require approver in `require_approval:`).
   - For `canary`: enforce `traffic_percent`, `soak_duration`, then re-evaluate.
   - On failure: revert frontmatter to `status: verifying`. Do not advance (§6.7).
4. After clearing the final environment: set `status: live`. Record `deployed_at:` and `deploy_sha:` in frontmatter.

## Feature flags (§6.7)

Prefer feature-flag rollback (seconds) over deployment rollback (minutes). Every flag state change MUST be logged with deployment-grade audit-trail rigor.

## Two-key on hot-fix path (§6.5)

If `emergency: true` and `expires_at:` is in frontmatter, the two-key rule still applies — recorded asynchronously is acceptable, but two distinct individuals must approve before this command promotes to prod. Write the emergency record to `.axis/changes/<id>/emergency-record.md`. Within 24 hours, run retroactive `/axis:specify` and full G1 Approve/G3 Evaluate.

## Output

Produce `.axis/changes/<id>/deployment-record.md` with frontmatter `change_id`, `risk`, `status`, `deployed_at`, and `deploy_sha`, plus one row per environment: timestamp, eval pass rate, threshold, approver, traffic %, and decision. Use `.axis/templates/deployment-record.md` when present; otherwise use `axis-core/templates/deployment-record.md`.
