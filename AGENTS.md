# Agent instructions

These files are maintained as one cross-platform project. Apply these instructions in Codex, Claude Code, Antigravity, and other Agent Skills-compatible hosts.

- Treat `wrap-up/SKILL.md` and `bootstrap/SKILL.md` in this directory as the canonical skill sources.
- Preserve the open `SKILL.md` frontmatter contract with only `name` and `description` in each skill's frontmatter.
- Keep both skills platform-neutral. Do not fork their behavior by host unless a documented platform limitation requires a small compatibility layer.
- Treat project documentation as project-owned, not agent-owned. Continue existing files from any AI platform instead of creating redundant platform-specific copies.
- Keep `SKILL.md` concise and imperative. Put user-facing installation and disable guidance in `INSTALL.md`, not inside a skill folder.
- After changing behavior, run the Skill Creator validator, forward-test the affected workflow in an isolated fixture, synchronize all global copies, and compare file hashes.
- Preserve unrelated files and settings in every global configuration directory. Never replace an existing settings file merely to disable or enable these skills.
- Update `STATUS.md` and `HANDOFF.md` whenever behavior, validation state, global paths, or outstanding work changes.
