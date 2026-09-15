# Handoff

## Purpose

Maintain two AI-platform-neutral skills that make end-of-phase documentation and new-session takeover reliable across Codex, Claude Code, and Google Antigravity.

## Current state

Version `2.5.0` (2026-09-15): both skills require an explicit user invocation by name (D-008). This release contains native Codex and Claude Code settings, common instruction guards, configuration validation, and Skill Creator compatibility validation. The user explicitly invoked `wrap-up publish tag v2.5.0`; no bootstrap was invoked. Publication consists of one scoped commit on `main` and annotated tag `v2.5.0`; inspect the Git refs for delivery state.

Observed: global synchronization created 16 file backups stamped `20260915-124154`; all eight installed skill entries contain the `2.5.0` correction. Reload host skill discovery before testing explicit commands and ordinary continuation. Configuration and installation checks do not prove native automatic-selection behavior.

Verified: isolated invocation policy validation rejected all 12 malformed or permissive variants; installation, package validation, and the six-direction takeover definition validator passed. Observed: an earlier Codex native app-server `skills/list` accepted both installed entries with `enabled: true` and no target loader error, and the current session's refreshed automatic skill catalog excludes them. No workflow was executed for that loader check.

Verified: `test-skill-validation.py` validates the required host fields and passes temporary standard-content projections to the unmodified Skill Creator validator. Both skills passed, all 12 invalid variants were rejected, and original source hashes stayed unchanged. The raw external validator still rejects the Claude extension; this compatibility check resolves that tooling mismatch without altering installed skill contents or claiming a raw validator pass.

Verified: release checks passed for `2.5.0`: live verifier 27/0/0, isolated installation, invocation policy regression, packaging, both six-direction fixture definition validators, syntax and whitespace checks. An isolated committed candidate passed the real `v2.4.0 -> 2.5.0` updater regression with unchanged-version rerun, backups, hashes, and dirty/ahead refusal. The final committed HEAD is checked before publication; Git refs determine delivery state.

Blocked: Antigravity loader enforcement has no confirmed setting; its instruction-level guard is not a substitute for native enforcement. Not run: fresh explicit workflow execution, Claude Code/Antigravity native selection, and six-direction behavioral replay. These remain limitations of the release, not claims of runtime success. Review: fixed point `a421c2edd490d66438be5df41d92857baaae881f`; all 16 release files, including the two new validators and uncommitted changes, are in scope. See STATUS.md for the exact path list.

The following updater closeout is historical. Its `origin/main` equality with `v2.4.0` applied at release time; `main` subsequently advanced to updater fix `a421c2e`.

Current follow-up (2026-09-14): Version `2.4.0` is published. A small updater-message change replaces the misleading same-version transition with `Version unchanged` and adds a same-version rerun to the canonical updater regression. The user authorized `wrap-up publish` for the exact six-file follow-up scope on `main`; `VERSION` and tag `v2.4.0` remain unchanged.

`Verified`: release commit `eb70e01`, `origin/main`, and peeled annotated tag `v2.4.0` resolve to the same commit. For the follow-up, a temporary committed clone passed the full updater regression: real `2.3.0 -> 2.4.0` transition, clear unchanged-version rerun, backups, installed hashes, and dirty/ahead refusal.

Historical release `2.4.0` substantially improved fresh-session continuity, gap-driven reading, conditional skill packaging, evidence-qualified handoff, and isolated safety coverage. It remains fixed at tag `v2.4.0` as the baseline before `2.5.0`.

Since that release, Decision D-007 added `test-update.ps1`: an isolated dry-run regression for `update.ps1` (bare-repo origin, client, and user root, all disposable). It is a canonical-repo improvement, not a release -- `VERSION` was not bumped, because `install.ps1` never installs test scripts anywhere.

Phase 0 is complete, and Git tag `v1.0.0` identifies the recoverable `1.0.0` baseline. Decision D-001 preserves the Version 1 behavior and governs the released Version 2 publishing contract: plain `wrap-up` is non-publishing, `wrap-up publish` is explicit publication authorization, and `ncp` remains a non-publishing compatibility alias.

Phase 1 is released in `2.0.0`. `verify.ps1` checks all installations, hashes, managed rules, frontmatter, trigger descriptions, OpenAI UI metadata, and restart guidance. `update.ps1` refuses dirty, detached, upstream-less, ahead, or divergent state; it fetches and fast-forwards only, then installs and verifies. It reports a transition when the version changes and `Version unchanged` when it does not. `install.ps1` reports timestamped backups and repairs duplicate managed blocks while preserving unrelated content.

Phase 2 is also released in `2.0.0`. The optional root-level `PROJECT_CONTEXT.yaml` Version 1 contract can route status, handoff, plan, spec, and decision documents; declare verification commands, default branch, publishing policy, cautions, and exclusions; and preserve discovery fallback when absent. Decision D-002 and the schema define path-safety, invalid-config, exclusion, and `skill-default`/`explicit`/`never` semantics. The intermediate `v1.1.0` release was not created; its planned work was folded into Version 2.

Phase 3 is released in `2.0.0`. Publishing now requires inspection of repository state and destination, positive phase-owned file scope, sensitive-material review, successful mandatory checks, explicit-path staging, and a final staged-diff review. Detached HEAD, merge state, branch or remote ambiguity, unclear ownership, likely secrets, and failed verification stop publication; the workflow forbids broad staging, force-push, reset, history rewrite, and discarding user work.

Four independent Phase 3 forward tests covered the non-publishing default, successful explicit publication, `publish_policy: never` with an untouched `.env`, and a mandatory verification failure without override. Direct Git checks confirmed unchanged refs and empty staging for every non-publishing or blocked case. The successful case committed exactly its two closeout documents plus the completed result and synchronized the local and remote `main` refs.

Phase 4 is released in `2.0.0`. Both skills now qualify material claims as `Verified`, `Observed`, `Assumption`, `Not run`, or `Blocked`. Only checks executed in the current session are current `Verified` evidence; historical passes remain `Observed` until rerun, and unresolved contradictions stay visible instead of being silently selected.

Version 2.2 adds Decision D-004 and an independent `plan` flag. `wrap-up plan` remains non-publishing and copies only the latest explicitly user-confirmed exact plan body into the configured or existing canonical plan; `wrap-up plan publish` composes that behavior with the existing explicit publish authorization. Unconfirmed proposals and unavailable exact text produce `Blocked` without modifying the plan body. Progress, verification evidence, and status remain outside the confirmed body. Bootstrap now retains formal plan identifiers and wording in current/next reporting.

Version 2.2.1 adds Decision D-005. Antigravity skills now install to its current `~/.gemini/config/skills/` global discovery root and continue syncing the former `~/.gemini/antigravity/skills/` path for legacy builds. `test-installation.ps1` asserts these paths independently from the installer and checks preservation, backups, verification, hashes, and idempotency.

Version 2.3.0 adds Decision D-006. `wrap-up` documents how to attach a short provenance preface (confirmation source, date, executing session) before a new or previously unattributed confirmed-plan body, clearly bounded outside the immutable body, and how to condense a historical closeout entry to one dated line once it no longer informs an open decision, blocker, or next action. `bootstrap` now treats a hardcoded environment-specific literal (path, username, hostname) that does not match the observed environment as its own conflict subtype, resolved the same way as any other contradiction (observed state wins) and flagged for correction at the next `wrap-up`. This release was found through direct dogfooding: this repository's own `HANDOFF.md` had unpruned historical closeouts and a stale hardcoded username in its "Installed global copies" section, both now fixed.

`test-plan-fidelity.ps1` provides a generic six-direction matrix with three confirmed-source and three unconfirmed-only cases. It derives expected content from fixture sources, compares the bounded plan body character-for-character, rejects draft sentinels, checks evidence separation and existing-document reuse, and enforces non-publishing Git state. `verify.ps1 -CanonicalOnly` validates source contracts and both fixture matrices without requiring or modifying global installations.

`test-regressions.ps1` maintains the complete six-direction takeover matrix through shared raw templates and per-direction manifests. Its three modes validate definitions, prepare isolated one-commit repositories, and assert post-run evidence labels, stale-claim reconciliation, exact reuse of the existing status/spec/handoff files, verification execution, and non-publishing Git state.

Six fresh-agent forward tests passed every Codex, Claude Code, and Antigravity source-to-receiver direction. The final checker reported 6 passes with no failures, and a separate prepare smoke test produced six clean repositories. Both skills pass Skill Creator validation. An isolated installation passed all 22 verifier checks; global synchronization created `20260906-125758` backups and updated all six skill copies.

Historical Phase 4 publication closeout evidence on 2026-09-06:

- `Verified`: the Skill Creator validator accepted both skills; all four PowerShell scripts passed AST parsing; fixture validation passed; the global verifier reported 22 passes with no warnings or failures; and `git diff --check` passed.
- `Verified`: six fresh receiving agents exercised all directed platform pairs. The post-run checker rejected one missing `Blocked` label, then reported 6 passes and no failures after the fixture record was corrected.
- `Observed`: at that closeout, the source version remained `2.0.0-dev`; Phase 4 was complete while the separate `v2.0.0` release decision remained future work.
- `Not run`: Phase 5 macOS/Linux distribution tests and release tagging were outside the Phase 4 publication scope.
- `Blocked`: none for publishing the Phase 4 source changes.

Historical Version 2 release-readiness closeout on 2026-09-06:

- `Observed`: the closeout started from clean `main` at `0ad5853`, synchronized with `origin/main`; at that point `VERSION` remained `2.0.0-dev`, and `v1.0.0` remained the only release tag.
- `Verified`: the Skill Creator validator accepted both canonical skills; all four PowerShell entry scripts passed AST parsing; the optional project-context example passed Draft 2020-12 schema validation; the six fixture definitions passed `test-regressions.ps1 -Mode Validate`; live `verify.ps1` reported 22 passes with no warnings or failures; and `git diff --check` returned exit code 0.
- `Verified`: a fresh isolated user root passed two-run installation idempotency without file or timestamp changes on the second run, followed by all 22 verifier checks. The temporary root was removed after the test.
- `Observed`: the completed Version 2 feature set and its current Windows installation path are ready for release. Phase 5 is a separately planned macOS/Linux distribution milestone and is not required before the Windows-scoped `v2.0.0` release.
- `Not run`: the six fresh-agent takeover workflows and isolated updater fixture were not repeated because this closeout changed no skill, fixture, installer, or updater behavior; their earlier passes remain historical observed evidence.
- `Blocked`: none for release readiness. Publication was intentionally pending explicit authorization to change the version, create the release commit and tag, and push them.

Version 2 release publication on 2026-09-06:

- `Observed`: the authorized release scope consists only of `VERSION`, `README.md`, `DECISIONS.md`, `STATUS.md`, `HANDOFF.md`, and `IMPLEMENTATION_PLAN.md`; no skill source, fixture, installer, updater, or unrelated user file is included.
- `Verified`: both Skill Creator validations, the four-script AST check, Draft 2020-12 project-context schema validation, six-fixture definition validation, live 22-check verifier, isolated two-run installation, and `git diff --check` passed for the release candidate.
- `Observed`: the release candidate sets `VERSION` to `2.0.0`, defines annotated tag `v2.0.0` as its release identifier, and has explicit current authorization to publish `main` and the tag to `origin`.
- `Not run`: fresh-agent takeover workflows and the isolated updater fixture were not repeated because their covered behavior did not change for this release.
- `Blocked`: none. Phase 5 remains an optional future macOS/Linux distribution milestone.

Version 2.1 global-preference increment on 2026-09-06:

- `Observed`: the existing English README remains intact and now has a complete Traditional Chinese version below it. The Codex, Claude Code, and Antigravity canonical global rule files carry identical response-language and bilingual GitHub README preferences inside the existing managed marker.
- `Verified`: source inspection and isolated tests confirm that existing `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` content outside the managed marker is preserved. A missing managed block is appended; an existing block is replaced in place; duplicates are removed; and each changed existing file is backed up first.
- `Verified`: an isolated local/remote fixture updated a clean installed `2.0.0` client to `2.1.0-dev`, preserved unrelated sentinel instructions on all three platforms, installed exactly one current managed block, created the expected backups, passed verification, and remained idempotent on a second update.
- `Verified`: the first fixture run caught a Windows PowerShell 5.1 encoding incompatibility in the verifier's new non-ASCII literals. Replacing those script literals with ASCII fragments retained UTF-8 rule-file validation, and the fresh end-to-end rerun passed.
- `Verified`: both Skill Creator validations, PowerShell AST parsing, canonical rule validation, takeover fixture definition validation, live global synchronization/hash checks, and `git diff --check` passed. The live verifier reported 23 passes with no warnings or failures.
- `Observed`: live synchronization created `20260906-183550` backups for `~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md`, and `~/.gemini/GEMINI.md`; content outside the managed marker was unchanged.
- `Verified`: an Antigravity IDE 1.107.0 agent session created the primary `README.md` in an otherwise empty isolated Git repository from an English prompt that did not request bilingual output. It produced a complete English version followed by a complete Traditional Chinese version, preserved commands and technical identifiers across both versions, created no other files, and made no commit.
- `Not run`: the equivalent Claude Code 2.1.221 observation stopped before model execution because it was not authenticated, and the user subsequently deferred that observation as low priority. The prepared fixture contains no `README.md` or other worktree file.
- `Not run`: the isolated Codex README behavior observation was outside the requested Claude Code and Antigravity IDE run.
- `Not run`: the six fresh-agent takeover workflows were not repeated because no skill or takeover behavior changed.
- `Blocked`: none. The development increment remains uncommitted and unpublished until explicitly requested.

Version 2.1 development-line publication closeout on 2026-09-07:

- `Observed`: the user explicitly authorized `wrap-up publish` for the completed `2.1.0-dev` global-preference increment and deferred the Claude Code behavior observation as low priority. This authorization covers a scoped commit and push of the development line, not a `v2.1.0` release tag.
- `Observed`: after `git fetch origin`, local `main` and `origin/main` both remained at `fd5a927` with ahead/behind `0/0`; no files were staged or untracked, and no merge or rebase was active before publication.
- `Verified`: `VERSION` is `2.1.0-dev`, and live `verify.ps1` reported 23 passes with no warnings or failures. The installed Codex, Claude Code, and Antigravity skill entries and managed global-preference blocks match the canonical source.
- `Verified`: the Skill Creator validator accepted both skills; all four PowerShell scripts passed AST parsing; `PROJECT_CONTEXT.example.yaml` passed Draft 2020-12 schema validation; `test-regressions.ps1 -Mode Validate` accepted all six directed fixtures; and `git diff --check` passed.
- `Verified`: a fresh isolated user root completed two `install.ps1` runs without any second-run file, hash, or timestamp change, then passed all 23 isolated verifier checks. The temporary root was removed afterward.
- `Verified`: Antigravity IDE 1.107.0 created a complete English-first, Traditional-Chinese-second README from an English-only request in an isolated empty repository, preserved commands and technical identifiers, created no other files, and made no commit.
- `Observed`: the earlier isolated updater fixture remains historical evidence because updater behavior has not changed since that passing run.
- `Not run`: the Claude Code observation was explicitly deferred as low priority; the isolated Codex behavior observation was not required for this development-line publication; and the six takeover workflows were not repeated because neither skill nor takeover behavior changed.
- `Blocked`: none for the authorized `2.1.0-dev` commit and push. The final `2.1.0` version change and annotated tag remain separate work requiring explicit release authorization.

Version 2.1 release publication on 2026-09-07:

- `Observed`: after the requested Codex smoke test passed, the user explicitly authorized `wrap-up publish 2.1.0 release`. The release candidate contains only `VERSION`, `README.md`, `STATUS.md`, `HANDOFF.md`, and `IMPLEMENTATION_PLAN.md`; the authorized destination is `main` and annotated tag `v2.1.0` on `origin`.
- `Observed`: after `git fetch origin`, local `main` and `origin/main` both remained at `34b9c5a` with a clean worktree; no merge or rebase was active, and `v2.1.0` did not yet exist before release preparation.
- `Verified`: a new Codex task in an isolated Codex worktree received an English-only README improvement request without any bilingual instruction. It modified only `README.md`, added a complete English section followed by a complete Traditional Chinese counterpart, kept commands and technical identifiers aligned, passed its README diff check, and made no commit, tag, or push.
- `Verified`: the isolated worktree verifier's 15 global-install mismatches came from byte-level checkout line-ending differences rather than damaged global rules. Representative canonical skill, metadata, and global-rule files had no difference when end-of-line whitespace was ignored; the smoke task changed only `README.md`, and the canonical live verifier passed all 23 checks.
- `Verified`: `VERSION` is `2.1.0`; both Skill Creator validations, the four-script PowerShell AST check, Draft 2020-12 project-context schema validation, six-fixture definition validation, README structural parity check, live 23-check verifier, and `git diff --check` passed.
- `Verified`: a fresh isolated user root completed two installations without any second-run file, hash, or timestamp change, then passed all 23 isolated verifier checks. Its one-time script and temporary root were removed afterward.
- `Observed`: the earlier passing updater fixture remains historical evidence because no updater behavior changed in this release-only version and documentation update.
- `Not run`: the Claude Code behavior observation remains explicitly deferred as low priority; the six fresh-agent takeover workflows were not repeated because no skill, evidence, or takeover behavior changed.
- `Blocked`: none for the explicitly authorized release commit, annotated tag, and pushes.

The skills explicitly require every agent to continue existing project documents regardless of which AI created them. They forbid platform-specific duplicate status/spec/handoff sets and distinguish shared project facts from host-specific behavioral instructions.

Isolated reciprocal tests verified both directions: `wrap-up ncp` continued ChatGPT/Codex-authored documents while reading Claude guidance, and Codex `bootstrap` continued Claude-authored status and spec files without editing them.

The canonical directory is a Git repository on `main`. Its `origin` is the private repository `https://github.com/aaabot1205/wrap-up-bootstrap.git`, and the branch tracks `origin/main`.

The repository also contains portable global preference rules for response language and bilingual GitHub READMEs, plus idempotent Windows install, verify, and update scripts. A new machine can clone the private repository and run the installer and verifier to configure Codex, Claude Code, and Antigravity together. Isolated local-remote fixtures confirmed two-run installation and update idempotency, fast-forward version reporting, changed-file backups, preservation of unrelated rules and skills, managed-block replacement, corruption detection and repair, and refusal of dirty or unpublished ahead state.

Plan Fidelity canonical closeout on 2026-09-08:

- `Observed`: development began from clean `main` at `c1d1a1d` (`v2.1.0`). The user reviewed the canonical-only result and then explicitly authorized global installation plus `wrap-up publish`.
- `Verified`: both Skill Creator validations passed using an already cached PyYAML runtime; all five PowerShell scripts passed AST parsing; `verify.ps1 -CanonicalOnly` reported 8 passes with no warnings or failures; both regression validators passed.
- `Verified`: six fresh-agent receiver-contract fixture runs passed the aggregate Plan Fidelity checker. Three confirmed-source bodies matched character-for-character, three unconfirmed-only bodies remained unchanged with recorded blockers, every draft sentinel was rejected, every local fixture verifier ran, and no fixture staged or committed work.
- `Verified`: an additional read-only fresh bootstrap observation retained the exact `Post-2.1: Plan Fidelity mode` and `Phase 5: Cross-operating-system distribution` identifiers and wording, detected a stale next-action sentence, and made no file change; the stale sentence was then reconciled in the canonical plan.
- `Verified`: `install.ps1` created timestamped `20260908-124457` backups for changed installed files and synchronized both skills across all three platforms. Live `verify.ps1` reported 23 passes with no warnings or failures, and all six installed `SKILL.md` SHA256 hashes match canonical sources.
- `Not run`: new host-native Claude Code and Antigravity sessions were not started after installation; the six portable source-to-receiver fixture directions remain the behavioral evidence.
- `Observed`: the 29-file Plan Fidelity implementation was published to `origin/main` as `7a36d71`. The user then explicitly authorized the `2.2.0` release increment, annotated `v2.2.0` tag, and pushes to the existing `main` upstream on `origin`.
- `Blocked`: none for the authorized commit and push.

Version 2.2 release publication on 2026-09-08:

- `Observed`: after refreshing `origin` and its tags, local and remote-tracking `main` were synchronized at `7a36d71`, the worktree was clean, and no local `v2.2.0` tag existed before release preparation.
- `Observed`: the authorized release candidate contains exactly `VERSION`, `README.md`, `DECISIONS.md`, `STATUS.md`, `HANDOFF.md`, and `IMPLEMENTATION_PLAN.md`; the destinations are `origin/main` and annotated tag `v2.2.0` on `origin`.
- `Verified`: `VERSION` is `2.2.0`; both Skill Creator validators, five-script PowerShell AST parsing, live 23-check verification, takeover and Plan Fidelity definition validation, the six-direction Plan Fidelity result checker, installed-skill hash comparison, README bilingual release parity, and `git diff --check` passed.
- `Not run`: fresh host-native behavior sessions were not repeated because this release-only increment does not change the globally installed skill content published in `7a36d71`.
- `Blocked`: none for the authorized release commit, annotated tag, and pushes.

Version 2.2.1 Antigravity discovery correction on 2026-09-09:

- `Observed`: Antigravity's installed customization guide defines `~/.gemini/config/` as global discovery and `skills/<name>/SKILL.md` as the skill layout. The prior installer and verifier both used only the legacy `~/.gemini/antigravity/skills/` root, explaining why Antigravity reported no `wrap-up` skill despite a passing repository verifier.
- `Verified`: the corrected verifier failed against the pre-install live state with six current-path missing-file results while accepting the legacy copies. The isolated installation regression then installed and verified both roots, preserved unrelated skills, created backups for stale managed files, and passed an unchanged second run.
- `Verified`: an isolated clean `2.2.0` client fast-forwarded through `update.ps1` to the `2.2.1` candidate, reported the version transition, installed both current-path Antigravity skills, preserved an unrelated current-path skill, and passed verification.
- `Verified`: both Skill Creator validations, six-script AST parsing, canonical verification, both six-direction regression definition validators, bilingual README parity, and `git diff --check` passed.
- `Verified`: the authorized live installation populated the current Antigravity path. The live verifier reported 27 passes with no warnings or failures, all eight current and compatibility installed `SKILL.md` hashes match canonical sources, and a second live installation changed no managed file, hash, or timestamp.
- `Not run`: a host-native Antigravity `/skills` observation awaits an IDE restart or new session so its skill inventory reloads.
- `Observed`: the user explicitly authorized the scoped `2.2.1` release commit, annotated `v2.2.1` tag, and pushes to the existing `main` upstream on `origin`.
- `Blocked`: none for release; the post-reload host observation remains the next runtime confirmation.

`IMPLEMENTATION_PLAN.md` records the Phase 0 through Phase 5 roadmap. Phases 0 through 4 are complete in their recorded source lines; Phase 5 covers eventual macOS/Linux distribution. `DECISIONS.md` is the durable source for publishing, project-context, and evidence-quality decisions.

## Canonical working copy

`C:\dev\wrap-up-bootstrap`

Installed global copies (paths are relative to the current user's home directory: `%USERPROFILE%` on Windows, `$HOME` on macOS/Linux, exactly as `install.ps1` resolves `$UserRoot`; do not hardcode a literal username here):

- Codex: `<home>\.agents\skills\{wrap-up,bootstrap}`
- Claude Code: `<home>\.claude\skills\{wrap-up,bootstrap}`
- Antigravity IDE current: `<home>\.gemini\config\skills\{wrap-up,bootstrap}`
- Antigravity IDE legacy compatibility: `<home>\.gemini\antigravity\skills\{wrap-up,bootstrap}`

## Maintenance procedure

1. Edit the canonical `wrap-up/` and `bootstrap/` folders.
2. Update `STATUS.md` and this handoff when behavior, validation state, global paths, or outstanding work changes.
3. Validate both skills with the Skill Creator validator.
4. Copy both folders to Codex, Claude Code, and both Antigravity global skill roots.
5. Compare hashes for each installed `SKILL.md` against the canonical copy.
6. Run isolated forward tests after behavioral changes.
7. Run the installer twice against an isolated test user root after changing installation logic; verify no duplicated managed blocks and no second-run changes.
8. Run `test-update.ps1` after changing `update.ps1` or `install.ps1` logic, and before claiming any release's upgrade path is verified; it is self-contained (isolated bare-repo origin, client, and user root) and no longer needs a live `update.ps1` run against a real global installation.
9. Run `test-regressions.ps1 -Mode Validate` after skill or fixture changes. For continuity or evidence changes, prepare fresh workspaces, forward-test all six receiving directions, and require `-Mode Check` to pass.
10. Run `test-plan-fidelity.ps1 -Mode Validate` after Plan Fidelity changes; prepare and forward-test all six directions before requiring `-Mode Check` to pass.
11. Run `test-installation.ps1` after changing installation paths or behavior.

Version 2.3.0 handoff hygiene closeout on 2026-09-09:

- `Observed`: the user confirmed the post-2.2.1 Antigravity `~/.gemini/config/skills/` discovery check passed on a restarted session, closing that item from the prior "Next action."
- `Verified`: the Skill Creator validator accepted both skills after removing two em-dash characters the new guidance had introduced (this machine's locale could not decode them; both skills are ASCII-only again, matching the rest of the canonical source).
- `Verified`: all six PowerShell scripts passed AST parsing; `verify.ps1 -CanonicalOnly` reported 8 passes, no warnings, no failures.
- `Verified`: a fresh six-direction takeover forward test (`test-regressions.ps1`: `Prepare` -> role-played all six directions -> `Check`) reported 6 passes, 0 failures.
- `Verified`: a fresh six-direction Plan Fidelity forward test (`test-plan-fidelity.ps1`) reported 6 passes, 0 failures, including the new provenance preface applied in all three confirmed-source cases without affecting the character-for-character plan-body comparison.
- `Verified`: `git diff --check` passed on the full canonical diff.
- `Not run`: `install.ps1` was deliberately withheld before this closeout so this machine's `v2.2.1` global installation stays intact for a genuine `update.ps1` upgrade test after the release is pushed.
- `Blocked`: none for the scoped release commit, annotated tag, and pushes once explicitly authorized.

Version 2.3.0's upgrade path was then verified live on this machine: `update.ps1` genuinely upgraded the installed `v2.2.1` copies (8 backup files created, confirmed to hold the pre-2.3.0 content; all 8 installed `SKILL.md` files SHA256-match canonical). That live run directly exposed Decision D-007: `update.ps1` only runs once a release is already pushed, so verifying it could only ever happen after the fact, with nowhere durable to record the result without creating another stale "Next action" -- the same pattern as the Antigravity-restart item this project already had to resolve once. `test-update.ps1` now automates that same dry-run against an isolated bare-repo origin, client, and user root seeded from the most recent prior release tag, so this verification is a normal pre-push check from now on; a live `update.ps1` run against a real global installation is no longer required to support an upgrade-path claim.

## Next action

Confirm explicit-only selection in fresh Codex and Claude Code sessions and resolve Antigravity loader enforcement before claiming all three hosts block model invocation. The updater-message work is complete. Neither this next-action record nor another skill authorizes invoking bootstrap or wrap-up; wait for the user's explicit request by name.

## Version 2.4.0 release handoff

- Date: 2026-09-14
- `Work`: release the completed IP-01 through IP-06 continuity implementation as `2.4.0`.
- `Observed`: the user explicitly authorized global installation, `wrap-up publish`, and annotated tag `v2.4.0`.
- `Verified`: global installation created eight `20260914-013140` backups and live verification reported 27 passes with every installed skill tree matching canonical.
- `Verified`: Skill Creator, packaging, isolated installation, six-direction fixture definition validation, and `git diff --check` passed.
- `Review`: the release document scope is exactly `VERSION`, `README.md`, `STATUS.md`, `HANDOFF.md`, `IMPLEMENTATION_PLAN.md`, `SKILL_CONTINUITY_PROPOSAL.md`, and `SKILL_CONTINUITY_EVIDENCE.md`; the underlying 35-file implementation already passed Standards and Spec review.
- `Verified`: the committed-HEAD updater regression upgraded `v2.3.0` to `2.4.0`; release commit `eb70e01`, `origin/main`, and peeled annotated tag `v2.4.0` were then verified at the same commit with a clean synchronized worktree.
- `Not run`: host-native post-restart discovery.
- `Next action`: no release work remains; the separate updater-message follow-up is published independently on `main` without moving tag `v2.4.0`.

## Skill continuity implementation handoff

- Date: 2026-09-13
- `Work`: IP-01 through IP-06 implement the approved continuity proposal while preserving the existing plan body and all six platform directions.
- `Verified`: takeover producers passed 6/6; six fresh bootstrap receivers recovered the same unfinished acceptance and external next action while preserving complete snapshots.
- `Verified`: Plan Fidelity passed 6/6 and replay was byte-stable with one provenance preface. Explicit publish committed and pushed exactly three authorized paths to a local bare remote.
- `Verified`: conditional references are independently packageable and missing-reference rejection is tested; updater regression selects the latest reachable prior tag with a different `VERSION`.
- `Verified`: global installation created `20260914-013140` backups and live verification reported 27 passes with all eight installed skill trees matching canonical.
- `Not run`: host-native three-product restart observation.
- `Review`: Standards and Spec reviews covered all 35 staged files from fixed point `a902c18a69c3dfe32bee9d56b66b63ce3c6b6f9a`; no P0-P3 finding remains.
- `Next action`: no continuity-release work remains; the updater-message follow-up is published independently on `main` without moving tag `v2.4.0`.
