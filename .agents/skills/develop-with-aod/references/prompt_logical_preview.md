# Logical Preview Invocation

Stage: `logical-preview`

AOD package artifacts:

- AOD-YAML: `{{AOD_YAML_FILENAME}}`
- Companion context: `{{AOD_CONTEXT_FILENAME}}`

Simulation policy for the logical preview: `{{PREVIEW_SIMULATION_POLICY_OR_BLANK}}`

Allowed values:

- `allow-visible-simulation`: visibly simulate contract responsibilities that a
  self-contained browser cannot satisfy so the declared workflow can be
  previewed.
- `prohibit-simulation`: use only capabilities that truthfully meet their
  contract success conditions in the browser and stop when that is impossible.

If the policy is blank or invalid, ask the user to select one value before
generation; never infer a default. The choice is logical-preview-only and must
not modify the AOD package or imply permission for the final implementation.

Locate and validate the package, then create exactly one complete self-contained
`.html` file in the current working directory under
`stage_logical_preview.md`. Respond only with its link. Then append the standard
stage-completion menu required by `SKILL.md`.
