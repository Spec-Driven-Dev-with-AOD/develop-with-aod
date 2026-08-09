# Lint Package Invocation

Stage: `lint-package`

AOD-YAML: `{{AOD_YAML_FILENAME}}`

Companion context: `{{AOD_CONTEXT_FILENAME_OR_NONE}}`

Locate the named artifacts in the workspace or user attachments and apply
`stage_lint_package.md`.

If a context file is supplied, perform a package lint. If the value is `None`,
perform an AOD-only lint without reporting the absent context as a finding. Do
not modify either input, generate application code, or create a corrected
package. Create the one Markdown report and final response required by the stage
procedure, then append the standard stage-completion menu required by `SKILL.md`.
