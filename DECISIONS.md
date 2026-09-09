# Decisions

## D-001: Version 1 publishing contract and Version 2 direction

- Status: Accepted
- Date: 2026-09-06
- Baseline: `1.0.0`
- Released in: `2.0.0` on 2026-09-06

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
- The Phase 1 and Phase 2 work was folded into the Version 2 development line and released in `2.0.0`; no `v1.1.0` tag was created.
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
- Released in: `2.0.0`

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

## D-004: Plan Fidelity is independent from publishing

- Status: Accepted
- Date: 2026-09-08
- Released in: `2.2.0` on 2026-09-08

### Decision

- Treat a standalone, case-insensitive `plan` token as Plan Fidelity and remove it from additional user instructions.
- Keep Plan Fidelity independent from publishing: `wrap-up plan` is non-publishing, while `wrap-up plan publish` composes verbatim plan preservation with the existing safeguarded publish workflow.
- In Plan Fidelity, use the configured plan path when valid, otherwise update the existing canonical plan document in place, falling back to root-level `IMPLEMENTATION_PLAN.md` only when no convention exists.
- Copy only the latest plan whose exact text the user explicitly confirmed. Preserve its complete body character-for-character and never summarize, paraphrase, merge, split, renumber, reorder, reformat, complete, or supplement it.
- Keep progress, verification evidence, and status outside the confirmed-plan body. Treat unconfirmed AI drafts as ineligible sources.
- When exact confirmed text or canonical ownership cannot be established, report `Blocked` and leave the plan body unchanged rather than reconstructing it.
- Bootstrap must retain formal plan identifiers and wording, and must use those identifiers when reporting current and next items.

### Consequences

- Existing `wrap-up`, `wrap-up publish`, and `wrap-up ncp` behavior remains unchanged.
- Plan Fidelity fixtures derive expected content from generic source artifacts instead of embedding a real plan in the checker.
- Canonical-only development can run `verify.ps1 -CanonicalOnly`; installed copies remain intentionally stale until a separately authorized installation.

## D-005: Use Antigravity's current global discovery root with legacy compatibility

- Status: Accepted
- Date: 2026-09-09
- Released in: `2.2.1` on 2026-09-09

### Decision

- Install Antigravity skills into the current global discovery root `~/.gemini/config/skills/`.
- Continue synchronizing `~/.gemini/antigravity/skills/` as a legacy compatibility path without deleting existing files or unrelated skills.
- Verify both Antigravity roots independently so a current installation cannot pass solely because installer and verifier agree on the legacy path.
- Maintain an isolated installation regression that asserts the current path as an external contract, checks both roots and canonical hashes, preserves unrelated skills, exercises backups, and verifies second-run idempotency.

### Consequences

- Current Antigravity sessions can discover `wrap-up` and `bootstrap` from the documented global customization root after restart or a new session.
- Older Antigravity builds retain their installed compatibility copies.
- The Windows installer now maintains eight skill copies across three platforms and two Antigravity discovery generations.
