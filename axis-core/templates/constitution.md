# Constitution
Version: 0.0.1 | Status: Active | Conforms to: AXIS-26 v0.0.1

## Principles

This Constitution declares the seven principles required by AXIS-26 §4.1.

1. **Spec is canonical; code is derived.**
2. **Verification is the budget; building is cheap.**
3. **Risk routes rigor.** Three risk levels, not uniform ceremony.
4. **Brownfield is default; deltas are first-class.**
5. **Tool-portable; vendor-replaceable; model-fungible.**
6. **Skills are versioned IP, audited as code.**
7. **Security and accessibility are constitutional, not features.**

## MUST (constitutional, non-negotiable — block G2 Validate on violation)

1. Validate all user input at trust boundaries.
2. Never log secrets, PII, or auth tokens.
3. All HTTP endpoints authenticate; exceptions require Security ADR.
4. Deployments use canary or blue/green; never instant 100% rollout.
5. Parameterized queries only; no string-built SQL.
6. Output encoding at template boundaries.
7. No hard-coded credentials; secrets via secret manager.

## SHOULD (strong default — exceptions require ADR)

1. New code covered by behavior evals before G3 Evaluate.
2. PRs ≤300 lines net change; functions ≤50 lines; files ≤300 lines.
3. Public APIs version-pinned and contract-tested.
4. LLM-judge rubrics κ-validated against humans quarterly.

## MAY (style, agent freedom)

- Choice of test framework within stack norms.
- Choice of internal helper structure.
- Local file organization beneath the source-tree convention.

## CWE Top 25 Mappings

§4.1 principle 7 requires "at minimum a subset of the CWE/MITRE Top 25" mapped to project-local enforcement rules. The 12 entries below are a **starter subset** — implementations MUST extend toward the full 25 (see `cwe-scanner` skill for the full list) and document any unreachable exclusions in a Security ADR.

| CWE | Constraint | Enforcement |
|---|---|---|
| CWE-89 SQL Injection | Parameterized queries only | `.axis/cwe/sql-injection.yaml` |
| CWE-79 XSS | Output encoding at template boundary | `.axis/cwe/xss.yaml` |
| CWE-22 Path Traversal | Reject `..` and absolute paths from user input | `.axis/cwe/path-traversal.yaml` |
| CWE-78 OS Command Injection | No shell interpolation of user input | `.axis/cwe/command-injection.yaml` |
| CWE-200 Sensitive Info Exposure | PII redactor middleware on all logs | `.axis/cwe/pii-exposure.yaml` |
| CWE-287 Improper Authentication | Centralized authn middleware required | `.axis/cwe/authn-improper.yaml` |
| CWE-352 CSRF | Anti-CSRF token on every state-changing form | `.axis/cwe/csrf.yaml` |
| CWE-434 Unrestricted Upload | Allowlist by content-type and signature | `.axis/cwe/upload-restrict.yaml` |
| CWE-502 Insecure Deserialization | No `pickle` / `unserialize` on untrusted bytes | `.axis/cwe/deserialize.yaml` |
| CWE-798 Hard-coded Credentials | Secret-scan pre-commit hook | `.axis/cwe/hardcoded-secret.yaml` |
| CWE-918 SSRF | Egress allowlist for outbound HTTP | `.axis/cwe/ssrf.yaml` |
| CWE-862 Missing Authorization | Authz check on every protected handler | `.axis/cwe/authz-missing.yaml` |

At risk high, §8.2 requires the full CWE Top 25 to be clear at G3 Evaluate. Either extend this table to all 25 entries reachable in your threat model or document each exclusion in a Security ADR.

## WCAG 2.2 AA Mappings

| Criterion | Constraint | Enforcement |
|---|---|---|
| 1.1.1 Non-text Content | Alt text required on all `<img>` | `.axis/wcag/alt-text.yaml` |
| 1.4.3 Contrast (Minimum) | Computed contrast ≥ 4.5:1 | axe-core in CI |
| 2.1.1 Keyboard | All interactive surfaces keyboard reachable | axe-core in CI |
| 2.4.7 Focus Visible | Visible focus indicator on all interactive elements | axe-core in CI |
| 3.3.1 Error Identification | Inline errors with descriptive text | manual review |
| 4.1.2 Name, Role, Value | ARIA labels on custom controls | axe-core in CI |

## Amendment Process

Amendments require an ADR. Versioning (§4.3): MUST changes → MAJOR; SHOULD additions → MINOR; editorial → PATCH. Constitution Reviews occur at least quarterly at Standard conformance and above.

## Amendment Log

- 2026-05-08 v0.0.1 — Initial Constitution. ADR-0001.
