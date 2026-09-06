# Handoff

## Purpose

Maintain two AI-platform-neutral skills that make end-of-phase documentation and new-session takeover reliable across Codex, Claude Code, and Google Antigravity.

## Current state

The implementation is ready for normal use on the current Windows machine. The remaining work is incremental hardening rather than a blocker to using `wrap-up` and `bootstrap` now.

Phase 0 is complete, and Git tag `v1.0.0` identifies the recoverable `1.0.0` baseline. Decision D-001 preserves that Version 1 behavior and now governs the implemented `2.0.0-dev` contract: plain `wrap-up` is non-publishing, `wrap-up publish` is explicit publication authorization, and `ncp` remains a non-publishing compatibility alias.

Phase 1 is complete in the `2.0.0-dev` working line. `verify.ps1` checks all installations, hashes, managed rules, frontmatter, trigger descriptions, OpenAI UI metadata, and restart guidance. `update.ps1` refuses dirty, detached, upstream-less, ahead, or divergent state; it fetches and fast-forwards only, then installs, verifies, and reports the version transition. `install.ps1` reports timestamped backups and repairs duplicate managed blocks while preserving unrelated content.

Phase 2 is also complete in `2.0.0-dev`. The optional root-level `PROJECT_CONTEXT.yaml` Version 1 contract can route status, handoff, plan, spec, and decision documents; declare verification commands, default branch, publishing policy, cautions, and exclusions; and preserve discovery fallback when absent. Decision D-002 and the schema define path-safety, invalid-config, exclusion, and `skill-default`/`explicit`/`never` semantics. The intermediate `v1.1.0` release was not created; all unreleased Phase 1 and Phase 2 work is folded into Version 2.

Phase 3 is complete in source. Publishing now requires inspection of repository state and destination, positive phase-owned file scope, sensitive-material review, successful mandatory checks, explicit-path staging, and a final staged-diff review. Detached HEAD, merge state, branch or remote ambiguity, unclear ownership, likely secrets, and failed verification stop publication; the workflow forbids broad staging, force-push, reset, history rewrite, and discarding user work.

Four independent Phase 3 forward tests covered the non-publishing default, successful explicit publication, `publish_policy: never` with an untouched `.env`, and a mandatory verification failure without override. Direct Git checks confirmed unchanged refs and empty staging for every non-publishing or blocked case. The successful case committed exactly its two closeout documents plus the completed result and synchronized the local and remote `main` refs.

Both skills pass Skill Creator validation. All six global skill copies are synchronized; changed wrap-up files received `20260906-110734` backups, and `verify.ps1` reports 21 passes with no warnings or failures.

The skills explicitly require every agent to continue existing project documents regardless of which AI created them. They forbid platform-specific duplicate status/spec/handoff sets and distinguish shared project facts from host-specific behavioral instructions.

Isolated reciprocal tests verified both directions: `wrap-up ncp` continued ChatGPT/Codex-authored documents while reading Claude guidance, and Codex `bootstrap` continued Claude-authored status and spec files without editing them.

The canonical directory is a Git repository on `main`. Its `origin` is the private repository `https://github.com/aaabot1205/wrap-up-bootstrap.git`, and the branch tracks `origin/main`.

The repository also contains portable global response-language rules and idempotent Windows install, verify, and update scripts. A new machine can clone the private repository and run the installer and verifier to configure Codex, Claude Code, and Antigravity together. An isolated local-remote fixture confirmed two-run installation and update idempotency, fast-forward version reporting, changed-file backups, preservation of unrelated rules and skills, corruption detection and repair, and refusal of dirty or unpublished ahead state.

`IMPLEMENTATION_PLAN.md` records the Phase 0 through Phase 5 roadmap. Phases 0 through 3 are complete in their recorded source lines; Phase 4 adds evidence-quality labels and the complete cross-platform regression matrix, and Phase 5 covers eventual macOS/Linux distribution. `DECISIONS.md` is the durable source for publishing and project-context contract decisions.

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

## Next action

Implement Phase 4 evidence labels and the complete cross-platform takeover regression matrix. After the remaining Version 2 validation work passes, run an explicit release closeout for `v2.0.0`.
