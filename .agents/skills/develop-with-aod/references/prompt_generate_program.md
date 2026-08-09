# Generate Program Invocation

Stage: `generate-program`

Required application artifacts:

- AOD-YAML: `{{AOD_YAML_FILENAME}}`
- Companion context: `{{AOD_CONTEXT_FILENAME}}`
- Implementation profile: `{{AOD_IMPLEMENTATION_PROFILE_FILENAME}}`

Experience brief and non-secret resource files required by the profile:
`{{AOD_EXPERIENCE_FILENAME_AND_RESOURCE_FILENAMES_OR_NONE}}`

Compatible additional directions:
`{{ADDITIONAL_IMPLEMENTATION_DIRECTIONS_OR_NONE}}`

Locate every named artifact in the workspace or user attachments. Use `None` for
experience inputs only when the profile selects restrained defaults. Generate
and verify the complete runnable project under `stage_generate_program.md`.

Complete every integrity, behavioral, profile, experience, environment, and
closed-scope preflight before writing files. Stop on conflict, integrity failure,
a missing pinned experience input, an uncovered `ENV-nnn`, or incoherent
realization; do not weaken an input.

Check actual provisioning readiness against the profile without exposing
secrets. Materialize generated setup and derived configuration; do not recast
them as operator inputs. Separate unavailable host tools, genuine external
resources, and resumable generator steps. Preserve the profile's runtime
portability boundary; current-host verification must not bind portable output to
that machine or create unrelated remote-host prerequisites. Honor
lifecycle and live-effect policies. Never reset persistent data or perform a real external effect without required explicit confirmation.

Create the project under `project.slug` with realization and traceability
artifacts, verify it, and return only links, any applicable running URL, setup,
and verification status. Do not paste source code. Then append the standard
stage-completion menu required by `SKILL.md`.
