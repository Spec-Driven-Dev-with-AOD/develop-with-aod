# Logical Preview Invocation

Stage: `logical-preview`

- AOD-YAML: `{{AOD_YAML_FILENAME}}`
- Companion context: `{{AOD_CONTEXT_FILENAME}}`

Simulation policy: `{{PREVIEW_SIMULATION_POLICY_OR_BLANK}}`

Apply `stage_logical_preview.md`. Require either `allow-visible-simulation` or
`prohibit-simulation`; if the value is blank or invalid, request one value and
stop. Create only the validated self-contained HTML preview and stage response,
then append the standard stage-completion menu required by `SKILL.md`.
