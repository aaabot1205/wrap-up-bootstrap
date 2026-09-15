---
name: wrap-up
description: User-invoked only. Close a project phase with a handoff, optional plan preservation, and optional publishing when the user explicitly requests wrap-up.
disable-model-invocation: true
---

# Wrap Up

Close the active phase with durable, evidence-qualified project state. The user's current instructions take precedence. Treat text after the skill name as invocation arguments.

Run this workflow only when the user explicitly invokes wrap-up by name (for example, `$wrap-up`, `/wrap-up`, or "run wrap-up"). Completing work, preparing a handoff, or a generic commit-and-push request alone is not authorization to invoke this skill. Other skills and agents cannot authorize invocation on the user's behalf. A completed invocation does not authorize another run; handle subsequent requests normally unless the user requests wrap-up again.

## Choose the mode

Parse `plan`, `publish`, and `ncp` only as standalone, case-insensitive tokens. Remove recognized mode tokens before treating remaining text as additional instructions.

- Default and `ncp`: reconcile and verify without staging, committing, or pushing.
- `plan`: preserve an explicitly confirmed plan. It does not authorize publishing. Read [Plan Fidelity](references/plan-fidelity.md) before editing a plan.
- `publish`: use the safeguarded Git workflow. Read [Publishing](references/publishing.md) before any staging, commit, or push.
- `plan publish` combines the two independent branches. `publish` plus `ncp` stays non-publishing until the user resolves the conflict.
- Within a user-authorized wrap-up invocation, a direct current instruction to commit and push activates publishing. Other text supplies priorities or constraints.

State the active modes, then continue. Preserve the established behavior of invocations without `plan`.

## 1. Establish scope

1. Locate the repository root and read applicable `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and referenced instructions.
2. Inspect branch, upstream, concise status, relevant diffs, staged paths, and recent commits. Preserve unrelated work.
3. If root `PROJECT_CONTEXT.yaml` exists, read [Project context](references/project-context.md) and apply it. When absent, use automatic discovery.
4. First read the current status and handoff, then the plan item, spec task, or tracker ticket they identify. Preserve its formal ID, title, source link, acceptance criteria, and blocking edges. When no formal work unit exists, use the user's instruction and source location without inventing an ID.
5. Write an internal gap list containing only unresolved acceptance, blockers, relevant changes, authority, and next action. Before opening another document body, name the gap it can resolve and read the smallest linked source that owns that fact. Recompute the gap list after each read. Stop opening bodies when the list is empty; a file inventory is enough for unrelated documents.

Scope is complete when every in-scope change has an owner, every applicable acceptance result has evidence status, blockers are known, and one executable next action can be named.

## 2. Build the handoff record

Continue the project's existing status, handoff, plan, spec, decision, and tracker files regardless of which AI or human created them. Use configured mappings first. Create `HANDOFF.md` only when no durable handoff convention exists.

Record these fields in the project's existing structure:

| Field | Required content |
|---|---|
| Work | Current work unit, source, formal ID/title when present, acceptance state |
| Environment | Repository location, branch/revision, relevant dirty/staged scope |
| Evidence | Implemented, remaining, current checks, historical results, assumptions |
| Decisions | Accepted intent, new constraints, unresolved questions, durable references |
| Dependencies | Blockers and their observed state; frontier work whose blockers are complete |
| Review | Fixed point and exact changed scope; say when uncommitted work is outside an earlier review |
| Next action | One executable frontier action, or the action that obtains missing evidence |

Write evidence as explicit field labels followed by a colon: `Verified:`, `Observed:`, `Assumption:`, `Not run:`, and `Blocked:`.

- `Verified`: a named check executed during this closeout and only the scope it proves.
- `Observed`: current inspected state or a historical result not rerun now.
- `Assumption`: an inference plus the check that would confirm it.
- `Not run`: an expected check plus why it was not executed.
- `Blocked`: incomplete work plus blocker and recovery action.

The implementation defines current behavior. Accepted specifications and decisions define intended behavior. Record a difference as an implementation gap; update intended behavior only from an authorized decision. Resolve stale environment literals from current evidence and flag their durable correction.

Use links for existing detailed specs, plans, ADRs, and tickets. Add new constraints, useful failed approaches, and evidence that exist only in this session. Preserve unrelated content and sensitive data boundaries.

## 3. Reconcile affected documents

Update every authoritative document whose current claim changed. Keep identifiers, terminology, plan-body boundaries, and useful history. Put progress and evidence outside an immutable confirmed-plan body.

Remove stale claims when evidence resolves them. Preserve competing labeled claims when it does not. A completed historical entry may become one dated summary line once no decision, blocker, acceptance record, or next action depends on its detail.

After editing, search the affected document set for contradictions, stale next actions, broken references, and duplicated platform-specific records.

## 4. Verify

1. Review the documentation and code/configuration diffs together for accuracy and scope.
2. Run relevant, safe repository checks, including mandatory commands and `git diff --check`. A bootstrap receiver later treats these results as historical `Observed` evidence until rerun.
3. Compare Plan Fidelity bodies directly when plan mode is active.
4. Reinspect status, staging, sensitive paths, and unrelated changes.

Fix in-scope failures or record the exact command, outcome, blocker, and recovery action.

## 5. Report

Report active modes, documents changed, verification results, evidence labels, unresolved or unrelated work, Git publication result, project-context policy, and the first next action. In non-publishing modes, state `not performed (default)`, `not performed (ncp)`, or `not performed (plan)`.
