# Skill continuity implementation evidence

Date: 2026-09-14
Review fixed point: `a902c18a69c3dfe32bee9d56b66b63ce3c6b6f9a`

This report maps the approved IP-01 through IP-06 proposal to the repository implementation and isolated evidence. Raw agent traces, snapshots, and temporary Git repositories remain local under `.scratch/skill-continuity/evidence/` and `.scratch/skill-continuity/runs/`.

| Scope | Result | Evidence |
|---|---|---|
| IP-01 baseline | Verified with limitations | Frozen canonical skill trees and hashes; A/B producer and fresh receiver runs; untouched-checker and snapshot negative controls. Host skill discovery prevented a strict no-skill runtime, so A is a no-target-body control. |
| IP-02 bootstrap frontier | Verified / minimal change | Existing bootstrap behavior recovered the exact next work and treated inherited verification as historical. Only the discovery description changed; fresh receivers in all six directed fixtures selected the correct release frontier and changed no file, index, HEAD, branch, ref, remote, or status entry. |
| IP-03 durable handoff | Verified | Default wrap-up producers in all six directions reconciled current versus intended state, recorded explicit evidence labels, preserved review scope, and passed the canonical takeover checker. |
| IP-04 conditional bundle | Verified | Default `wrap-up` routes plan, publishing, and project-context details to three conditional references. Independent package testing copies each skill alone and rejects a missing linked reference. Five fresh wording samples stopped once the named gap list was empty. |
| IP-04 discovery | Verified with bounded scope | Five fresh frontmatter-only samples correctly selected bootstrap, wrap-up, or neither for positive, comparison-only, and reference-only prompts. Descriptions retain model invocation and two-field frontmatter. Global installation passed; host-native UI discovery after restart was not rerun. |
| IP-05 safety | Verified for isolated fixtures | Takeover and Plan Fidelity each passed all six directions. Confirmed bodies matched source, unconfirmed cases preserved baseline, and replay kept one provenance preface. Local bare-remote cases verified lowercase/uppercase publish, `PUBLISH NCP` non-publication, and mandatory-check failure with unchanged refs/index. Historical branch, scope, `never`, and invalid-context cases remain `Observed` because their governing behavior was unchanged and they were not rerun. |
| IP-05 cost | Partially verified | Baseline `wrap-up/SKILL.md`: 17,251 chars / 2,440 whitespace words. Candidate main: 6,046 / 856; candidate with all references: 10,347 / 1,451. Main-entry chars fell 65.0%; full package chars fell 40.0%. Runtime tokens, cache costs, and a comparable five-cycle token median are `Not run` because no tokenizer/runtime accounting was available; no token claim is made. |
| IP-06 review and closeout | Verified | Standards and Spec reviewers compared all 35 implementation files from fixed point `a902c18a69c3dfe32bee9d56b66b63ce3c6b6f9a`. After correction rounds, both reported no remaining P0-P3 findings. Global synchronization and live verification passed; the authorized `2.4.0` release is in progress. |

## Mechanical checks

- `test-regressions.ps1 -Mode Check`: 6 passed, 0 failed on fresh producer workspaces.
- Six fresh bootstrap receivers preserved complete pre/post snapshots.
- `test-plan-fidelity.ps1 -Mode Check`: 6 passed, 0 failed.
- Confirmed-plan replay: unchanged SHA-256 `AC6924D12143A8863F400DC704A52836FC0492C54AE4756B5D4D84278E175951`; provenance, begin marker, and end marker each occur once.
- Explicit publish fixture: commit `1148a89c255a1e0f2d2ffe67ebeff9b3dbd40895`; local and bare-remote `main` match; commit contains exactly `STATUS.md`, `HANDOFF.md`, and `RESULT.txt`; index/worktree clean.
- Uppercase `PUBLISH` created scoped commit `06cefb32ea7d6b35638e6afe3ea066ed526a7c82`; `PUBLISH NCP` left refs and index unchanged; an intentional mandatory-check failure exited 1 and left refs/index unchanged.
- Five fresh description-only samples: positive bootstrap, positive closeout, positive publish, negative comparison, and negative reference all routed correctly.
- `test-update.ps1`: passed after selecting the newest reachable tag whose `VERSION` differs, while retaining real fast-forward, backup/hash, dirty-worktree, and ahead-of-upstream assertions.
- `test-installation.ps1`: passed with independent current and legacy Antigravity paths.
- `test-skill-packaging.ps1`: passed and rejected a missing required reference.

## Limits and deferred operations

- The six directions are portable fresh-agent tests, not host-native executions inside all three products.
- Global synchronization is `Verified`: backups use timestamp `20260914-013140`, and live verification reported 27 passes with no warnings or failures.
- Host-native discovery after restarting all three products is `Not run`; the `2.4.0` release commit, tag, and pushes are authorized and pending.
