# Agent instructions

These files are maintained as one cross-platform project. Apply these instructions in Codex, Claude Code, Antigravity, and other Agent Skills-compatible hosts.

- Treat `wrap-up/SKILL.md` and `bootstrap/SKILL.md` in this directory as the canonical skill sources.
- Treat `global-rules/AGENTS.md`, `global-rules/CLAUDE.md`, and `global-rules/GEMINI.md` as the canonical portable sources for the response-language and bilingual GitHub README preferences.
- Treat `PROJECT_CONTEXT.schema.json` and `PROJECT_CONTEXT.example.yaml` as the canonical optional project-context contract. Never make `PROJECT_CONTEXT.yaml` mandatory or remove automatic discovery fallback.
- Treat `test-regressions.ps1` and `tests/fixtures/takeover/` as the canonical cross-platform takeover regression system. Keep all six directed platform pairs.
- Treat `test-plan-fidelity.ps1` and `tests/fixtures/plan-fidelity/` as the canonical `wrap-up plan` regression system. Keep all six directed platform pairs and derive expected plan text from fixture sources rather than hardcoding a plan in the checker.
- Treat `test-installation.ps1` as the canonical isolated Windows installation regression. Keep the current Antigravity global discovery path and its legacy compatibility path independently asserted.
- Treat `test-update.ps1` as the canonical isolated `update.ps1` dry-run regression. Keep it exercising a real fast-forward from the most recent prior release tag to `HEAD` against an isolated bare-repo origin and an isolated user root, asserting version transition reporting, backup creation, installed-file hashes, and both dirty-worktree and ahead-of-upstream refusal.
- Keep `install.ps1` idempotent and non-destructive toward unrelated global rules and skill files.
- Preserve the open `SKILL.md` frontmatter contract with only `name` and `description` in each skill's frontmatter.
- Keep both skills platform-neutral. Do not fork their behavior by host unless a documented platform limitation requires a small compatibility layer.
- Treat project documentation as project-owned, not agent-owned. Continue existing files from any AI platform instead of creating redundant platform-specific copies.
- Keep `SKILL.md` concise and imperative. Put user-facing installation and disable guidance in `INSTALL.md`, not inside a skill folder.
- After changing behavior, run the Skill Creator validator, forward-test the affected workflow in an isolated fixture, synchronize all global copies, and compare file hashes.
- Run `verify.ps1` after changing skills, installation logic, or the project-context contract.
- Run `test-regressions.ps1 -Mode Validate` after changing either skill or any takeover fixture. After cross-platform continuity or evidence behavior changes, prepare fresh workspaces and forward-test all six directions before using `-Mode Check`.
- Run `test-plan-fidelity.ps1 -Mode Validate` after changing Plan Fidelity behavior or fixtures. Forward-test all six directions before using `-Mode Check` for a behavioral release claim.
- Run `test-installation.ps1` after changing installation paths or installation behavior.
- Run `test-skill-packaging.ps1` after adding or changing files linked from either skill. It must validate each skill independently and reject a package with a missing required reference.
- Run `test-update.ps1` after changing `update.ps1` or `install.ps1` logic, and before claiming any release's upgrade path is verified. It is self-contained and self-verifying (it targets `HEAD` against the previous release tag dynamically), so no separate live `update.ps1` run against a real global installation is needed to support that claim.
- Preserve unrelated files and settings in every global configuration directory. Never replace an existing settings file merely to disable or enable these skills.
- Update `STATUS.md` and `HANDOFF.md` whenever behavior, validation state, global paths, or outstanding work changes.
