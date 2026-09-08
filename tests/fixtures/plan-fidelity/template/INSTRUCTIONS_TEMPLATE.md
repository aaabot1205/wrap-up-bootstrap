# Project instructions

This isolated fixture was last maintained through {{SOURCE_PLATFORM}} and is now being received through {{RECEIVER_PLATFORM}}.

- Invoke `wrap-up plan` and remain non-publishing.
- Use `PROJECT_CONTEXT.yaml`; its canonical plan is `{{PLAN_FILE}}`.
- {{SCENARIO_INSTRUCTION}}
- Keep the confirmed-plan markers in the canonical plan. Record progress, evidence, and status only in `{{STATUS_FILE}}`, `{{HANDOFF_FILE}}`, or outside the marked plan body.
- Ignore `UNCONFIRMED_DRAFT.md` as a plan source because it is explicitly unconfirmed.
- Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\verify.ps1` and record its current result.
- Preserve all fixture inputs and create no replacement documents, commits, or staged changes.
