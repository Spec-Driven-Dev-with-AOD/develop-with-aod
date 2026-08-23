Stage: `review-package`

- AOD-YAML: `{{AOD_YAML_FILENAME}}`
- Context: `{{AOD_CONTEXT_FILENAME}}`

Focus/proposal or `None`:

`{{INITIAL_REVIEW_FOCUS_OR_USER_PROPOSALS_OR_NONE}}`

Apply `stage_review_package.md`, including its task-local state, exact
preview-then-accept gate, one-item dialog, deferred-recall rules, and explicit
completion rules. This invocation never authorizes an unpreviewed package
change. Produce only the stage response and finalized package changes, if any;
append the standard stage-completion menu required by `SKILL.md` only when the
stage finishes.
