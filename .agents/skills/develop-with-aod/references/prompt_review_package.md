Stage: `review-package`

- AOD-YAML: `{{AOD_YAML_FILENAME}}`
- Context: `{{AOD_CONTEXT_FILENAME}}`

Focus/proposal or `None`:

`{{INITIAL_REVIEW_FOCUS_OR_USER_PROPOSALS_OR_NONE}}`

Run `stage_review_package.md`; preflight, preserve the task-local `BR-nnn` sequence,
and emit the next-identifier marker.

Keep one unresolved item. `Accept` applies only the prior active exact preview. A new
user package change becomes `User proposal | Pending`; an added request remains
pending. `Revise: ...` remains pending.

For `Accept deferred BR-nnn`, require a known same-task deferred BR. Revalidate; apply
under the same ID only if its semantic patch is unchanged, otherwise re-present it
pending. Fail closed for an unknown or nondeferred ID; infer and allocate nothing.

Do not reconfirm unambiguous behavior. Preserve unrelated semantic items verbatim and
in place. Show complete group-labeled current-draft diffs, complete other context
items, and per-ENV before/after tables with full `ID`, full `AOD reference`, and only
changed fields. No fragments, raw rows, or truncation.

Put behavior in AOD-YAML. Name independent policies; reject vague validity catch-alls;
keep atomic shared-state enforcement in the capability contract. A group split is the
sole editorial BR exception and still requires a complete preview and later `Accept`.

Apply accepted previews and lint drafts; add no unpreviewed material consequence.
Keep canonical files unchanged until finalization; preserve IDs, revision, and digest.
Run final lint and append the standard stage-completion menu required by `SKILL.md`.

With no reviewer proposal, show the prescribed open-review state. Only `Finish` or
`Discard all` terminates Stage 2; otherwise never infer completion or show the menu.

End every pending item with exactly this final line:

Reply `Accept`, `Accept deferred BR-nnn`, `Reject`, `Revise: ...`, `Defer`, `Discard all`, `Finish`, or ask a follow-up question.

Never substitute `Modify`, bold options, omit/reorder an option, or append text.
`Discard all` leaves both canonical package files untouched and makes newly issued BRs ineligible
for `Accept deferred BR-nnn`.
