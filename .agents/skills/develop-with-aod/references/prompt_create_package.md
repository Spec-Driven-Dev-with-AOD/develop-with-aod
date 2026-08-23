# Create Package Invocation

Stage: `create-package`

Optional human-readable project name: `{{PROJECT_NAME_OR_BLANK}}`

Optional project slug: `{{PROJECT_SLUG_OR_BLANK}}`

Natural-language application description:

`{{NATURAL_LANGUAGE_APPLICATION_DESCRIPTION}}`

Apply `stage_create_package.md`. Treat blank naming fields as delegated naming,
not missing input. If the application description is absent or too empty to
support the stage, request it and stop. Otherwise create only the two validated
package artifacts and the response required by the stage, then append the
standard stage-completion menu required by `SKILL.md`.
