# Handoff

## Purpose

Maintain two AI-platform-neutral skills that make end-of-phase documentation and new-session takeover reliable across Codex, Claude Code, and Google Antigravity.

## Current state

The skills explicitly require every agent to continue existing project documents regardless of which AI created them. They forbid platform-specific duplicate status/spec/handoff sets and distinguish shared project facts from host-specific behavioral instructions.

Isolated reciprocal tests verified both directions: `wrap-up ncp` continued ChatGPT/Codex-authored documents while reading Claude guidance, and Codex `bootstrap` continued Claude-authored status and spec files without editing them.

The 2026-09-05 full closeout reviewed the project documentation and installation state. Both skills passed validation, their canonical hashes matched all three global installations, and Markdown checks found no stale legacy path, conflict marker, or trailing whitespace.

The canonical directory is now a Git repository on `main`. Its `origin` is the private repository `https://github.com/aaabot1205/wrap-up-bootstrap.git`, and the branch tracks `origin/main`.

The repository also contains portable global response-language rules and an idempotent Windows `install.ps1`. A new machine can clone the private repository and run the installer to configure Codex, Claude Code, and Antigravity together. A two-run isolated-user-root test confirmed that the installer creates exactly six skill entries and one managed response-language block per platform without second-run changes.

## Canonical working copy

`C:\dev\wrap-up-bootstrap`

Installed global copies:

- Codex: `C:\Users\User\.agents\skills\{wrap-up,bootstrap}`
- Claude Code: `C:\Users\User\.claude\skills\{wrap-up,bootstrap}`
- Antigravity IDE: `C:\Users\User\.gemini\antigravity\skills\{wrap-up,bootstrap}`

## Maintenance procedure

1. Edit the canonical `wrap-up/` and `bootstrap/` folders.
2. Update `STATUS.md` and this handoff when behavior or installation changes.
3. Validate both skills with the Skill Creator validator.
4. Copy both folders to all three global locations.
5. Compare hashes for each installed `SKILL.md` against the canonical copy.
6. Run isolated forward tests after behavioral changes.
7. Run the installer twice against an isolated test user root after changing installation logic; verify no duplicated managed blocks and no second-run changes.

## Next action

No immediate action is required. When a platform changes its discovery rules, update `INSTALL.md`, synchronize the global copies, re-run validation, and push the resulting commit to `origin/main`.
