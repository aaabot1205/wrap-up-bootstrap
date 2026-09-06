# Implementation plan

This roadmap turns the currently usable cross-platform `wrap-up` and `bootstrap` skills into a versioned, verifiable, and portable maintenance system. The existing behavior remains the working baseline while the phases are delivered incrementally.

## Guiding principles

- Keep project documents project-owned and reusable across Codex, Claude Code, and Google Antigravity.
- Preserve backward compatibility until a behavior change is explicitly approved and released as a major version.
- Prefer optional project configuration over mandatory ceremony.
- Treat repository state, commands, tests, and diffs as evidence; never promote assumptions into verified facts.
- Keep installation and updates reversible, idempotent, and non-destructive toward unrelated user configuration.

## Phase 0: Baseline and policy decision

Status: Complete in `1.0.0` on 2026-09-06.

### Goal

Freeze the current working implementation as a recoverable baseline and decide how Git publishing should evolve.

### Deliverables

- Add a `VERSION` file with the current release number.
- Create a Git tag such as `v1.0.0` after the baseline is verified.
- Document the current command contract:
  - `bootstrap` loads project context without editing during context gathering.
  - `wrap-up` reconciles documentation, verifies, commits, and pushes.
  - `wrap-up ncp` reconciles and verifies without staging, committing, or pushing.
- Decide whether a future major release should make `wrap-up` non-publishing by default and reserve Git operations for `wrap-up publish`.

### Acceptance criteria

- All three platforms continue discovering both skills.
- The current behavior is documented and recoverable by version or tag.
- No default Git behavior changes without an explicit decision.

### Outcome

- The Phase 0 commit recorded `VERSION` as `1.0.0`, and Git tag `v1.0.0` identifies that verified baseline.
- The current command contract is documented in `README.md`, `INSTALL.md`, and `DECISIONS.md`.
- Decision D-001 preserves the current publishing behavior throughout `v1.x` and selects the explicit `wrap-up publish` model for `v2.0.0`.
- Phase 3 owns the migration and regression work; no skill behavior changed in Phase 0.

## Phase 1: Automated verification and updates

Status: Complete in the `2.0.0-dev` working version on 2026-09-06; this unreleased work was folded into the Version 2 development line.

### Goal

Make installation health observable and make upgrades repeatable on another Windows machine.

### Deliverables

- Add `verify.ps1` to check:
  - all six installed skill entry files;
  - equality between canonical and installed skill files;
  - exactly one managed response-language block in each global rule file;
  - valid `SKILL.md` frontmatter and required trigger descriptions;
  - platforms that may require a restart.
- Add `update.ps1` to update the repository, back up affected global files, run `install.ps1`, run `verify.ps1`, and report the version transition.
- Add a small manifest or canonical hash set if it materially simplifies verification.

### Acceptance criteria

- Running `install.ps1` twice remains idempotent.
- `verify.ps1` reports all expected installations and rules accurately.
- Updating preserves unrelated skills and global instructions.

### Outcome

- `verify.ps1` validates the version, canonical frontmatter and trigger terms, all six global skill entries, every canonical file hash, exactly one matching managed rule per platform, and restart guidance.
- `update.ps1` refuses dirty, detached, upstream-less, ahead, and divergent states; it fetches and permits only a fast-forward before installation and verification.
- `install.ps1` now reports each timestamped backup and collapses duplicate managed blocks to one canonical block while preserving unrelated content.
- An isolated local-remote fixture verified first-install failure detection, two-run idempotency, fast-forward version transition, changed-file backups, repeated-update idempotency, unrelated-content preservation, corruption detection and repair, and dirty/ahead refusal.

## Phase 2: Optional project context contract

Status: Complete in the `2.0.0-dev` working version on 2026-09-06; this unreleased work was folded into the Version 2 development line.

### Goal

Let large projects identify their authoritative documents and verification commands without making a new file mandatory.

### Deliverables

- Define an optional root-level `PROJECT_CONTEXT.yaml` schema containing, as needed:
  - project name;
  - status, handoff, plan, spec, and decision-document paths;
  - verification commands;
  - default branch and Git publish policy;
  - project-specific cautions or exclusions.
- Add a documented example and schema version.
- Update both skills to prefer `PROJECT_CONTEXT.yaml` when present and retain automatic discovery when absent.

### Acceptance criteria

- Existing projects without `PROJECT_CONTEXT.yaml` continue working unchanged.
- A project started by one supported AI can be bootstrapped and wrapped up by either of the other platforms.
- The receiving platform updates the existing source of truth instead of creating platform-specific duplicates.

### Outcome

- `PROJECT_CONTEXT.schema.json` defines schema version 1, and `PROJECT_CONTEXT.example.yaml` documents every supported field.
- Both skills prefer valid configured document mappings, verification commands, Git policy, cautions, and exclusions while treating them as routing rather than evidence.
- Repository-relative paths may not escape the root, exclusions cannot hide instructions or safety metadata, and branch mismatches never cause automatic branch switching.
- Missing configuration retains automatic discovery unchanged; invalid configuration is reported and falls back where safe.
- Decision D-002 records the contract and the `skill-default`, `explicit`, and `never` publishing semantics.
- Four isolated forward tests covered valid configured bootstrap, absent-config bootstrap, unsupported-version/root-escape fallback, and configured `wrap-up ncp` without replacement documents or Git operations.

## Phase 3: Git publishing safety model

Status: Complete and verified in the `2.0.0-dev` working version on 2026-09-06; release remains separate closeout work.

### Goal

Reduce accidental commits or pushes while keeping closeout convenient.

Phase 0 decision D-001 accepted the following contract for `v2.0.0`. Phase 3 implements it in the Version 2 development line; the tagged `v1.0.0` baseline remains unchanged.

### Command contract

- `bootstrap`: load context.
- `wrap-up`: update documentation and verify, without publishing.
- `wrap-up publish`: update, verify, commit, and push.
- `wrap-up ncp`: retain as a compatibility alias for the non-publishing mode.

### Required safeguards

- Inspect repository, branch, upstream, remote, diff, and staged files before publishing.
- Stage only files belonging to the completed phase.
- Detect likely credentials, secrets, `.env` files, and unrelated changes.
- Do not push when required verification fails unless the user explicitly overrides it.
- Never force-push, discard, reset, or silently include ambiguous user work.

### Migration completed in source

1. Preserve the tagged `v1.0.0` behavior and do not backport the new default to `v1.x`.
2. Move the unreleased Phase 1 and Phase 2 changes directly into `2.0.0-dev`; no `v1.1.0` release or tag was created.
3. Document that Version 1 automation must add `publish` when it intends to commit and push.
4. Require the safeguards and isolated regression coverage before releasing `2.0.0`.

### Acceptance criteria

- The compatibility behavior is unambiguous for every supported command.
- Publishing never includes unrelated or sensitive files.
- A failed publish reports the exact blocker and recovery action.

### Outcome

- Plain `wrap-up` and the `ncp` alias are non-publishing; only a current explicit `publish` instruction enters the Git workflow.
- `PROJECT_CONTEXT.yaml` policies are composed with the command contract: `skill-default` uses the Version 2 default, `explicit` requires current authorization, and `never` requires a direct policy override.
- Publishing inspects repository state and destination, establishes phase-owned paths, scans for sensitive material, requires successful mandatory verification, stages explicit paths only, and rechecks the staged diff before committing.
- Detached HEAD, unresolved merges, ambiguous ownership or destination, sensitive candidates, and failed checks stop publication with an exact blocker and recovery path. Force-push, history rewrite, reset, discard, and broad staging remain forbidden.
- Four isolated forward tests and direct Git-ref assertions verified the default, successful publish, policy-blocked, and failed-verification paths.

## Phase 4: Evidence quality and cross-platform regression tests

### Goal

Prevent multiple AI platforms from consistently propagating the same incorrect project claim.

### Deliverables

- Require closeout records to distinguish:
  - `Verified`: supported by an executed check;
  - `Observed`: directly visible in Git, configuration, or files;
  - `Assumption`: inferred but unverified;
  - `Not run`: expected check not executed;
  - `Blocked`: incomplete, with the reason recorded.
- Maintain isolated takeover fixtures for all six source-to-receiver platform directions.
- Test that each receiver continues the existing status, spec, and handoff files without creating replacements.

### Acceptance criteria

- Unexecuted checks are never reported as passed.
- Contradictory documents are reconciled when evidence is sufficient and called out when it is not.
- All takeover fixtures pass after behavioral changes.

## Phase 5: Cross-operating-system distribution

### Goal

Support repeatable installation beyond the current Windows environment.

### Deliverables

- Add `install.sh`, `verify.sh`, and `update.sh` for macOS and Linux.
- Add `CHANGELOG.md`, release notes, and rollback instructions.
- Publish versioned GitHub releases after validation.
- Confirm path handling for different home directories and existing user configuration.

### Acceptance criteria

- A new Windows, macOS, or Linux machine can install from the private repository with a short documented sequence.
- Reinstallation does not duplicate managed rules or remove unrelated configuration.
- A documented Git tag can be used to roll back.

## Recommended delivery order

1. Preserve the completed `v1.0.0` Phase 0 baseline.
2. Keep the completed Phase 1, Phase 2, and Phase 3 work together in the `2.0.0-dev` line.
3. Add Phase 4 evidence labels and full cross-platform regression coverage.
4. Exercise the Version 2 contract on real projects and resolve any release blockers.
5. Release `v2.0.0` only after final closeout; start Phase 5 when macOS or Linux use becomes concrete.

## Next implementation action

Implement Phase 4 evidence labels and the complete cross-platform takeover regression matrix, then close out the combined Version 2 work for a future `v2.0.0` release.
