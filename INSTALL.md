# Cross-platform session skills

This bundle contains two skills based on the open `SKILL.md` format:

- `wrap-up`: reconcile project documentation and verify the phase; publish only when explicitly requested.
- `bootstrap`: load durable project context and prepare or begin the next task.

## Global installation locations

| Platform | Global skill directory |
| --- | --- |
| Codex | `~/.agents/skills/<skill-name>/` |
| Claude Code | `~/.claude/skills/<skill-name>/` |
| Google Antigravity IDE | `~/.gemini/antigravity/skills/<skill-name>/` |

Copy both `wrap-up/` and `bootstrap/` folders into each platform directory. Keep each `SKILL.md` directly inside its named folder.

## Automated Windows installation

On another machine, authenticate GitHub CLI and run:

```powershell
gh auth login --hostname github.com --git-protocol https --web --scopes repo
gh repo clone aaabot1205/wrap-up-bootstrap C:\dev\wrap-up-bootstrap
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\install.ps1
```

`install.ps1` installs both skills and merges the managed response-language block into:

- Codex: `~/.codex/AGENTS.md`
- Claude Code: `~/.claude/CLAUDE.md`
- Antigravity: `~/.gemini/GEMINI.md`

The installer is idempotent. It preserves unrelated rule content and creates timestamped backups before changing different existing files.

## Verify an installation

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\verify.ps1
```

The verifier checks the current semantic version, both canonical skill frontmatter blocks and required trigger terms, all six installed skill entries, every canonical-to-installed file hash, and exactly one matching response-language managed block per platform. It exits nonzero on failure and reports which platforms may need a restart or new session.

Use `-UserRoot <path>` with `install.ps1`, `verify.ps1`, or `update.ps1` to operate on an isolated profile during testing.

## Safely update an existing checkout

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\update.ps1
```

The updater requires:

- a clean worktree with no staged, unstaged, or untracked files;
- a named current branch with a configured upstream;
- no local commits ahead of or diverged from that upstream.

It fetches the configured upstream, fast-forwards without merging, runs the installer, runs the verifier, and reports the old and new `VERSION`. Before replacing a different existing global file, the installer creates and reports a side-by-side `*.backup-<timestamp>` copy. If any safety check or verification fails, the updater exits nonzero and identifies the blocker; it never switches branches, resets work, force-pushes, or publishes local commits.

## Optional project context contract

Projects may add a root-level `PROJECT_CONTEXT.yaml`; it is never required. Start from `PROJECT_CONTEXT.example.yaml` and validate the allowed shape against `PROJECT_CONTEXT.schema.json`.

Version 1 supports:

- `schema_version` and `project_name`;
- repository-relative arrays for status, handoff, plan, spec, and decision documents;
- verification commands, executed from the repository root when relevant and safe;
- a default branch and `git.publish_policy`;
- cautions and discovery exclusions.

Publishing policies are:

- `skill-default`: use the active skill version's normal contract;
- `explicit`: require a current explicit publish request before staging, committing, or pushing;
- `never`: prohibit automatic publishing unless the user's current instruction explicitly overrides it.

Document paths must remain inside the repository. Exclusions guide broad discovery and staging but cannot hide applicable instruction files, Git safety metadata, or explicitly configured documents. The configuration is routing and policy context, not completion evidence. When it is absent, automatic discovery works exactly as before; when it is invalid or unsupported, the skill reports the issue and falls back where safe.

## Invocation

| Action | Codex | Claude Code | Antigravity |
| --- | --- | --- | --- |
| Close and verify, no publish | `$wrap-up` | `/wrap-up` | `/wrap-up` |
| Close, verify, commit, and push | `$wrap-up publish` | `/wrap-up publish` | `/wrap-up publish` |
| Compatibility no-publish alias | `$wrap-up ncp` | `/wrap-up ncp` | `/wrap-up ncp` |
| Load project context | `$bootstrap` | `/bootstrap` | `/bootstrap` |
| Load context and start a task | `$bootstrap <task>` | `/bootstrap <task>` | `/bootstrap <task>` |

Plain `wrap-up`, `wrap-up publish`, `wrap-up ncp`, and `bootstrap` prompts are also described as implicit triggers. Explicit `$` or `/` invocation is the deterministic option.

Version 2 migration: Version 1 made plain `wrap-up` publish by default. Add the standalone `publish` argument to any existing prompt or automation that must still commit and push. Publication is blocked for detached HEAD, unresolved merges, branch-policy or destination ambiguity, uncertain file ownership, likely secrets, or failed mandatory checks. Resolve the reported blocker and invoke `wrap-up publish` again; never work around it with broad staging, force-push, reset, or discarded work.

Restart a platform if a newly created top-level skills directory does not appear in the current session. In Codex, inspect the skill list with `/skills`; Claude Code and Antigravity also expose a `/skills` view.

## Disable and re-enable

The universal reversible method is to rename each entry file from `SKILL.md` to `SKILL.md.disabled`. Rename it back to re-enable the skill, then restart the platform if its skill list does not refresh.

Codex also supports entries in `~/.codex/config.toml`:

```toml
[[skills.config]]
path = "C:/Users/User/.agents/skills/wrap-up/SKILL.md"
enabled = false

[[skills.config]]
path = "C:/Users/User/.agents/skills/bootstrap/SKILL.md"
enabled = false
```

Restart Codex after changing the file. Set `enabled = true` or remove the entries to re-enable the skills.

Claude Code supports `skillOverrides`. Merge this key into `~/.claude/settings.json` without overwriting other settings:

```json
{
  "skillOverrides": {
    "wrap-up": "off",
    "bootstrap": "off"
  }
}
```

Set a value to `"on"` or remove it to re-enable that skill. The `/skills` menu can also change visibility interactively.

Antigravity's public standalone-skill documentation does not currently define a persistent per-skill `enabled` field. Rename `SKILL.md` to `SKILL.md.disabled`, move the named skill folder outside `~/.gemini/antigravity/skills/`, or delete the installed copy. Keep this source bundle if you may want to restore it later.
