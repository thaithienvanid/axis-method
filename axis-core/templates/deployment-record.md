---
# Replace placeholder values before committing. Schema: AXIS-26 Appendix A.7.
change_id: 2026-05-001-example
risk: moderate
status: live
deployed_at: 2026-05-08T00:00:00Z
deploy_sha: "0000000000000000000000000000000000000000"  # 40-char Git SHA of the deployed commit (REQUIRED)
environments: [staging, prod]
final_environment: prod
rollback_runbook: "ADR-0000-rollback"  # ADR or runbook URL
---

# Deployment Record

## Environment Promotions

| Timestamp | Environment | Eval pass rate | Threshold | Approver | Traffic % | Decision |
|---|---|---:|---:|---|---:|---|
| 2026-05-08T00:00:00Z | staging | 0.99 | 0.98 | auto | 100 | pass |

## Notes

[Deployment notes, rollback links, feature-flag changes, or CI/CD run links.]
