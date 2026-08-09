# Create Package Invocation

Stage: `create-package`

Optional human-readable project name: `{{PROJECT_NAME_OR_BLANK}}`

Optional project slug: `{{PROJECT_SLUG_OR_BLANK}}`

Natural-language application description:

`{{NATURAL_LANGUAGE_APPLICATION_DESCRIPTION}}`

Create and validate the compact two-file AOD package required by
`stage_create_package.md`. Follow its complete staged generation, lint, triage,
re-lint, context, and package-validation workflow.
Use cohesive reading-concern groups, precise validity rules, and atomic capability
contracts where mutable-state eligibility must still hold at effect success.

If the slug is blank, derive it from the project name. If both are blank,
automatically derive a meaningful project name and slug from the application's
primary domain and purpose; never use a generic placeholder. Create
`<project-slug>.aod.yaml` and `<project-slug>.aod-context.md`.

Create only the two final package files in the current working directory. Do not
deliver the intermediate specification, lint result, application code, or another
explanatory file. Return links and the required concise design, lint-decision,
assumption, and residual-concern summary; do not paste either artifact. Then
append the standard stage-completion menu required by `SKILL.md`.
