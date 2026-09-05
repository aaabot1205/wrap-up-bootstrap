---
name: wrap-up
description: Close the current project phase and leave a reliable cross-session, cross-platform handoff. Use whenever the user says or types `wrap-up`, asks to wrap up, close out, finish a milestone, prepare a handoff, synchronize project documentation, or commit and push completed work, including when ChatGPT/Codex, Claude, Gemini, or Antigravity created the existing files. A trailing `ncp` means update and reconcile documentation but do not stage, commit, or push.
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

- Default: reconcile project documentation, verify the completed work, commit the scoped changes, and push the current branch.
- `ncp`: reconcile and verify documentation, but do not stage, commit, or push anything. A standalone, case-insensitive `ncp` in the trailing arguments selects this mode; exclude that token from the user's additional instructions.
- Treat all other trailing text as additional priorities or constraints. If it explicitly changes Git behavior, follow it.

State the selected mode briefly, then continue without asking for confirmation unless a genuinely consequential choice cannot be inferred safely.

## 1. Establish scope and evidence

1. Locate the project or repository root. Read applicable agent instruction files before editing, including `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and instruction files referenced by them.
2. Inspect the current branch, upstream, concise status, relevant diffs, and recent commits. Do not fetch, switch branches, stash, reset, discard, or overwrite work merely to make the tree clean.
3. Separate current-phase changes from unrelated pre-existing work. Preserve unrelated changes and never include them in a commit. If ownership cannot be established, leave the ambiguous files untouched and call them out.
4. Use observable repository state, configuration, tests, and diffs as evidence. Never mark work complete or claim verification without support.

## 2. Discover the documentation system

Do not assume one platform's filenames or create parallel ChatGPT/Codex, Claude, Gemini, and Antigravity documentation sets. Discover the project's existing conventions and identify every relevant durable artifact, including:

- current-state and handoff files such as `HANDOFF.md`, `STATUS.md`, `*_STATUS.md`, TODO, milestone, or progress documents;
- plans, requirements, product or technical specs such as `*_SPEC.md`, PRDs, RFCs, ADRs, and roadmaps;
- architecture, operational, setup, testing, deployment, changelog, and `README` documentation;
- agent instruction files when commands, conventions, or architecture recorded there actually changed.

Follow links between documents and search for references to changed features, old statuses, superseded decisions, commands, paths, or names. Prefer updating the existing source of truth. If no durable current-state or handoff artifact exists and repository conventions do not specify another location, create a concise root-level `HANDOFF.md`.

## 3. Reconcile facts across documents

Create a compact internal fact set covering: goal, completed work, current behavior, decisions, verification, remaining work, blockers, risks, and next action. Then update all documents whose claims are affected.

- Distinguish implemented, verified, in progress, planned, blocked, and deferred work explicitly.
- Update checklists, milestone state, acceptance results, commands, links, file paths, interfaces, and architecture descriptions that changed.
- Preserve useful history and project-specific structure. Do not replace detailed specs with summaries or perform broad cosmetic rewrites.
- Record unresolved issues honestly, with enough context for the next session to act.
- Remove or qualify stale claims. Do not invent decisions, dates, owners, test results, or completion percentages.
- Keep the handoff concise and actionable: current state, what changed, verification, decisions, remaining tasks in priority order, blockers/risks, and the exact next recommended action.

After editing, search the relevant documentation set again for contradictions and stale terminology. Resolve inconsistencies instead of merely listing them when the evidence is sufficient.

## 4. Verify the closeout

1. Review the documentation diff for factual accuracy, broken internal links, malformed Markdown, accidental scope expansion, and consistency with the code/configuration diff.
2. Run the best available non-destructive checks relevant to the completed work, favoring commands documented by the repository. Use a focused subset when the full suite is unavailable or disproportionately expensive.
3. Run whitespace/diff checks supported by the repository, including `git diff --check` in Git projects.
4. Recheck concise status. Ensure no generated secrets, credentials, local-only files, or unrelated changes are about to be committed.

Fix in-scope failures when feasible. Otherwise record the exact command, outcome, and reason it remains unresolved.

## 5. Finish Git operations

Skip this entire section in `ncp` mode.

1. Stage only the completed current-phase work and the documentation updates. Never use a broad staging command when it would include unrelated changes.
2. Inspect the staged diff and confirm it is coherent and contains no sensitive data.
3. Create one descriptive commit unless repository conventions require another structure. If a relevant commit already exists and the worktree contains no scoped changes, do not create an empty commit.
4. Push the current branch to its configured upstream. If it has no upstream but an unambiguous `origin` exists, set the upstream for the current named branch. Never force-push.
5. Verify the resulting commit identifier, upstream destination, push result, and remaining worktree state.

If commit or push is impossible because of permissions, hooks, authentication, detached HEAD, missing remote, or ambiguous files, complete every safe prior step and report the exact blocker and recovery command. Do not falsely report success.

## 6. Report completion

Return a compact closeout containing:

- selected mode;
- documents updated or created and the consistency issues resolved;
- verification commands and results;
- commit identifier and push destination, or `not performed (ncp)`;
- remaining unrelated or unresolved changes;
- the first action the next session should take.
