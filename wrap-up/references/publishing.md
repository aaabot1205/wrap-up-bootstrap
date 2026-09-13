# Publishing

Load this reference only after current authorization activates publishing.

1. Reinspect named branch, upstream, remote URL, concise status, unstaged diff, staged names, staged diff, and merge state. Detached HEAD, branch-policy mismatch, ambiguous remote, and unresolved merge state are `Blocked`.
2. Build an explicit path list for completed current-work-unit changes and documentation. Establish ownership of every candidate and pre-existing staged path. Ambiguous ownership is `Blocked`.
3. Scan candidate paths and diffs for secrets without exposing values. Exclude `.env`, private keys, credentials, tokens, secret-bearing connection strings, and generated local files by default. Review examples explicitly. Report path and risk category only.
4. Require mandatory checks to pass. A `publish` request does not override failure; proceed only after the user sees the exact failure and explicitly authorizes the override.
5. Stage explicit paths only. Preserve pre-existing staging. If this workflow must unstage its own paths, name those exact paths and preserve worktree content.
6. Inspect complete staged names and diff again. Stop on unrelated, ambiguous, generated, or sensitive material.
7. Create one descriptive commit unless convention requires otherwise. Do not create an empty commit.
8. Push the current named branch to its configured upstream. With no upstream, set one only when the request authorizes one unambiguous `origin`. Never force-push or rewrite history.
9. Verify commit ID, destination, push result, upstream state, and remaining worktree status.

If permissions, hooks, authentication, or repository state block publication, complete safe prior steps and report the blocker and recovery command.
