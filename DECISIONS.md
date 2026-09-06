# Decisions

## D-001: Version 1 publishing contract and Version 2 direction

- Status: Accepted
- Date: 2026-09-06
- Baseline: `1.0.0`
- Implemented in source: `2.0.0-dev` on 2026-09-06

### Decision

- Preserve the current `v1.x` command contract:
  - `bootstrap` gathers project context without editing during the bootstrap phase and may then begin a supplied follow-on task.
  - `wrap-up` reconciles documentation, verifies the completed phase, stages scoped changes, commits, and pushes.
  - `wrap-up ncp` reconciles documentation and verifies without staging, committing, or pushing.
- Use the safer explicit publishing contract beginning with the Version 2 development line:
  - `wrap-up` reconciles documentation and verifies without publishing.
  - `wrap-up publish` performs the safeguarded scoped commit and push workflow.
  - `wrap-up ncp` remains a compatibility alias for the non-publishing mode.
- Implement the Version 2 behavior only through the Phase 3 migration. Do not change the `v1.x` default silently or backport the new default to a minor release.

### Rationale

Publishing is consequential and is safer when explicitly requested. Keeping the current contract throughout `v1.x` avoids breaking existing automation and user expectations while leaving a clear major-version migration path.

### Consequences

- The `1.0.0` baseline remains behaviorally identical to the implementation verified before this decision.
- Documentation and tests must state the active major-version contract unambiguously.
- The unreleased Phase 1 and Phase 2 work is folded into `2.0.0-dev`; no `v1.1.0` tag was created.
- Version 1 automation that expects publication must add the standalone `publish` argument when migrating to Version 2.
- Phase 3 adds pre-publish repository, scope, secret, verification, and destination checks; a blocker must be reported with a recovery action before any retry.

## D-002: Optional project context contract

- Status: Accepted
- Date: 2026-09-06
- Schema version: `1`

### Decision

- A repository may provide one optional root-level `PROJECT_CONTEXT.yaml` using `PROJECT_CONTEXT.schema.json`.
- All configured document paths and exclusion patterns are repository-relative. Document paths must remain within the repository root.
- Document roles use arrays so an existing project may identify more than one authoritative status, handoff, plan, spec, or decision artifact.
- Configured verification commands run from the repository root when relevant and safe.
- `git.publish_policy` accepts:
  - `skill-default`: follow the active skill version's normal publishing contract;
  - `explicit`: require a current explicit publish instruction before Git operations;
  - `never`: prohibit automatic publishing unless the user's current instruction explicitly overrides it.
- A valid contract is routing and policy context, not evidence that work is implemented or verified.
- If the file is absent, both skills retain automatic discovery unchanged. If it is invalid, they report the exact issue and fall back where safe instead of silently ignoring it or creating replacement documents.

### Consequences

- Projects can identify their source-of-truth documents without introducing platform-specific handoffs.
- Existing projects require no migration.
- Skills must never allow exclusions to hide applicable instructions, Git safety metadata, or explicitly configured documents.

## D-003: Evidence labels and directed takeover regression matrix

- Status: Accepted
- Date: 2026-09-06
- Implemented in source: `2.0.0-dev`

### Decision

- Use five exact evidence labels in material bootstrap briefs and closeout records:
  - `Verified`: supported by a check executed in the current session;
  - `Observed`: directly inspected current state;
  - `Assumption`: an inference with a stated confirmation method;
  - `Not run`: an expected check not executed, with the reason;
  - `Blocked`: incomplete work or verification, with the blocker and recovery action.
- Treat a previous session's recorded pass as historical `Observed` evidence until rerun. Never let a narrow check verify claims outside its actual scope.
- Preserve unresolved contradictions as competing labeled claims when current evidence cannot resolve them.
- Maintain one isolated fixture for every directed receiver pair among Codex, Claude Code, and Antigravity: six directions in total.
- Require receivers to update the existing status, spec, and handoff files in place, run the documented local check, avoid replacement documents, and leave Git unpublished under plain `wrap-up`.

### Consequences

- Handoffs expose verification gaps instead of allowing repeated AI sessions to amplify an unsupported claim.
- `test-regressions.ps1` provides deterministic fixture validation, isolated workspace preparation, and post-run checks; fresh receiving agents still perform the behavioral portion.
- Any evidence or cross-platform continuity behavior change must pass all six directions before release.
