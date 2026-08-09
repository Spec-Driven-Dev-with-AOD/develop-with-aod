# AOD Skill Instruction Architecture

This file defines ownership boundaries for the reusable AOD prompt system. It is
maintainer guidance outside the active skill and is not loaded into application
workflow tasks.

The repo-local skill is rooted at `.agents/skills/develop-with-aod/`. `SKILL.md`
owns stage selection, same-task workflow continuation, stage-completion
navigation, progressive reference loading, authority order, and the rule that
bundled framework references are never requested from the user.

## Canonical Sources

| Concern | Sole manual authority under `references/` |
| --- | --- |
| AOD model and AOD-YAML syntax and semantics | `aod_yaml_model_summary.md` |
| AOD context, package metadata, and environment contract | `aod_context_format.md` |
| Optional experience brief and restrained presentation defaults | `aod_experience_format.md` |
| Shared lint procedure, findings, and severities | `aod_yaml_lint_rules.md` |
| Implementation-profile structure | `aod_implementation_profile.schema.json` |
| Implementation-traceability semantics and coverage | `aod_traceability_format.md` |
| Implementation-traceability structure | `aod_traceability.schema.json` |

Change a shared rule only in its canonical source. A stage procedure may state a
concise implementation consequence or task-specific acceptance criterion, but it
must not reproduce a grammar, semantic reference section, context format, or
schema.

## Stage Procedures

| Stage | Task-specific authority under `references/` |
| --- | --- |
| Generate and lint an AOD package | `stage_create_package.md` |
| Review and revise an AOD package and its business design | `stage_review_package.md` |
| Produce a standalone lint report | `stage_lint_package.md` |
| Produce a one-file logical and behavioral HTML preview | `stage_logical_preview.md` |
| Conduct the implementation-profile dialog | `stage_implementation_profile.md` |
| Generate the final program | `stage_generate_program.md` |

These files own stage workflow, task-specific decisions, response bodies,
artifact output contracts, and verification only. `SKILL.md` owns the shared
stage-completion navigation footer. High-risk semantic consequences may be
emphasized where a generator must compile them, but the canonical source remains
authoritative.

## Invocation Contracts

Each `prompt_*.md` is a lean skill-internal invocation contract. It supplies
dynamic application input or policy and states essential stop and output
conditions without duplicating its stage procedure. It preserves the shared
completion-menu handoff to `SKILL.md` and does not list canonical framework files
as user attachments.

`SKILL.md` loads these sets before application-specific input:

| Stage | Bundled references |
| --- | --- |
| `create-package` | model summary, context format, lint rules, stage procedure, invocation contract |
| `review-package` | model summary, context format, lint rules, stage procedure, invocation contract |
| `lint-package` | model summary, context format, lint rules, stage procedure, invocation contract |
| `logical-preview` | model summary, context format, stage procedure, invocation contract |
| `implementation-profile` | model summary, context format, experience format, profile schema, stage procedure, invocation contract |
| `generate-program` | model summary, context format, experience format, traceability format and schema, stage procedure, invocation contract |

Do not create concatenated copies of these sources merely to call them bundles.
That would restore duplicated artifacts and increase static prompt input. Add a
reference to only those stage load sets that require it.

## Non-Skill Material

The user workflow stays in `docs/aod_user_workflow.md`; the research paper stays
under `paper/`. Historical material under `archive/`, transcripts, and test
examples are not active instruction sources. They must not be loaded as hidden
authority by the skill.

## Maintenance Check

After changing an active model, format, rule, schema, stage procedure, invocation
contract, skill router, or metadata file, run:

```powershell
./tools/check_aod_instruction_consistency.ps1
```

The check verifies skill structure and routing, required references, canonical
content boundaries, schema parsing, Markdown fences, ASCII, invocation-contract
size, and total static payload budgets. A legitimate expansion may require an
intentional budget update, but shared semantics must remain in their canonical
source.
