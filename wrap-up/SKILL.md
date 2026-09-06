---
name: wrap-up
description: Close the current project phase and leave a reliable cross-session, cross-platform handoff. Use whenever the user says or types `wrap-up`, asks to wrap up, close out, finish a milestone, prepare a handoff, synchronize project documentation, or explicitly publish completed work, including when ChatGPT/Codex, Claude, Gemini, or Antigravity created the existing files. By default it reconciles and verifies without Git publishing; a trailing `publish` enables a safeguarded scoped commit and push, while `ncp` remains a non-publishing compatibility alias.
---

# Wrap Up

Close the active phase completely and leave the repository safe for a new AI session.

The user's current instructions take precedence over this workflow. Treat text after the skill name as invocation arguments. On hosts that expand it, the raw arguments are: `$ARGUMENTS`.

## Preserve cross-platform continuity

Treat every durable project document as project-owned, never AI-platform-owned. The current agent must continue from relevant files created or last updated by ChatGPT/Codex, Claude, Gemini, Antigravity, a human, or any other tool.

- Discover documents by purpose, links, content, and repository conventions rather than by the current platform's preferred filename.
- Update the existing source of truth in place, preserving its useful structure, terminology, decision history, and level of detail.
- Do not ignore a file because another platform usually creates it. For example, Claude must continue an existing `AGENTS.md`, `STATUS.md`, spec, or handoff when it contains relevant project state; Codex and Antigravity must likewise continue relevant `CLAUDE.md` or `GEMINI.md` material.
- Separate shared project facts from platform-specific behavioral instructions. Carry shared facts forward; apply platform-specific instructions only when they are applicable to the current host and scope.
- Do not create a second platform-native status, spec, plan, or handoff merely because the current agent would normally use a different name.
- When duplicate or conflicting documents already exist, determine the authoritative one from repository guidance, links, recency, accepted decisions, and live evidence. Reconcile all affected documents or record the unresolved ownership conflict explicitly.

## Choose the mode

- Default: reconcile project documentation and verify the completed work without staging, committing, or pushing.
- `publish`: a standalone, case-insensitive `publish` token explicitly requests the safeguarded scoped commit-and-push workflow. Exclude the token from the user's additional instructions.
- `ncp`: retain as a case-insensitive compatibility alias for the non-publishing default. If `publish` and `ncp` conflict, remain non-publishing and report the conflict unless the user resolves it explicitly.
- Treat a direct current instruction to commit and push as publish authorization, and a direct instruction not to publish as non-publishing. Treat all other trailing text as additional priorities or constraints.
- After locating the repository, apply a valid root `PROJECT_CONTEXT.yaml` Git policy: `skill-default` uses the Version 2 non-publishing default; `explicit` still requires current publish authorization; `never` blocks publishing even when `publish` is present unless the user explicitly says to override that policy. Never silently broaden publishing authority.

State the selected mode briefly, then continue without asking for confirmation unless a genuinely consequential choice cannot be inferred safely.

## 1. Establish scope and evidence

1. Locate the project or repository root. Read applicable agent instruction files before editing, including `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and instruction files referenced by them.
2. Inspect the current branch, upstream, concise status, relevant diffs, and recent commits. Do not fetch, switch branches, stash, reset, discard, or overwrite work merely to make the tree clean.
3. Separate current-phase changes from unrelated pre-existing work. Preserve unrelated changes and never include them in a commit. If ownership cannot be established, leave the ambiguous files untouched and call them out.
4. Use observable repository state, configuration, tests, and diffs as evidence. Never mark work complete or claim verification without support.

### Qualify evidence

Use these exact labels for material claims in durable status, handoff, acceptance, and closeout records, and in the completion response. Fit them into the project's existing structure instead of rewriting every sentence mechanically.

- `Verified`: supported by a check executed during the current closeout. Name the command or check and its result.
- `Observed`: read directly from current Git state, configuration, source, or another inspected artifact, but not proven by an executed check.
- `Assumption`: inferred and still unverified. State what would confirm or reject it.
- `Not run`: an expected check was not executed. Name the check and why it was skipped or unavailable.
- `Blocked`: work or verification is incomplete. State the blocker and the concrete recovery action.

Never turn a plan, user claim, or earlier document into `Verified` evidence. Treat a prior session's recorded pass as an `Observed` historical result unless the current closeout reruns it. Label only the scope a check actually proves; do not use one passing check to verify a broader milestone. When evidence is insufficient to reconcile a contradiction, retain the competing claims with their labels instead of choosing silently.

## 2. Load optional project context

Check for a root-level `PROJECT_CONTEXT.yaml` before broader document discovery.

- If it is absent, continue with automatic discovery and the existing command contract unchanged.
- If it is present, read it fully and support `schema_version: 1`. Treat its repository-relative document paths, verification commands, default branch, publishing policy, cautions, and exclusions as authoritative routing and policy context, not as evidence that work is complete.
- Resolve every configured path against the repository root and reject paths that escape it. Update listed status, handoff, plan, spec, and decision files in place; do not create platform-specific replacements.
- Run configured verification commands from the repository root when they are relevant and safe. Record any command not run and why.
- Compare the current branch with `git.default_branch`; never switch branches merely to match it. Treat a publishing-time mismatch as a blocker unless the user explicitly resolves it.
- Respect exclusions during discovery, editing, staging, and publishing unless the user's current request requires an excluded path. Never let an exclusion hide applicable instruction files, Git safety metadata, or an explicitly listed document.
- If the file is malformed, uses an unsupported schema version, contains unsafe paths, or points to missing files, report the exact issue and fall back to automatic discovery where safe. Do not silently treat an invalid file as absent or rewrite it without authorization.

## 3. Discover the documentation system

Use valid `PROJECT_CONTEXT.yaml` document mappings first when present. Do not assume one platform's filenames or create parallel ChatGPT/Codex, Claude, Gemini, and Antigravity documentation sets. Discover other relevant durable artifacts, including:

- current-state and handoff files such as `HANDOFF.md`, `STATUS.md`, `*_STATUS.md`, TODO, milestone, or progress documents;
- plans, requirements, product or technical specs such as `*_SPEC.md`, PRDs, RFCs, ADRs, and roadmaps;
- architecture, operational, setup, testing, deployment, changelog, and `README` documentation;
- agent instruction files when commands, conventions, or architecture recorded there actually changed.

Follow links between documents and search for references to changed features, old statuses, superseded decisions, commands, paths, or names. Prefer updating the existing source of truth. If no durable current-state or handoff artifact exists and repository conventions do not specify another location, create a concise root-level `HANDOFF.md`.

## 4. Reconcile facts across documents

Create a compact internal fact set covering: goal, completed work, current behavior, decisions, verification, remaining work, blockers, risks, and next action. Then update all documents whose claims are affected.

- Distinguish implemented, verified, in progress, planned, blocked, and deferred work explicitly.
- Update checklists, milestone state, acceptance results, commands, links, file paths, interfaces, and architecture descriptions that changed.
- Preserve useful history and project-specific structure. Do not replace detailed specs with summaries or perform broad cosmetic rewrites.
- Record unresolved issues honestly, with enough context for the next session to act.
- Remove or qualify stale claims. Do not invent decisions, dates, owners, test results, or completion percentages.
- Keep the handoff concise and actionable: current state, what changed, verification, decisions, remaining tasks in priority order, blockers/risks, and the exact next recommended action.

After editing, search the relevant documentation set again for contradictions and stale terminology. Resolve inconsistencies instead of merely listing them when the evidence is sufficient.

## 5. Verify the closeout

1. Review the documentation diff for factual accuracy, broken internal links, malformed Markdown, accidental scope expansion, and consistency with the code/configuration diff.
2. Run the best available non-destructive checks relevant to the completed work, favoring commands documented by the repository. Use a focused subset when the full suite is unavailable or disproportionately expensive.
3. Run whitespace/diff checks supported by the repository, including `git diff --check` in Git projects.
4. Recheck concise status. Ensure no generated secrets, credentials, local-only files, or unrelated changes are about to be committed.

Fix in-scope failures when feasible. Otherwise record the exact command, outcome, and reason it remains unresolved.

## 6. Publish only with explicit authorization

Skip this entire section in the default and `ncp` modes.

1. Reinspect the repository, named branch, configured upstream, exact remote URL, concise status, unstaged diff, staged names, and staged diff. Do not guess or change the destination. Treat detached HEAD, branch-policy mismatch, ambiguous remote, or unresolved merge state as blockers.
2. Build an explicit candidate path list containing only completed current-phase work and its documentation. Positively establish ownership of every candidate and every pre-existing staged path. Leave unrelated work untouched; block publishing if staged or candidate ownership is ambiguous.
3. Scan candidate filenames and diffs for sensitive material without exposing values. Do not stage `.env`, `.env.*`, private keys, credentials, tokens, secret-bearing connection strings, or generated local-only files by default. Review example/template environment files explicitly. Use repository secret scanners when available. Report only the path and risk category when blocking.
4. Require all mandatory verification to pass before publication. A `publish` request alone does not override a failed check. Proceed after failure only when the user sees the exact failure and explicitly authorizes that override; record it in the closeout.
5. Stage the explicit path list only. Never use `git add .`, `git add -A`, `git commit -a`, or another broad shortcut. Do not disturb pre-existing staging. If a problem is found after staging files staged solely by this workflow, unstage only those exact paths and preserve their worktree content.
6. Inspect staged names and the complete staged diff again. Confirm scope, coherence, and absence of sensitive data. Stop before committing if anything is unrelated, ambiguous, generated, or risky.
7. Create one descriptive commit unless repository conventions require another structure. If a relevant commit already exists and no scoped changes remain, do not create an empty commit.
8. Push the current named branch to its configured upstream. If it has no upstream but one unambiguous `origin` exists and the publish request authorizes that destination, set the upstream for the current branch. Never force-push or rewrite published history.
9. Verify the commit identifier, exact remote destination, push result, upstream state, and remaining worktree status.

If commit or push is impossible because of permissions, hooks, authentication, detached HEAD, missing remote, or ambiguous files, complete every safe prior step and report the exact blocker and recovery command. Do not falsely report success.

## 7. Report completion

Return a compact closeout containing:

- selected mode;
- documents updated or created and the consistency issues resolved;
- verification commands and results;
- commit identifier and push destination, or `not performed (default)`, `not performed (ncp)`, or the exact policy/blocker;
- active `PROJECT_CONTEXT.yaml` publishing policy and any configuration issues;
- an evidence summary using the exact labels above, including every expected check that was not run or remained blocked;
- remaining unrelated or unresolved changes;
- the first action the next session should take.
