# Lint Package Invocation

Stage: `lint-package`

AOD-YAML: `{{AOD_YAML_FILENAME}}`

Companion context: `{{AOD_CONTEXT_FILENAME_OR_NONE}}`

Apply `stage_lint_package.md`. Use package mode when a context is supplied and
AOD-only mode for `None`; absence of an optional context is not a finding.
Create only the nonmutating Markdown report and response required by the stage,
then append the standard stage-completion menu required by `SKILL.md`.
