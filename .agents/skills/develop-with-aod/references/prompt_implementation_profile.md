# Implementation Profile Invocation

Stage: `implementation-profile`

AOD package artifacts:

- AOD-YAML: `{{AOD_YAML_FILENAME}}`
- Companion context: `{{AOD_CONTEXT_FILENAME}}`

Project name: `{{PROJECT_NAME_OR_BLANK}}`

Existing profile to refresh: `{{EXISTING_IMPLEMENTATION_PROFILE_FILENAME_OR_NONE}}`

Existing experience brief: `{{EXISTING_AOD_EXPERIENCE_FILENAME_OR_NONE}}`

Non-secret UX, brand, content-guide, logo, or asset files:
`{{EXPERIENCE_RESOURCE_FILENAMES_OR_NONE}}`

Initial implementation preferences:
`{{INITIAL_IMPLEMENTATION_PREFERENCES_OR_BLANK}}`

Locate every named application artifact and follow
`stage_implementation_profile.md` exactly. Preflight first. If no project name was
explicitly selected or retained, ask `Project name` first; do not silently accept
a derived name. Ask exactly one unnumbered material question per turn. A follow-up,
partial answer, or future-topic choice leaves it pending. Use the standardized form;
`Accept` records the recommendation. After target selection, resolve the
experience-brief gate. Resolve portability before any host commitment and follow
the stage's portable-default technology-separation rules. Resolve
application-owned browser login and session security separately from account
lifecycle. Apply the stage's bounded self-containment, provisioning, readiness,
lifecycle, and effect rules without requesting secrets. Never infer consent or
simulation. Generate only after explicit confirmation.

Then validate `<project-slug>.aod-implementation.yaml` and, only when opted in,
`<project-slug>.aod-experience.md`. Use the package slug; do not modify the package
or resources or create code. Respond only with file links followed by the
standard stage-completion menu required by `SKILL.md`.
