# Plan Fidelity

Load this reference only when standalone, case-insensitive `plan` is active.

1. Select the configured plan path, otherwise the existing canonical plan. Use root `IMPLEMENTATION_PLAN.md` only when no convention exists. Multiple unresolved owners are `Blocked`.
2. Select only the latest plan whose exact text the user explicitly confirmed in the current conversation or in a durable record that contains both the confirmation and complete text. AI drafts and summaries are not sources.
3. Replace only a clearly bounded confirmed-plan body. Preserve its character sequence exactly: wording, identifiers, numbering, hierarchy, order, owners, dependencies, acceptance criteria, whitespace, newlines, Unicode, and formatting.
4. Keep progress, verification, status, and commentary outside the body. Repeating the same preservation must not change the body or accumulate provenance.
5. For a new or unattributed body, add one preface outside its boundary with source, confirmation date, and executing platform/model when known. Do not update the preface with progress.
6. Compare the written body directly with its exact source using ordinal character equality. If source text, confirmation, destination, or boundaries are unavailable, leave the body unchanged and record `Blocked` with the missing evidence and recovery action.
