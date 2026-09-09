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

Status: Complete and released in `2.0.0` on 2026-09-06.

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

Status: Complete and released in `2.0.0` on 2026-09-06.

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

Status: Complete, verified, and released in `2.0.0` on 2026-09-06.

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

Status: Complete, verified, and released in `2.0.0` on 2026-09-06.

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

### Outcome

- Both skills use the exact `Verified`, `Observed`, `Assumption`, `Not run`, and `Blocked` labels for material claims and prevent historical passes or narrow checks from being promoted beyond their evidence.
- Decision D-003 records the evidence semantics and requires unresolved contradictions to remain visible when current evidence cannot resolve them.
- `test-regressions.ps1` validates the canonical matrix, prepares fresh one-commit Git workspaces, and checks evidence, reconciliation, document reuse, and non-publishing behavior.
- Shared raw templates plus six manifests cover every directed takeover among Codex, Claude Code, and Antigravity without duplicating fixture content.
- Six fresh-agent forward tests passed. Each receiver updated exactly the existing status, spec, and handoff documents, executed the local check, created no replacement files, and left Git unstaged and uncommitted.

## Version 2.1: Bilingual GitHub README global preference

Status: Complete, verified, and released in `2.1.0` on 2026-09-07.

### Goal

Extend the portable global preferences beyond response language so GitHub repositories receive a complete English README followed by a complete Traditional Chinese version.

### Deliverables

- Add the bilingual README requirement to the existing managed global rule files for Codex, Claude Code, and Antigravity.
- Preserve the historical managed-marker identifier so existing installations upgrade in place instead of receiving a second block.
- Extend `verify.ps1` to require aligned canonical global rule files containing both preferences.
- Document that existing global instruction content remains untouched outside the managed block.
- Forward-test `update.ps1` from an installed `2.0.0` fixture to `2.1.0-dev`.

### Acceptance criteria

- The three canonical global rule files are identical and require both Traditional Chinese responses and bilingual GitHub READMEs.
- Updating an existing installation preserves unrelated `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` content, replaces exactly one managed block, and creates backups before changes.
- A second update is idempotent and creates no additional backups.
- The live installation and all relevant repository checks pass.

### Outcome

- The repository README preserves its complete English content and adds a complete Traditional Chinese version below it.
- `install.ps1` continues to append or replace only its marker-delimited block, while user-facing output and documentation now describe the broader global preferences accurately.
- `verify.ps1` validates the required canonical preference content before checking each installed managed block.
- An isolated upstream/client fixture passed the `2.0.0` to `2.1.0-dev` fast-forward, unrelated-content preservation, backup, verifier, and second-run idempotency checks.
- An Antigravity IDE 1.107.0 session passed an isolated behavior observation by producing a complete English-first, Traditional-Chinese-second README from an English-only prompt. The user deferred the unauthenticated Claude Code observation as low priority.
- A new Codex task in an isolated worktree received an English-only README improvement request with no bilingual instruction and updated only `README.md`, adding a complete English section followed by its complete Traditional Chinese counterpart with aligned commands and technical identifiers.

## Phase 5: Cross-operating-system distribution

Status: Deferred until there is concrete macOS or Linux demand; not a blocker for the Windows-scoped `v2.2.1` release.

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

## Version 2.2: Plan Fidelity mode

Status: Complete, verified, globally installed, and released in `2.2.0` on 2026-09-08.

### Goal

Allow an explicitly requested closeout to preserve a user-confirmed plan exactly without coupling that behavior to Git publishing.

### Deliverables

- Add standalone, case-insensitive `plan` parsing while preserving the existing default, `publish`, and `ncp` contracts.
- Select the configured or existing canonical plan document and preserve the latest explicitly user-confirmed exact plan body verbatim.
- Keep progress, verification evidence, and status changes outside the confirmed-plan body; block when exact source text is unavailable or only an unconfirmed proposal exists.
- Make bootstrap retain formal plan identifiers and wording when it reports current and next items.
- Add generic confirmed-source and unconfirmed-only regression fixtures for all six directed platform pairs.

### Acceptance criteria

- `wrap-up plan` is non-publishing, and `wrap-up plan publish` composes independent Plan Fidelity and publish flags.
- The canonical plan body matches the confirmed source character-for-character across arbitrary wording, language, numbering, hierarchy, owners, dependencies, and acceptance criteria.
- Unconfirmed AI draft content is never copied, and unavailable exact source text produces a recorded `Blocked` result without modifying the plan body.
- Canonical validation, existing takeover regression validation, all six Plan Fidelity forward tests, the canonical verifier, and `git diff --check` pass before installation or release.

### Outcome

- `wrap-up/SKILL.md`, `bootstrap/SKILL.md`, OpenAI metadata, documentation, verifier coverage, and the Plan Fidelity regression system implement the accepted D-004 contract.
- `test-plan-fidelity.ps1` derives expected text from fixture sources and checks exact plan-body equality, draft rejection, separate evidence records, existing-document reuse, and non-publishing Git state.
- All six fresh-agent receiver-contract fixtures passed: three confirmed-source cases matched character-for-character, and three unconfirmed-only cases preserved the baseline body and recorded blockers.
- Global installation passed live verification. Commit `7a36d71` published the implementation, and the `2.2.0` release records the feature with annotated tag `v2.2.0`.

## Version 2.2.1: Antigravity global discovery correction

Status: Complete, verified, globally installed, and released in `2.2.1` on 2026-09-09.

### Goal

Install the skills where current Antigravity global discovery loads them while retaining compatibility with older Antigravity installations.

### Deliverables

- Install both skills into current `~/.gemini/config/skills/` and legacy `~/.gemini/antigravity/skills/` roots.
- Verify both Antigravity roots independently and continue preserving unrelated global skills and rules.
- Add an isolated installation regression whose expected Antigravity paths are independent of installer routing.
- Update installation, disable, maintenance, status, handoff, and release documentation.

### Acceptance criteria

- A pre-install live verifier fails when only legacy Antigravity copies exist.
- An isolated installation populates both roots, matches canonical hashes, preserves unrelated skills, backs up changed managed files, passes verification, and is unchanged on its second run.
- Live global installation produces matching current and legacy copies and passes the complete verifier.
- Both Skill Creator validations, PowerShell parsing, applicable regression validators, bilingual README parity, and `git diff --check` pass before release.

### Outcome

- The corrected verifier reproduced the original gap with six missing current-path files before installation, while the isolated installation regression passed the full new contract.
- A clean isolated `2.2.0` client fast-forwarded through `update.ps1` to the `2.2.1` candidate, installed the current Antigravity copies without changing an unrelated skill, reported the version transition, and passed verification.
- Global installation populated all eight current and compatibility skill copies. Live verification reported 27 passes with no warnings or failures, all eight `SKILL.md` hashes match canonical sources, and a second live installation changed no managed file, hash, or timestamp.
- A restarted or new Antigravity session remains the first post-release runtime observation because already-running sessions cache their skill inventory.

## Recommended delivery order

1. Preserve the completed `v1.0.0` Phase 0 baseline.
2. Preserve annotated tag `v2.0.0` as the Version 2 release point containing the completed Phase 1 through Phase 4 work.
3. Preserve annotated tag `v2.1.0` as the bilingual GitHub README global-preference release point and observe it in normal use.
4. Preserve annotated tag `v2.2.0` as the Plan Fidelity release point after its canonical and cross-platform checks passed.
5. Preserve annotated tag `v2.2.1` as the Antigravity global discovery correction after isolated and live installation checks passed.
6. Start Phase 5 when macOS or Linux use becomes concrete.

## Next implementation action

Confirm `wrap-up` and `bootstrap` in a restarted or new Antigravity session, and start Phase 5 only when macOS or Linux distribution has a concrete user need.
