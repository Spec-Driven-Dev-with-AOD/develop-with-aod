# Implementation Profile Invocation

Stage: `implementation-profile`

- AOD-YAML: `{{AOD_YAML_FILENAME}}`
- Companion context: `{{AOD_CONTEXT_FILENAME}}`
- Project name: `{{PROJECT_NAME_OR_BLANK}}`
- Existing profile: `{{EXISTING_IMPLEMENTATION_PROFILE_FILENAME_OR_NONE}}`
- Existing experience brief: `{{EXISTING_AOD_EXPERIENCE_FILENAME_OR_NONE}}`
- Experience resources: `{{EXPERIENCE_RESOURCE_FILENAMES_OR_NONE}}`
- Initial preferences: `{{INITIAL_IMPLEMENTATION_PREFERENCES_OR_BLANK}}`

Apply `stage_implementation_profile.md`. Resolve missing material decisions only
through its adaptive one-question dialog and generate artifacts only after its
explicit confirmation gate. Create only the validated profile, any opted-in
experience brief, and the stage response, then append the standard
stage-completion menu required by `SKILL.md`.
