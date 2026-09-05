# Wrap-up and Bootstrap Skills

This project maintains two global, cross-platform Agent Skills for Codex, Claude Code, and Google Antigravity:

- `wrap-up`: close a project phase, reconcile durable documentation, verify the work, and commit/push unless `ncp` is supplied.
- `bootstrap`: reconstruct reliable project context in a new session and optionally begin a supplied follow-on task.

The current implementation is usable. The remaining reliability, safety, project-context, and operating-system improvements are organized in `IMPLEMENTATION_PLAN.md` so they can be delivered incrementally without destabilizing the working baseline.

Current baseline version: `1.0.0` (`v1.0.0`).

## Version 1 command contract

- `bootstrap` gathers project context without editing during the bootstrap phase and may then begin a supplied follow-on task.
- `wrap-up` reconciles documentation, verifies the completed phase, commits scoped changes, and pushes.
- `wrap-up ncp` reconciles documentation and verifies without staging, committing, or pushing.

This behavior is frozen for `v1.x`. The accepted future publishing direction is recorded in `DECISIONS.md`; it does not change the current commands.

## Design contract

Project documents belong to the project, not to the AI that created them. Every supported platform must discover and continue the existing source of truth even when another platform chose its filename or last updated it. The skills therefore search by document purpose and repository conventions rather than imposing separate ChatGPT, Claude, or Gemini documentation sets.

See `INSTALL.md` for installation, invocation, disabling, and re-enabling instructions.

## Project layout

- `wrap-up/SKILL.md`: portable wrap-up workflow.
- `bootstrap/SKILL.md`: portable session bootstrap workflow.
- `agents/openai.yaml` inside each skill: optional Codex/ChatGPT UI metadata; other hosts can ignore it.
- `global-rules/`: portable source copies of the global response-language rules for all three platforms.
- `install.ps1`: idempotent Windows installer for all skills and global rules.
- `VERSION`: current release version.
- `DECISIONS.md`: accepted compatibility and publishing-policy decisions.
- `IMPLEMENTATION_PLAN.md`: phased roadmap from the usable baseline to a versioned, verifiable, safer, and cross-OS system.
- `STATUS.md`: current implementation and verification state.
- `HANDOFF.md`: concise context for the next maintenance session.
- `AGENTS.md`: maintenance rules for any AI agent working in this directory.

## Install on another Windows machine

After authenticating GitHub CLI as `aaabot1205`, run:

```powershell
gh repo clone aaabot1205/wrap-up-bootstrap C:\dev\wrap-up-bootstrap
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\install.ps1
```

The installer preserves unrelated global instructions, updates only its marked response-language block, and creates timestamped backups before replacing different existing files. Start new sessions in all three platforms afterward.

Alternatively, open Codex on the new machine and paste this single request:

```text
Authenticate GitHub as aaabot1205 if needed, clone the private repository aaabot1205/wrap-up-bootstrap to C:\dev\wrap-up-bootstrap, run its install.ps1, verify all six skill installations and three global response-language rules, then report any platform that needs a restart.
```
