# Wrap-up and Bootstrap Skills

This project maintains two global, cross-platform Agent Skills for Codex, Claude Code, and Google Antigravity:

- `wrap-up`: close a project phase, reconcile durable documentation, and verify the work; publish only when explicitly requested.
- `bootstrap`: reconstruct reliable project context in a new session and optionally begin a supplied follow-on task.

The current implementation is usable. The remaining reliability, safety, project-context, and operating-system improvements are organized in `IMPLEMENTATION_PLAN.md` so they can be delivered incrementally without destabilizing the working baseline.

Current release: `2.0.0` (`v2.0.0`). The recoverable Version 1 baseline remains `1.0.0` (`v1.0.0`); the completed Phase 1 through Phase 4 work is included in Version 2.

## Version 2 command contract

- `bootstrap` gathers project context without editing during the bootstrap phase and may then begin a supplied follow-on task.
- `wrap-up` reconciles documentation and verifies the completed phase without staging, committing, or pushing.
- `wrap-up publish` adds a safeguarded, scoped commit and push after successful required verification.
- `wrap-up ncp` remains a compatibility alias for the non-publishing default.

Published `v1.x` users retain the older default-publishing contract. When migrating to Version 2, add `publish` to automation or prompts that are intended to commit and push. A plain `wrap-up` now stops after documentation reconciliation and verification.

Before publishing, the skill inspects the branch, upstream, remote, unstaged and staged diffs; establishes an explicit phase-owned path list; and blocks ambiguous, unrelated, or likely sensitive files. Failed mandatory checks block publication unless the user sees the failure and explicitly overrides it. The workflow never force-pushes, resets, discards work, or uses broad staging shortcuts.

## Optional project context

A repository may copy `PROJECT_CONTEXT.example.yaml` to a root-level `PROJECT_CONTEXT.yaml` and tailor it to identify authoritative documents, verification commands, the default branch, publishing policy, cautions, and discovery exclusions. The contract is optional and versioned by `schema_version`; projects without it continue using automatic discovery.

All configured paths are relative to the repository root. A valid file guides routing and policy but never proves that work is implemented or verified. Invalid or unsupported configuration is reported explicitly, then the skills fall back to automatic discovery where safe.

`git.publish_policy` supports `skill-default`, `explicit`, and `never`. Current user instructions still take precedence, and neither skill switches branches merely to match the configured default.

## Evidence contract

Both skills qualify material project claims with five exact labels:

- `Verified`: a check executed in the current session, with the command or check and result recorded;
- `Observed`: current Git, configuration, source, or file state inspected directly;
- `Assumption`: an inference that still needs a stated confirmation method;
- `Not run`: an expected check that was skipped or unavailable, with the reason recorded;
- `Blocked`: incomplete work or verification, with its blocker and recovery action.

A previous session's passing result is historical `Observed` evidence until rerun. One narrow passing check never verifies a broader milestone, and unresolved contradictions remain visible as competing labeled claims.

The regression matrix covers every directed takeover among Codex, Claude Code, and Antigravity. `test-regressions.ps1` validates the six fixture definitions, prepares isolated Git workspaces, and checks that receiving sessions update the existing status, spec, and handoff files without publishing or creating platform-specific replacements.

## Design contract

Project documents belong to the project, not to the AI that created them. Every supported platform must discover and continue the existing source of truth even when another platform chose its filename or last updated it. The skills therefore search by document purpose and repository conventions rather than imposing separate ChatGPT, Claude, or Gemini documentation sets.

See `INSTALL.md` for installation, invocation, disabling, and re-enabling instructions.

## Project layout

- `wrap-up/SKILL.md`: portable wrap-up workflow.
- `bootstrap/SKILL.md`: portable session bootstrap workflow.
- `agents/openai.yaml` inside each skill: optional Codex/ChatGPT UI metadata; other hosts can ignore it.
- `global-rules/`: portable source copies of the global response-language rules for all three platforms.
- `install.ps1`: idempotent Windows installer for all skills and global rules.
- `verify.ps1`: installation, hash, managed-rule, frontmatter, metadata, evidence-contract, fixture-matrix, and restart-guidance checks.
- `update.ps1`: guarded fast-forward update, backed-up installation, verification, and version-transition reporting.
- `test-regressions.ps1`: validate, prepare, and check the six-direction cross-platform takeover matrix.
- `tests/fixtures/takeover/`: shared raw fixture templates plus one manifest for each directed platform pair.
- `PROJECT_CONTEXT.schema.json`: machine-readable Version 1 contract for optional project context.
- `PROJECT_CONTEXT.example.yaml`: documented repository-root configuration example.
- `VERSION`: current source version; release tags identify published baselines.
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
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\verify.ps1
```

The installer preserves unrelated global instructions, updates only its marked response-language block, and creates timestamped backups before replacing different existing files. Start new sessions in all three platforms afterward.

Alternatively, open Codex on the new machine and paste this single request:

```text
Authenticate GitHub as aaabot1205 if needed, clone the private repository aaabot1205/wrap-up-bootstrap to C:\dev\wrap-up-bootstrap, run its install.ps1, verify all six skill installations and three global response-language rules, then report any platform that needs a restart.
```

## Update an existing Windows installation

Run the guarded updater from a clean checkout whose current named branch has an upstream and no unpublished local commits:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\update.ps1
```

The updater fetches the configured upstream, permits only a fast-forward, refuses dirty, detached, untracked, ahead, or divergent local state, then runs `install.ps1` and `verify.ps1`. Changed existing global files receive timestamped side-by-side backups, and the final report includes the version transition and restart guidance.
