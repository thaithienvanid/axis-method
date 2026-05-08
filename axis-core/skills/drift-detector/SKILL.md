---
name: drift-detector
description: Continuous drift detection in the Observe phase — checks whether runtime has diverged from spec or spec has diverged from code. Activate on schedule and after Deploy clears its environment list.
version: 0.0.1
---

# Drift Detector

Drift detection is one of the three orthogonal verification regimes (§8.1) and a hard requirement at Full conformance (§F2).

## Three drift surfaces

| Surface | Question | Detector |
|---|---|---|
| **Runtime ↔ Spec** | Is production behaving as `/specs/<cap>/spec.md` says? | Telemetry fingerprint vs Functional eval expectations |
| **Spec ↔ Code** | Has implementation evolved past the spec? | API surface diff, AST scan, test-name diff |
| **ADR ↔ Code** | Has a previously-decided constraint been silently dropped? | ADR-keyword grep against current code |

## Process

1. Schedule: at least once per Standard-conformance reporting window (default daily).
2. For each capability in `/specs/`:
   - Snapshot runtime telemetry (request-shape histograms, error rates, latency distribution).
   - Re-run the Functional eval suite headlessly against production where safe.
   - Compare against last-known-good fingerprint stored in `.axis/drift/<cap>/baseline.json`.
3. Compare current `git ls-files` for the capability with declared API surface in `spec.md`. Flag added/removed routes, types, and exported symbols.
4. For each ADR under `/docs/adr/`, scan the code for the named constraint; flag silent removal.
5. Emit a drift report at `.axis/drift/<cap>/report-<date>.md`. Severity:
   - INFO — minor drift within tolerance.
   - WARN — drift exceeds tolerance; produce a Specify ticket.
   - SEV-2 — runtime contradicts a MUST principle; alert ARE on-call.

## Feedback loop (§6.1)

Drift findings trigger new Specify entries. Observe is intentionally narrow: drift detection, incident triage, and feeding new Specify triggers (§6.1). Routine ops (capacity planning, security patching) live outside Observe in the implementing org's SRE practice.

## Anti-patterns

- Treating the drift detector as an alert system without a Specify follow-up.
- Letting the baseline fingerprint update silently — every baseline change is a Change.
- Drift on a capability that is `deprecated` or `archived` (§6.6 capability spec lifecycle); skip those.
