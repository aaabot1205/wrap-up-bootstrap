# Cross-platform session skills

This bundle contains two skills based on the open `SKILL.md` format:

- `wrap-up`: reconcile project documentation, verify the phase, commit, and push.
- `bootstrap`: load durable project context and prepare or begin the next task.

## Global installation locations

| Platform | Global skill directory |
| --- | --- |
| Codex | `~/.agents/skills/<skill-name>/` |
| Claude Code | `~/.claude/skills/<skill-name>/` |
| Google Antigravity IDE | `~/.gemini/antigravity/skills/<skill-name>/` |

Copy both `wrap-up/` and `bootstrap/` folders into each platform directory. Keep each `SKILL.md` directly inside its named folder.

## Invocation

| Action | Codex | Claude Code | Antigravity |
| --- | --- | --- | --- |
| Full closeout | `$wrap-up` | `/wrap-up` | `/wrap-up` |
| Docs only, no commit/push | `$wrap-up ncp` | `/wrap-up ncp` | `/wrap-up ncp` |
| Load project context | `$bootstrap` | `/bootstrap` | `/bootstrap` |
| Load context and start a task | `$bootstrap <task>` | `/bootstrap <task>` | `/bootstrap <task>` |

Plain `wrap-up`, `wrap-up ncp`, and `bootstrap` prompts are also described as implicit triggers. Explicit `$` or `/` invocation is the deterministic option.

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
