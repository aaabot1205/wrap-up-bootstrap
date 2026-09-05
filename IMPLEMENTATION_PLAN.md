# Implementation plan

This roadmap turns the currently usable cross-platform `wrap-up` and `bootstrap` skills into a versioned, verifiable, and portable maintenance system. The existing behavior remains the working baseline while the phases are delivered incrementally.

## Guiding principles

- Keep project documents project-owned and reusable across Codex, Claude Code, and Google Antigravity.
- Preserve backward compatibility until a behavior change is explicitly approved and released as a major version.
- Prefer optional project configuration over mandatory ceremony.
- Treat repository state, commands, tests, and diffs as evidence; never promote assumptions into verified facts.
- Keep installation and updates reversible, idempotent, and non-destructive toward unrelated user configuration.

## Phase 0: Baseline and policy decision

### Goal

Freeze the current working implementation as a recoverable baseline and decide how Git publishing should evolve.

### Deliverables

- Add a `VERSION` file with the current release number.
- Create a Git tag such as `v1.0.0` after the baseline is verified.
- Document the current command contract:
  - `bootstrap` loads project context without editing during context gathering.
  - `wrap-up` reconciles documentation, verifies, commits, and pushes.
  - `wrap-up ncp` reconciles and verifies without staging, committing, or pushing.
- Decide whether a future major release should make `wrap-up` non-publishing by default and reserve Git operations for `wrap-up publish`.

### Acceptance criteria

- All three platforms continue discovering both skills.
- The current behavior is documented and recoverable by version or tag.
- No default Git behavior changes without an explicit decision.

## Phase 1: Automated verification and updates

### Goal

Make installation health observable and make upgrades repeatable on another Windows machine.

### Deliverables

- Add `verify.ps1` to check:
  - all six installed skill entry files;
  - equality between canonical and installed skill files;
  - exactly one managed response-language block in each global rule file;
  - valid `SKILL.md` frontmatter and required trigger descriptions;
  - platforms that may require a restart.
- Add `update.ps1` to update the repository, back up affected global files, run `install.ps1`, run `verify.ps1`, and report the version transition.
- Add a small manifest or canonical hash set if it materially simplifies verification.

### Acceptance criteria

- Running `install.ps1` twice remains idempotent.
- `verify.ps1` reports all expected installations and rules accurately.
- Updating preserves unrelated skills and global instructions.

## Phase 2: Optional project context contract

### Goal

Let large projects identify their authoritative documents and verification commands without making a new file mandatory.

### Deliverables

- Define an optional root-level `PROJECT_CONTEXT.yaml` schema containing, as needed:
  - project name;
  - status, handoff, plan, spec, and decision-document paths;
  - verification commands;
  - default branch and Git publish policy;
  - project-specific cautions or exclusions.
- Add a documented example and schema version.
- Update both skills to prefer `PROJECT_CONTEXT.yaml` when present and retain automatic discovery when absent.

### Acceptance criteria

- Existing projects without `PROJECT_CONTEXT.yaml` continue working unchanged.
- A project started by one supported AI can be bootstrapped and wrapped up by either of the other platforms.
- The receiving platform updates the existing source of truth instead of creating platform-specific duplicates.

## Phase 3: Git publishing safety model

### Goal

Reduce accidental commits or pushes while keeping closeout convenient.

### Proposed command contract

- `bootstrap`: load context.
- `wrap-up`: update documentation and verify, without publishing.
- `wrap-up publish`: update, verify, commit, and push.
- `wrap-up ncp`: retain as a compatibility alias for the non-publishing mode.

### Required safeguards

- Inspect repository, branch, upstream, remote, diff, and staged files before publishing.
- Stage only files belonging to the completed phase.
- Detect likely credentials, secrets, `.env` files, and unrelated changes.
- Do not push when required verification fails unless the user explicitly overrides it.
- Never force-push, discard, reset, or silently include ambiguous user work.

### Migration

1. Keep the existing `v1.x` behavior.
2. Introduce and document `wrap-up publish` without changing the default.
3. Announce the proposed safer default.
4. Change the default only in `v2.0.0` after explicit approval.

### Acceptance criteria

- The compatibility behavior is unambiguous for every supported command.
- Publishing never includes unrelated or sensitive files.
- A failed publish reports the exact blocker and recovery action.

## Phase 4: Evidence quality and cross-platform regression tests

### Goal

Prevent multiple AI platforms from consistently propagating the same incorrect project claim.

### Deliverables

- Require closeout records to distinguish:
  - `Verified`: supported by an executed check;
  - `Observed`: directly visible in Git, configuration, or files;
  - `Assumption`: inferred but unverified;
  - `Not run`: expected check not executed;
  - `Blocked`: incomplete, with the reason recorded.
- Maintain isolated takeover fixtures for all six source-to-receiver platform directions.
- Test that each receiver continues the existing status, spec, and handoff files without creating replacements.

### Acceptance criteria

- Unexecuted checks are never reported as passed.
- Contradictory documents are reconciled when evidence is sufficient and called out when it is not.
- All takeover fixtures pass after behavioral changes.

## Phase 5: Cross-operating-system distribution

### Goal

Support repeatable installation beyond the current Windows environment.

### Deliverables

- Add `install.sh`, `verify.sh`, and `update.sh` for macOS and Linux.
- Add `CHANGELOG.md`, release notes, and rollback instructions.
- Publish versioned GitHub releases after validation.
- Confirm path handling for different home directories and existing user configuration.

### Acceptance criteria

- A new Windows, macOS, or Linux machine can install from the private repository with a short documented sequence.
- Reinstallation does not duplicate managed rules or remove unrelated configuration.
- A documented Git tag can be used to roll back.

## Recommended delivery order

1. Complete Phase 0.
2. Deliver Phase 1 and Phase 2 together as the next useful increment, tentatively `v1.1.0`.
3. Use the skills on several real projects and collect failure cases.
4. Make the Phase 3 policy decision from that evidence.
5. Add Phase 4 regression coverage before releasing behavior changes.
6. Start Phase 5 when macOS or Linux use becomes concrete.

## Next implementation action

Start a new session with `bootstrap`, execute Phase 0, and leave the existing `wrap-up` Git behavior unchanged until the publishing-policy decision is explicitly approved.
