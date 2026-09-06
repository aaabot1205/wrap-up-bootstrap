---
name: bootstrap
description: Bootstrap a new AI coding session by loading the current project's instructions, plans, status, specs, handoff, Git state, architecture, verification commands, risks, and next task across AI platforms. Use whenever the user says or types `bootstrap`, asks to initialize or resume project context, continue from a previous ChatGPT/Codex, Claude, Gemini, or Antigravity session, understand a repository before working, or take over the next task.
---

# Bootstrap

Build a trustworthy, compact operating picture of the current project before continuing work.

The user's current instructions take precedence over this workflow. Treat text after the skill name as invocation arguments. On hosts that expand it, the raw arguments are: `$ARGUMENTS`. Use any non-empty trailing text as the requested follow-on task after bootstrapping.

## Preserve cross-platform continuity

Treat durable context as project-owned, never AI-platform-owned. Continue from relevant documents regardless of whether ChatGPT/Codex, Claude, Gemini, Antigravity, a human, or another tool created them.

- Discover documents by purpose, links, content, and repository conventions, not by the current platform's preferred filenames.
- Read relevant `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, status, spec, plan, decision, and handoff files even when their names originated with another platform.
- Separate shared project facts and decisions from platform-specific behavioral instructions. Retain the former; apply the latter only when relevant to the current host and directory scope.
- Preserve the existing source-of-truth hierarchy. Do not bootstrap from a newly invented platform-native document or imply that another platform's valid handoff is unusable.
- If multiple platforms left overlapping or contradictory records, resolve their factual claims against repository guidance and live evidence, then identify which file should be maintained at the next `wrap-up`.

## 1. Locate and obey project guidance

1. Determine the workspace and repository root without assuming the current directory is the root.
2. Read applicable instruction files first, including `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and instruction files they reference. Respect their directory scope and precedence.
3. Do not modify files during the bootstrap phase. Do not fetch, pull, switch branches, stash, reset, install dependencies, or run destructive commands merely to gather context.

## 2. Load optional project context

After locating the root, check for a root-level `PROJECT_CONTEXT.yaml` before broader document discovery.

- If it is absent, continue with automatic discovery unchanged.
- If it is present, read it fully and support `schema_version: 1`. Treat its repository-relative document paths, verification commands, default branch, publishing policy, cautions, and exclusions as authoritative routing and policy context, not as proof that planned work is implemented or verified.
- Resolve every configured path against the repository root. Reject paths that escape it. Read listed status, handoff, plan, spec, and decision files first, then use targeted discovery to find relevant unlisted context.
- Respect exclusions during broad searches and avoid reading excluded content unless the user's current request requires it. Never let an exclusion hide applicable instruction files, Git metadata needed for safety, or a path explicitly listed under `documents`.
- Recognize `git.publish_policy` values `skill-default`, `explicit`, and `never`. Record the active value in the brief; do not perform Git publishing during bootstrap context gathering.
- If the file is malformed, uses an unsupported schema version, contains unsafe paths, or points to missing files, report the exact issue and fall back to automatic discovery where safe. Do not silently treat an invalid file as absent or invent replacement paths.

## 3. Inspect live state

If the project uses Git, inspect at minimum:

- current branch, upstream, ahead/behind information available locally, and concise worktree status;
- relevant unstaged and staged diffs, including untracked filenames without exposing secrets;
- recent commits sufficient to understand the latest milestone and direction.

Treat uncommitted changes as important handoff context. Never assume they belong to the current session, discard them, or describe the tree as clean without checking.

Inspect the project structure, primary configuration and manifests, entry points, and documented test/build/run commands. Keep exploration targeted; avoid reading large generated, vendored, cache, dependency, or binary trees.

## 4. Discover and read the durable context

Use valid `PROJECT_CONTEXT.yaml` document mappings first when present. Otherwise find the project's actual documentation conventions instead of relying on one platform's standard names. Prioritize:

1. current-state and handoff artifacts such as `HANDOFF.md`, `STATUS.md`, `*_STATUS.md`, TODO, milestone, and progress files;
2. active plans, requirements, specs, PRDs, RFCs, ADRs, and roadmaps;
3. root and component `README` files, architecture docs, changelogs, and operational/setup/testing/deployment docs;
4. recent source and tests needed to verify claims that affect the next task.

Follow document links when they are relevant. Do not load every document indiscriminately. Search for the active feature, milestone, pending checklist items, blockers, and terminology in the handoff.

## 5. Reconcile conflicts

Do not repeat documentation claims as facts without checking them against live repository evidence. Use this default priority when sources conflict:

1. the user's current instruction;
2. applicable repository instructions;
3. observable worktree, configuration, source, tests, and recent commits;
4. explicit accepted decisions and specifications;
5. current status or handoff documents;
6. general prose and older README content.

Treat planned behavior as planned, not implemented. Identify stale or contradictory documentation explicitly. Make a reasonable evidence-based interpretation when safe; ask only when the ambiguity would materially change the requested work.

### Qualify evidence

Use these exact labels for material claims in the bootstrap brief and preserve them when reading or continuing durable records:

- `Verified`: supported by a check executed during the current bootstrap. Name the command or check and its result.
- `Observed`: read directly from current Git state, configuration, source, or another inspected artifact.
- `Assumption`: inferred and still unverified; state how to test it.
- `Not run`: an expected check was not executed; name it and explain why.
- `Blocked`: work or verification is incomplete; state the blocker and recovery action.

Treat a previous session's `Verified` item as an `Observed` historical result until it is rerun. Never upgrade a plan, inherited claim, or configuration declaration to `Verified`. Apply each label only to the scope its evidence supports. If evidence cannot resolve a contradiction, report the competing labeled claims instead of selecting one silently.

## 6. Produce the bootstrap brief

Before starting any follow-on task, give a concise brief containing:

- project purpose and current milestone;
- applicable instructions and important conventions;
- branch, worktree, and recent-change state;
- what is completed and what is verified;
- in-progress and remaining tasks in priority order;
- important decisions, architecture, commands, and acceptance criteria;
- blockers, risks, unknowns, and documentation conflicts;
- `PROJECT_CONTEXT.yaml` status, active Git policy, and any configured verification commands or exclusions;
- evidence-qualified material claims using the exact labels above, including expected checks that were not run or are blocked;
- the exact recommended next action.

Use file references and evidence where helpful. Keep the brief dense enough to act on but short enough to preserve context for the work.

## 7. Continue or hand off control

- If the invocation has a follow-on task, begin it after the brief, following normal safety and repository rules. Do not stop merely to ask whether to proceed when the request is already clear.
- If no follow-on task is supplied, stop after the brief and state that the project is ready to continue from the recommended next action.
- Do not repair documentation during a bootstrap-only invocation. Report inconsistencies for a later `wrap-up` or an explicit documentation task.
