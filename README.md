# Develop with AOD

`develop-with-aod` is a Codex skill for specification-driven application
development using
[Attainment-Oriented Declarations (AOD)](.agents/skills/develop-with-aod/references/aod_yaml_model_summary.md).
AOD combines the declarative construction principle familiar from low-code
development with an open, application-specific path vocabulary. Paths,
standing determining declarations, concept bindings, and reaction contexts
provide a constrained and inspectable behavioral structure without prescribing
the target technology.

The skill implements an AOD-based behavioral specification process. It turns
natural-language intent into an AOD package comprising a `*.aod.yaml`
specification and a companion `*.aod-context.md` file containing its environment
contract, material design decisions, assumptions, and residual concerns. The
package can be reviewed and linted before implementation choices are selected
through an implementation profile and a program generator realizes the declared
behavior. The AOD user retains control over behavioral intent and business
decisions, while the generator handles much of the technical realization.

The skill currently uses **Interpretive AOD**. Its declarations may contain
controlled natural language, so semantic tooling can surface materially
different interpretations and require clarification, but it cannot generally
prove the absence of all material ambiguity. Model judgment and subsequent
verification therefore remain necessary. The AOD package remains the principal
behavioral input, while implementation choices are recorded separately. Using
an LLM for generation does not imply that the generated application requires an
LLM at runtime.

The AOD model permits controlled implicit path declarations. Framework packages
use a stricter authoring profile: every inferred or assumed path must also occur
in an AOD-YAML entry. The skill adds a declaration-only bare entry such as
`- P` when the path is not already explicit as a given entry, trigger, or target;
this changes neither AOD behavior nor environment responsibilities.

## Workflow

| Stage | Purpose |
| --- | --- |
| `create-package` | Create a linted `*.aod.yaml` specification and `*.aod-context.md`. |
| `review-package` | Review and revise a lint-clean AOD package. |
| `lint-package` | Lint an AOD package without changing it. |
| `logical-preview` | Preview declared behavior in self-contained HTML with nonbinding presentation. |
| `implementation-profile` | Select technologies, provisioning, deployment, and experience policies. |
| `generate-program` | Generate and verify the final program from the confirmed artifacts. |

Numeric aliases `1` through `6` select these stages in the listed order.

## Install

Codex discovers repository skills under `.agents/skills` and personal skills
under `$HOME/.agents/skills`. Clone this repository, then either retain its
`.agents/skills/develop-with-aod` directory in a working repository or copy that
directory into your personal skills directory.

For a repository-local installation in PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path '<workspace>/.agents/skills' | Out-Null
Copy-Item -Recurse -Force `
  './.agents/skills/develop-with-aod' `
  '<workspace>/.agents/skills/'
```

Start a new Codex task after installation so the skill is discovered.

## Use

Invoke the skill without a stage to open its stage menu:

```text
$develop-with-aod
```

Or select a stage directly:

```text
$develop-with-aod Stage: create-package
```

The skill asks for one missing input or decision at a time. See
[`docs/aod_user_workflow.md`](docs/aod_user_workflow.md) for the complete user
workflow.

## Repository Contents

- `.agents/skills/develop-with-aod/`: the complete Codex skill
- `docs/aod_user_workflow.md`: user-oriented workflow description
- `docs/maintainers/aod_instruction_architecture.md`: instruction ownership and maintenance guidance
- `tools/check_aod_instruction_consistency.ps1`: deterministic consistency checks for the instruction package

Run the maintainer check from the repository root:

```powershell
& ./tools/check_aod_instruction_consistency.ps1
```

## License

Licensed under the Apache License, Version 2.0. See [`LICENSE`](LICENSE) and
[`NOTICE`](NOTICE).
