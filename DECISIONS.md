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

## D-006: Handoff hygiene and reconciliation clarifications

- Status: Accepted
- Date: 2026-09-09
- Released in: `2.3.0` on 2026-09-09

### Decision

- Plan Fidelity requires a short provenance preface before a confirmed-plan body whenever the canonical plan document is new or does not yet record its source: confirmation source, confirmation date, and the executing session's platform or model if known, separated from the body by a clear boundary. The preface is never part of the immutable body and is never edited to narrate progress.
- `wrap-up` may condense a historical closeout entry to one dated summary line once it no longer informs an open decision, blocker, or the next action. Verbatim detail is kept only for entries a current decision or acceptance record still depends on; this does not authorize summarizing specs or performing broad cosmetic rewrites.
- `bootstrap` treats a hardcoded environment-specific literal (a file path, username, hostname, or similar) that no longer matches the observed environment as its own conflict subtype, distinct from a document-versus-document contradiction, resolved the same way (observed state wins) and flagged for correction at the next `wrap-up`.

### Rationale

Both gaps were found through direct dogfooding rather than speculation: this repository's own `HANDOFF.md` had accumulated unpruned historical closeouts, and its "Installed global copies" section hardcoded a literal username that did not match the machine actually running the installed skills. Plan Fidelity's verbatim-body rule left no documented way to attach provenance without an agent inventing its own convention.

### Consequences

- Existing Plan Fidelity, publishing, and evidence-labeling behavior is unchanged; this only adds a preface convention and a narrow pruning allowance.
- `HANDOFF.md`'s "Installed global copies" section is now machine-agnostic; no future installation needs to edit that wording.
- Both skills' six-direction fixture matrices must still pass after this change, since it touches reconciliation and Plan Fidelity behavior in both skills.

## D-007: Isolated `update.ps1` dry-run replaces the live post-release verification ritual

- Status: Accepted
- Date: 2026-09-09

### Decision

- Add `test-update.ps1` as a self-contained, isolated regression for `update.ps1`: it builds a bare-repo origin seeded at the most recent prior release tag, an isolated client clone, and an isolated user root pre-seeded with that old release, advances the bare origin to `HEAD`, then runs the client's own `update.ps1` and asserts version-transition reporting, backup creation, installed-file hashes against canonical, and refusal on both a dirty worktree and an ahead-of-upstream branch.
- Treat a passing `test-update.ps1` run as sufficient evidence that a release's upgrade path works. A live `update.ps1` run against a real global installation is no longer required to support that claim, and must not be treated as an open item in `HANDOFF.md`'s "Next action" once the isolated regression has passed.
- Do not bump `VERSION` for changes that add or modify test scripts alone: `install.ps1` never installs anything outside `wrap-up/` and `bootstrap/`, so a test-only change has no effect on what any global installation actually receives.

### Rationale

The `v2.3.0` release surfaced the problem directly: `update.ps1` refuses to run unless the local branch is synced with `origin`, so verifying the upgrade path could only happen after pushing a real release. Recording that live verification afterward in `HANDOFF.md` produced exactly the kind of stale, easy-to-forget "Next action" that Decision D-006 was partly written to stop recurring (the same pattern as the Antigravity-restart item this project already had to resolve once). `test-installation.ps1` isolates `install.ps1` but never exercises `update.ps1`'s own git-safety logic, so that logic had no automated coverage at all before this decision, despite `AGENTS.md` already describing the manual version of this exact check.

### Consequences

- Verifying an upgrade path becomes a normal pre-push check, like the other three `test-*.ps1` scripts, instead of a post-push manual ritual.
- Future releases that do not touch `install.ps1`/`update.ps1` do not need to rerun `test-update.ps1`, matching the existing rule for `test-installation.ps1`.
- `test-update.ps1` depends on the canonical repo already having at least one prior release tag reachable from `HEAD`; it has no effect on, and is not run by, `install.ps1` or `update.ps1` themselves.
