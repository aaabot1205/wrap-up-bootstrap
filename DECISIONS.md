# Decisions

## D-001: Version 1 publishing contract and Version 2 direction

- Status: Accepted
- Date: 2026-09-06
- Baseline: `1.0.0`

### Decision

- Preserve the current `v1.x` command contract:
  - `bootstrap` gathers project context without editing during the bootstrap phase and may then begin a supplied follow-on task.
  - `wrap-up` reconciles documentation, verifies the completed phase, stages scoped changes, commits, and pushes.
  - `wrap-up ncp` reconciles documentation and verifies without staging, committing, or pushing.
- Target the safer explicit publishing contract for `v2.0.0`:
  - `wrap-up` will reconcile documentation and verify without publishing.
  - `wrap-up publish` will perform the scoped commit and push workflow.
  - `wrap-up ncp` will remain a compatibility alias for the non-publishing mode.
- Implement the Version 2 behavior only through the Phase 3 migration. Do not change the `v1.x` default silently or backport the new default to a minor release.

### Rationale

Publishing is consequential and is safer when explicitly requested. Keeping the current contract throughout `v1.x` avoids breaking existing automation and user expectations while leaving a clear major-version migration path.

### Consequences

- The `1.0.0` baseline remains behaviorally identical to the implementation verified before this decision.
- Documentation and tests must state the active major-version contract unambiguously.
- Phase 3 must add migration guidance and regression coverage before releasing `2.0.0`.
