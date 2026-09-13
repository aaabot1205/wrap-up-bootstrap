# Project context

Load this reference only when a root-level `PROJECT_CONTEXT.yaml` exists.

- Support `schema_version: 1`. Treat document paths, verification commands, default branch, publishing policy, cautions, and exclusions as routing and policy, not completion evidence.
- Resolve configured paths against the repository root. Reject paths that escape it. Update listed status, handoff, plan, spec, and decision files in place.
- Run configured verification commands from the repository root when relevant and safe.
- Compare the current branch with `git.default_branch`; never switch merely to match it. A publishing-time mismatch is `Blocked` until explicitly resolved.
- `skill-default` uses the Version 2 non-publishing default. `explicit` requires current publish authorization. `never` blocks publishing unless the current instruction explicitly overrides that policy.
- Respect exclusions during discovery, editing, staging, and publishing. Applicable instructions, Git safety metadata, and explicitly listed documents remain visible.
- For malformed data, unsupported versions, unsafe paths, or missing documents, report the exact issue and use automatic discovery where safe. Keep the file unchanged.
