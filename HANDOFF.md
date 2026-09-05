# Handoff

## Purpose

Maintain two AI-platform-neutral skills that make end-of-phase documentation and new-session takeover reliable across Codex, Claude Code, and Google Antigravity.

## Current state

The implementation is ready for normal use on the current Windows machine. The remaining work is incremental hardening rather than a blocker to using `wrap-up` and `bootstrap` now.

Phase 0 is complete. `VERSION` records `1.0.0`, and Git tag `v1.0.0` identifies the recoverable baseline. Decision D-001 preserves the existing command behavior throughout `v1.x` and selects a non-publishing default plus explicit `wrap-up publish` for `v2.0.0`. Phase 0 did not change either skill's behavior.

The skills explicitly require every agent to continue existing project documents regardless of which AI created them. They forbid platform-specific duplicate status/spec/handoff sets and distinguish shared project facts from host-specific behavioral instructions.

Isolated reciprocal tests verified both directions: `wrap-up ncp` continued ChatGPT/Codex-authored documents while reading Claude guidance, and Codex `bootstrap` continued Claude-authored status and spec files without editing them.

The canonical directory is a Git repository on `main`. Its `origin` is the private repository `https://github.com/aaabot1205/wrap-up-bootstrap.git`, and the branch tracks `origin/main`.

The repository also contains portable global response-language rules and an idempotent Windows `install.ps1`. A new machine can clone the private repository and run the installer to configure Codex, Claude Code, and Antigravity together. A two-run isolated-user-root test confirmed that the installer creates exactly six skill entries and one managed response-language block per platform without second-run changes.

`IMPLEMENTATION_PLAN.md` records the Phase 0 through Phase 5 roadmap. It covers the completed baseline, automated verification and updates, optional `PROJECT_CONTEXT.yaml`, the accepted Version 2 explicit Git publishing model, evidence-quality rules, cross-platform regression tests, and eventual macOS/Linux distribution. `DECISIONS.md` is the durable source for the publishing-policy decision.

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

## Next action

Start Phase 1 from `IMPLEMENTATION_PLAN.md` by implementing `verify.ps1`, including checks for all six installed skill entries, canonical hash equality, exactly one managed response-language block per platform, valid skill frontmatter, and restart guidance. Keep the `v1.x` command contract unchanged.
