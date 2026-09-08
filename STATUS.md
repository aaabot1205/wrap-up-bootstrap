# Status

Last updated: 2026-09-08

## Current state

- The current implementation is usable as the working baseline; planned reliability and portability improvements are documented in `IMPLEMENTATION_PLAN.md`.
- Phase 0 is complete, and tag `v1.0.0` identifies the recoverable `1.0.0` baseline.
- Version `2.1.0` is the current release, identified by annotated tag `v2.1.0`; `v2.0.0` remains the previous release, and the intermediate `v1.1.0` release was not created.
- Version `2.1.0` adds a portable preference requiring a GitHub repository's primary `README.md` to contain complete English and Traditional Chinese versions.
- Phase 1 and Phase 2 are implemented and verified in `2.0.0`, providing automated verification, guarded updates, and the optional project-context contract.
- Phase 3 is implemented and verified in `2.0.0`, activating the accepted explicit-publishing contract.
- Phase 4 is implemented and verified in `2.0.0`, adding evidence-qualified records and the complete six-direction takeover regression matrix.
- The Version 2 release-readiness closeout is complete for the current Windows distribution. No source blocker was found; Phase 5 macOS/Linux distribution remains a deferred post-Version 2 milestone.
- `wrap-up` and `bootstrap` are implemented as portable directory-based `SKILL.md` skills.
- Both skills explicitly preserve cross-platform continuity among ChatGPT/Codex, Claude, Gemini, Antigravity, humans, and other tools.
- `wrap-up` defaults to documentation reconciliation and verification without publishing. `wrap-up publish` enables the safeguarded scoped commit-and-push workflow, and `ncp` remains a non-publishing compatibility alias.
- The canonical source now implements unreleased Plan Fidelity: standalone `plan` preserves an explicitly user-confirmed plan body verbatim, remains non-publishing unless independently combined with `publish`, rejects unconfirmed drafts, and records progress or evidence outside the confirmed body.
- `bootstrap` is read-only during context gathering and can begin a trailing follow-on task afterward.
- `bootstrap` now preserves formal plan identifiers and wording when reporting current and next items.
- Global copies are installed for Codex, Claude Code, and Antigravity.
- The canonical working copy is `C:\dev\wrap-up-bootstrap`; its skill files are synchronized with all three global installations.
- The canonical working copy is a Git repository on branch `main`, tracking the private GitHub remote `https://github.com/aaabot1205/wrap-up-bootstrap.git`.
- Portable source copies of the three response-language and bilingual GitHub README preference files live under `global-rules/`.
- `install.ps1` installs or updates all six global skill copies and all three global rule files on Windows while preserving unrelated content.
- `verify.ps1` checks version syntax, skill frontmatter and trigger descriptions, OpenAI UI metadata, canonical global-preference content, evidence and Plan Fidelity contracts, both six-direction fixture matrices, all global entry files and hashes, managed rules, and restart guidance. `-CanonicalOnly` supports source validation without inspecting installed copies.
- `update.ps1` allows only clean, upstream-backed, non-ahead fast-forward updates before backed-up installation and verification.
- `install.ps1` reports every changed-file backup and repairs duplicate managed rules to one canonical block without removing unrelated content.
- `PROJECT_CONTEXT.schema.json` and `PROJECT_CONTEXT.example.yaml` define repository-relative document routing, verification commands, Git policy, cautions, and exclusions.
- Both skills prefer valid `PROJECT_CONTEXT.yaml` mappings, report invalid configuration, and retain automatic discovery when the file is absent.
- Decision D-001 preserves the tagged Version 1 behavior and now governs the implemented Version 2 default: only a current explicit publish instruction permits Git publication.
- Decision D-003 defines `Verified`, `Observed`, `Assumption`, `Not run`, and `Blocked`; historical checks remain observed evidence until rerun.
- `test-regressions.ps1` validates, prepares, and checks isolated takeover fixtures for every directed pair among Codex, Claude Code, and Antigravity.
- `test-plan-fidelity.ps1` validates, prepares, and checks generic confirmed-source and unconfirmed-only fixtures for the same six directed pairs using source-derived character-for-character comparisons.

## Verification

- Both skill folders passed the Skill Creator `quick_validate.py` validator after the cross-platform clarification.
- The earlier isolated `wrap-up ncp` test reconciled contradictory status, spec, and handoff files without Git operations.
- The earlier isolated `bootstrap` test detected a stale README and authoritative configuration without modifying files.
- A cross-platform takeover test confirmed that `wrap-up ncp` continued ChatGPT/Codex-authored `STATUS.md` and `HANDOFF.md` in place while honoring relevant `CLAUDE.md` guidance; it created no replacement handoff.
- A reciprocal takeover test confirmed that Codex `bootstrap` continued Claude-authored `PROJECT_STATUS.md` and `SEARCH_SPEC.md` without modifying files.
- `install.ps1` passed a two-run isolated-user-root test: six skill entry files were installed, each response-language rule had exactly one managed block, the second run made no file changes, and no unnecessary backups were created.
- Phase 1 live verification reported 18 passes with no warnings or failures against the current global installation.
- Both skill folders passed the Skill Creator validator again after the Phase 1 implementation.
- A Phase 1 isolated local-remote fixture verified a `1.0.0` to `1.0.1-fixture` fast-forward, three changed-skill backups, a clean second update with no new backups, preservation of unrelated global rules and skills, and explicit version reporting.
- Negative fixture checks verified missing-install detection, skill hash and duplicate-block detection, duplicate-block repair, and refusal of both dirty worktrees and unpublished ahead commits without changing the installed files.
- The YAML example passed validation against `PROJECT_CONTEXT.schema.json` with Draft 2020-12, PyYAML, and jsonschema.
- Independent Phase 2 forward tests verified valid configured routing, absent-config discovery fallback, explicit reporting and fallback for schema version 99 plus a root-escaping path, and configured `wrap-up ncp` updates to existing documents only.
- The configured wrap-up fixture ran its declared verification command, changed only its three mapped documents, created no replacement `STATUS.md` or `HANDOFF.md`, and performed no Git operations.
- All six updated global skill copies were synchronized with timestamped backups; final live verification reported 19 passes with no warnings or failures.
- Phase 3 Skill Creator validation passed for both skills, and an isolated installation passed all 21 verifier checks.
- Four independent Phase 3 forward tests covered the non-publishing default, a successful explicit publish, a `publish_policy: never` blocker with an untouched `.env`, and a mandatory-verification failure without an override.
- Direct Git assertions confirmed that default and blocked fixtures did not stage, commit, or move remote refs; the successful fixture committed exactly `docs/HANDOFF.md`, `docs/STATUS.md`, and `src/result.txt` and synchronized `main` with its upstream.
- Phase 3 global synchronization created timestamped backups for each changed wrap-up skill and metadata file at `20260906-110734`; final live verification reported 21 passes with no warnings or failures.
- Phase 4's untouched baseline was rejected before forward testing, proving that the post-run checker does not accept fixture setup as a pass.
- Six fresh-agent Phase 4 forward tests passed all Codex, Claude Code, and Antigravity source-to-receiver directions. Every receiver changed exactly the existing status, spec, and handoff files, ran the documented local check, created no replacement, and performed no Git publication.
- The final regression runner reported 6 passes and no failures; a separate smoke run prepared six clean one-commit repositories from the shared templates.
- An isolated Phase 4 installation passed all 22 verifier checks. Global synchronization backed up all changed skill and metadata files at `20260906-125758` before updating the six installations.
- Re-run validation and cross-installation hash checks after every skill change.

## Latest closeout

- Date: 2026-09-07
- `Observed`: after the requested Codex smoke test passed, the user explicitly authorized `wrap-up publish 2.1.0 release`. The authorized release scope is `VERSION`, `README.md`, `STATUS.md`, `HANDOFF.md`, and `IMPLEMENTATION_PLAN.md`, followed by an annotated `v2.1.0` tag and pushes to `origin`.
- `Observed`: after `git fetch origin`, local `main` and `origin/main` both remained at `34b9c5a` with a clean worktree; no merge or rebase was active, and `v2.1.0` did not yet exist before release preparation.
- `Verified`: a new Codex task in an isolated Codex worktree received an English-only request to materially improve the primary README without any bilingual instruction. It modified only `README.md`, added a complete English section followed by a complete Traditional Chinese counterpart, kept commands and technical identifiers aligned, passed `git diff --check -- README.md`, and made no commit, tag, or push.
- `Verified`: the isolated worktree verifier's 15 global-install mismatches were byte-level checkout line-ending differences, not damaged global rules. Representative canonical skill, metadata, and global-rule files had no difference under `git diff --no-index --ignore-space-at-eol`; the smoke task's Git scope contained only `README.md`, and the canonical live verifier passed all 23 checks with no warnings or failures.
- `Verified`: `VERSION` is `2.1.0`; the Skill Creator validator accepted both skills; all four PowerShell scripts passed AST parsing; `PROJECT_CONTEXT.example.yaml` passed Draft 2020-12 schema validation; `test-regressions.ps1 -Mode Validate` accepted all six directed fixtures; the README structural parity check passed; and `git diff --check` passed.
- `Verified`: a fresh isolated user root completed two `install.ps1` runs without any second-run file, hash, or timestamp change, then passed all 23 isolated verifier checks. The one-time script and temporary root were removed afterward.
- `Observed`: the earlier isolated updater fixture remains historical evidence because updater behavior did not change for this release-only version and documentation update.
- `Not run`: the Claude Code 2.1.221 behavior observation remains explicitly deferred as low priority; the six fresh-agent takeover workflows were not repeated because no skill, evidence, or takeover behavior changed.
- `Blocked`: none for the explicitly authorized `2.1.0` release commit, annotated tag, and pushes.

## Remaining work

- Review the unreleased Plan Fidelity diff. Global installation, commit, tag, and push require separate explicit approval.
- Phase 5: add macOS/Linux distribution when there is a concrete need.
- Observe the `v2.1.0` release in normal use. Antigravity IDE and Codex have passed isolated behavior checks; Claude Code remains explicitly deferred as low priority.
- Recheck official platform discovery and disable locations when any host changes its skill specification.

## Plan Fidelity development closeout

- Date: 2026-09-08
- `Observed`: the canonical repository started clean at `c1d1a1d` (`v2.1.0`) on `main`; the user subsequently authorized global installation and `wrap-up publish` for this change.
- `Verified`: both canonical skills passed Skill Creator `quick_validate.py` using the already cached PyYAML runtime; all five PowerShell scripts passed AST parsing.
- `Verified`: `verify.ps1 -CanonicalOnly` reported 8 passes, no warnings, and no failures; `test-regressions.ps1 -Mode Validate` retained all six takeover fixtures; `test-plan-fidelity.ps1 -Mode Validate` accepted all six Plan Fidelity fixtures.
- `Verified`: six fresh-agent receiver-contract workflows passed `test-plan-fidelity.ps1 -Mode Check`: all three confirmed-source cases matched their source body character-for-character, all three unconfirmed-only cases left the plan body unchanged and recorded `Blocked`, no case copied the draft sentinel, and every case remained unstaged and uncommitted.
- `Verified`: each fixture's documented `verify.ps1` ran successfully; the aggregate checker reported 6 passes and 0 failures.
- `Verified`: a separate read-only fresh bootstrap observation reported the formal `Post-2.1: Plan Fidelity mode` and `Phase 5: Cross-operating-system distribution` headings and their exact plan wording instead of substituting summaries; it also detected a stale next-action sentence, which was corrected in place without changing either plan item.
- `Verified`: `install.ps1` globally installed the canonical skills for Codex, Claude Code, and Antigravity after creating `20260908-124457` backups of every changed installed skill or metadata file.
- `Verified`: live `verify.ps1` reported 23 passes, no warnings, and no failures; separate SHA256 comparison confirmed all six installed `SKILL.md` files match their canonical sources.
- `Not run`: new host-native Claude Code and Antigravity sessions were not started after installation; the portable six-direction fixture behavior remains the current forward-test evidence.
- `Observed`: the authorized publication scope is the 29 Plan Fidelity implementation, fixture, verifier, instruction, and documentation files in the current worktree. No version bump or tag was requested.
- `Blocked`: none for the authorized scoped commit and push to `main`/`origin`.
