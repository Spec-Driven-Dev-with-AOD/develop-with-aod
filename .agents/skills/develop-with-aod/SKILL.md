---
name: develop-with-aod
description: Develop applications from idea to verified program using Attainment-Oriented Declarations (AOD).
---

# Develop With AOD

Perform exactly one AOD workflow stage per invocation. A task may contain
successive stage invocations. The skill bundles the framework instructions and
canonical references; the user supplies only the application intent and any
application-specific artifacts required by the selected stage.

## Select The Stage

Use one of these stage identifiers:

| Choice | Stage | Purpose |
| --- | --- | --- |
| `1` | `create-package` | Turn natural-language intent into a linted `*.aod.yaml` and companion `*.aod-context.md`. |
| `2` | `review-package` | Optionally challenge and revise the business design of a lint-clean AOD package. |
| `3` | `lint-package` | Produce a standalone lint report without changing the package. |
| `4` | `logical-preview` | Generate a self-contained HTML preview of AOD behavior with nonbinding presentation. |
| `5` | `implementation-profile` | Conduct the adaptive dialog that selects the implementation and optional experience guidance. |
| `6` | `generate-program` | Generate and verify the final program from the confirmed AOD package and implementation profile. |

Accept `1` through `6` as aliases for the corresponding stage identifiers. Also
accept `review-design` as a compatibility alias for `review-package` and
`preview` as a compatibility alias for `logical-preview`. If the user
names a stage, use it. With `Stage: auto`, infer the stage only when
the request and available artifacts make it unambiguous. A natural-language app
idea with no package means `create-package`; a direct request to lint, review,
logical preview, preview, profile, or implement selects the corresponding stage.
If the user only invokes the skill, leaves placeholders unresolved, or asks
ambiguously between stages, ask one concise question using this Markdown
structure:

```markdown
**Choose The AOD Stage**

1. `create-package` - Create an AOD package from an application idea.
2. `review-package` - Review and revise a lint-clean AOD package.
3. `lint-package` - Lint an AOD package without changing it.
4. `logical-preview` - Preview AOD behavior in self-contained HTML; presentation is nonbinding.
5. `implementation-profile` - Choose technologies and implementation policies.
6. `generate-program` - Generate the final program.

**Recommended:** `1` when starting from an application idea.

Reply with the number or stage name, or ask a follow-up question.
```

Treat stage selection as its own dialog turn. When showing this menu,
ask only for the stage; do not also ask for the application goal, filenames, artifacts,
or another decision. After the user selects a stage, ask for exactly one next
missing stage input. For `create-package`, request the natural-language
application goal first. For stages `2` through `6`, request the required existing
artifact or stage-specific decision instead; do not require a separate program
goal unless that stage genuinely needs clarification. If the user's initial
message already supplies a clear stage and its required input, proceed without
asking for either again. A concrete application goal without an existing package
unambiguously selects `create-package`.

Complete one stage at a time. Continue with the next stage in the same task by
default, explicitly naming the stage. A reply containing a menu number or stage
name names that stage; the user need not repeat the skill name. Start a fresh
task only when an independent review is desired, the existing conversation has
become long or confusing, or a clean implementation context would be
beneficial.

When `review-package` is invoked repeatedly in the same task, continue its
task-local `BR-nnn` sequence as defined by `stage_review_package.md`; completing
or discarding a review does not reset it. A fresh task starts a fresh sequence.
Within that same task, `Accept deferred BR-nnn` recalls only a known deferred
proposal under the validation rules in `stage_review_package.md`; it never
guesses an unknown, nondeferred, or discarded identifier.
An active `review-package` stage completes only through an explicit `Finish` or
`Discard all`; an empty reviewer backlog does not complete the stage.

Do not silently continue into another stage. Keep corrections, follow-up
questions, and an adaptive dialog within the current stage. A follow-up after
completion does not select another stage.

## Complete The Stage

A stage is complete only after its required artifacts, validation, and response
content have been produced. Then present the stage-specific links and summary
required by its procedure and append this navigation footer:

```markdown
**Stage Complete**

`<completed-stage>` completed.

**Choose The Next Stage**

1. `create-package` - Create, revise, or recreate an AOD package. <status>
2. `review-package` - Review and revise a lint-clean AOD package. <status>
3. `lint-package` - Lint an AOD package without changing it. <status>
4. `logical-preview` - Preview AOD behavior in self-contained HTML; presentation is nonbinding. <status>
5. `implementation-profile` - Choose technologies and implementation policies. <status>
6. `generate-program` - Generate the final program. <status>

**Recommended:** `<number and stage, or Stop>` - <one concise reason>.

Reply with the number or stage name, ask a follow-up question, or stop here.
```

Keep all six choices visible. Replace each `<status>` with a concise marker such
as `Completed`, `Available`, `Optional`, `Requires <artifact>`, or `Stale` based
on the artifacts and validation state. Recommend exactly one contextually useful
next stage when work remains; after a complete and verified program, recommend
`Stop` unless a concrete unresolved item points elsewhere. Common transitions
are `create-package` to optional `review-package`, an accepted package to
`implementation-profile`, and a confirmed profile to `generate-program`.
Recommend `lint-package` when package integrity is uncertain or files were
manually changed.

Do not show this completion footer while the current stage is waiting for input,
has stopped on a blocker, or remains unfinished. If the user asks a follow-up
after completion, answer it without advancing and show the menu again when it
remains useful. The footer is conversational navigation, not a generated
artifact, and is permitted in addition to every stage-specific response.

## Load The Stage Bundle

Read every listed file completely before acting. Resolve paths relative to this
`SKILL.md`.

### `create-package`

1. `references/aod_yaml_model_summary.md`
2. `references/aod_context_format.md`
3. `references/aod_yaml_lint_rules.md`
4. `references/stage_create_package.md`
5. `references/prompt_create_package.md`

### `review-package`

1. `references/aod_yaml_model_summary.md`
2. `references/aod_context_format.md`
3. `references/aod_yaml_lint_rules.md`
4. `references/stage_review_package.md`
5. `references/prompt_review_package.md`

### `lint-package`

1. `references/aod_yaml_model_summary.md`
2. `references/aod_context_format.md`
3. `references/aod_yaml_lint_rules.md`
4. `references/stage_lint_package.md`
5. `references/prompt_lint_package.md`

### `logical-preview`

1. `references/aod_yaml_model_summary.md`
2. `references/aod_context_format.md`
3. `references/stage_logical_preview.md`
4. `references/prompt_logical_preview.md`

### `implementation-profile`

1. `references/aod_yaml_model_summary.md`
2. `references/aod_context_format.md`
3. `references/aod_experience_format.md`
4. `references/aod_implementation_profile.schema.json`
5. `references/stage_implementation_profile.md`
6. `references/prompt_implementation_profile.md`

### `generate-program`

1. `references/aod_yaml_model_summary.md`
2. `references/aod_context_format.md`
3. `references/aod_experience_format.md`
4. `references/aod_traceability_format.md`
5. `references/aod_traceability.schema.json`
6. `references/stage_generate_program.md`
7. `references/prompt_generate_program.md`

## Apply Authority And Inputs

Within a stage, apply the bundle in the listed authority order, followed by the
application-specific artifacts and explicit user decisions identified by the
stage procedure. Canonical model, format, lint, and schema references outrank the
stage procedure; the procedure outranks its invocation contract. Application
intent may select behavior but cannot redefine AOD semantics.

Never ask the user to attach a bundled framework reference. Mentions of attached
files inside stage procedures refer to application-specific package, profile,
experience, or resource files. Locate named artifacts in the current workspace
or ask for a missing required application artifact according to the stage's
preflight and stop rules.

Do not treat `docs/`, `paper/`, `archive/`, `transcripts/`, `tests/`, or repository
history as hidden instruction authority. They may be inspected only when the user
explicitly asks for maintenance, examples, research, or historical comparison.

Use `scripts/get_aod_file_digest.ps1` when an exact AOD-YAML digest must be
computed or refreshed. Preserve every preflight, dialog, closed-scope, lifecycle,
effect-safety, traceability, validation, file-output, and final-response
constraint in the selected stage procedure.
