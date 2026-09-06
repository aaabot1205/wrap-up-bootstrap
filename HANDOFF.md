# Handoff

## Purpose

Maintain two AI-platform-neutral skills that make end-of-phase documentation and new-session takeover reliable across Codex, Claude Code, and Google Antigravity.

## Current state

The implementation is ready for normal use on the current Windows machine. The remaining work is incremental hardening rather than a blocker to using `wrap-up` and `bootstrap` now.

Phase 0 is complete, and Git tag `v1.0.0` identifies the recoverable `1.0.0` baseline. Version `2.0.0`, identified by annotated tag `v2.0.0`, is the current release. Version `2.1.0-dev` is the active development line and adds a portable preference requiring complete English and Traditional Chinese versions in a GitHub repository's primary `README.md`. Decision D-001 preserves the Version 1 behavior and governs the released Version 2 publishing contract: plain `wrap-up` is non-publishing, `wrap-up publish` is explicit publication authorization, and `ncp` remains a non-publishing compatibility alias.

Phase 1 is released in `2.0.0`. `verify.ps1` checks all installations, hashes, managed rules, frontmatter, trigger descriptions, OpenAI UI metadata, and restart guidance. `update.ps1` refuses dirty, detached, upstream-less, ahead, or divergent state; it fetches and fast-forwards only, then installs, verifies, and reports the version transition. `install.ps1` reports timestamped backups and repairs duplicate managed blocks while preserving unrelated content.

Phase 2 is also released in `2.0.0`. The optional root-level `PROJECT_CONTEXT.yaml` Version 1 contract can route status, handoff, plan, spec, and decision documents; declare verification commands, default branch, publishing policy, cautions, and exclusions; and preserve discovery fallback when absent. Decision D-002 and the schema define path-safety, invalid-config, exclusion, and `skill-default`/`explicit`/`never` semantics. The intermediate `v1.1.0` release was not created; its planned work was folded into Version 2.

Phase 3 is released in `2.0.0`. Publishing now requires inspection of repository state and destination, positive phase-owned file scope, sensitive-material review, successful mandatory checks, explicit-path staging, and a final staged-diff review. Detached HEAD, merge state, branch or remote ambiguity, unclear ownership, likely secrets, and failed verification stop publication; the workflow forbids broad staging, force-push, reset, history rewrite, and discarding user work.

Four independent Phase 3 forward tests covered the non-publishing default, successful explicit publication, `publish_policy: never` with an untouched `.env`, and a mandatory verification failure without override. Direct Git checks confirmed unchanged refs and empty staging for every non-publishing or blocked case. The successful case committed exactly its two closeout documents plus the completed result and synchronized the local and remote `main` refs.

Phase 4 is released in `2.0.0`. Both skills now qualify material claims as `Verified`, `Observed`, `Assumption`, `Not run`, or `Blocked`. Only checks executed in the current session are current `Verified` evidence; historical passes remain `Observed` until rerun, and unresolved contradictions stay visible instead of being silently selected.

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

The skills explicitly require every agent to continue existing project documents regardless of which AI created them. They forbid platform-specific duplicate status/spec/handoff sets and distinguish shared project facts from host-specific behavioral instructions.

Isolated reciprocal tests verified both directions: `wrap-up ncp` continued ChatGPT/Codex-authored documents while reading Claude guidance, and Codex `bootstrap` continued Claude-authored status and spec files without editing them.

The canonical directory is a Git repository on `main`. Its `origin` is the private repository `https://github.com/aaabot1205/wrap-up-bootstrap.git`, and the branch tracks `origin/main`.

The repository also contains portable global preference rules for response language and bilingual GitHub READMEs, plus idempotent Windows install, verify, and update scripts. A new machine can clone the private repository and run the installer and verifier to configure Codex, Claude Code, and Antigravity together. Isolated local-remote fixtures confirmed two-run installation and update idempotency, fast-forward version reporting, changed-file backups, preservation of unrelated rules and skills, managed-block replacement, corruption detection and repair, and refusal of dirty or unpublished ahead state.

`IMPLEMENTATION_PLAN.md` records the Phase 0 through Phase 5 roadmap. Phases 0 through 4 are complete in their recorded source lines; Phase 5 covers eventual macOS/Linux distribution. `DECISIONS.md` is the durable source for publishing, project-context, and evidence-quality decisions.

## Canonical working copy

`C:\dev\wrap-up-bootstrap`

Installed global copies:

- Codex: `C:\Users\User\.agents\skills\{wrap-up,bootstrap}`
- Claude Code: `C:\Users\User\.claude\skills\{wrap-up,bootstrap}`
- Antigravity IDE: `C:\Users\User\.gemini\antigravity\skills\{wrap-up,bootstrap}`

## Maintenance procedure

1. Edit the canonical `wrap-up/` and `bootstrap/` folders.
2. Update `STATUS.md` and this handoff when behavior, validation state, global paths, or outstanding work changes.
3. Validate both skills with the Skill Creator validator.
4. Copy both folders to all three global locations.
5. Compare hashes for each installed `SKILL.md` against the canonical copy.
6. Run isolated forward tests after behavioral changes.
7. Run the installer twice against an isolated test user root after changing installation logic; verify no duplicated managed blocks and no second-run changes.
8. Run the updater against an isolated upstream and confirm fast-forward-only behavior, backup reporting, version transition, and dirty/ahead refusal after changing update logic.
9. Run `test-regressions.ps1 -Mode Validate` after skill or fixture changes. For continuity or evidence changes, prepare fresh workspaces, forward-test all six receiving directions, and require `-Mode Check` to pass.

## Next action

Observe the published `2.1.0-dev` development line in normal use. Leave the Claude Code behavior observation deferred unless its priority changes, and run the isolated Codex observation only if it becomes part of the release gate. Create the final `2.1.0` version and annotated tag only with separate explicit release authorization; start Phase 5 only when macOS or Linux distribution has a concrete user need.
