# AOD Context Format

`aod_context_format.md` defines the companion context format for an AOD-YAML specification. It governs the structure and meaning of `*.aod-context.md` files.

## Purpose and Artifact Boundary

An implementation-ready, platform-independent AOD package consists of:

1. `<project-slug>.aod.yaml`, which is authoritative for application behavior, paths, definitions, bindings, reaction contexts, and attainment targets; and
2. `<project-slug>.aod-context.md`, which records the design rationale and the environment contract required to interpret and implement that behavior.

`<project-slug>` is the package's canonical filesystem-safe name: lowercase kebab-case matching `[a-z0-9]+(?:-[a-z0-9]+)*`. The same slug is later used for `<project-slug>.aod-implementation.yaml` and the generated `<project-slug>.aod-traceability.yaml`. It is distinct from the human-readable project name. At initial package creation, use an explicitly supplied slug; otherwise derive it from an explicit project name or, when no name was supplied, from a concise meaningful name synthesized from the application's primary domain and purpose. Do not use a generic placeholder such as `aod-spec`, `application`, `project`, or `untitled` for an automatically derived slug.

The context metadata also identifies and protects the two-file package. It declares the package format and revision, the AOD profile, and the exact-byte SHA-256 digest of the companion AOD-YAML file. This detects an AOD file that has changed without a corresponding context revision.

The environment contract states what the environment must supply, observe, preserve, or accomplish and what counts as successful environment-backed attainment. It does not add application behavior. A reaction, state change, binding, or business-relevant effect that is absent from the AOD-YAML cannot be introduced by the context file.

The context file is platform-independent. It must not select frameworks, programming languages, databases, cloud products, deployment technology, or concrete service vendors. Those choices belong in an AOD implementation profile. It must never contain passwords, tokens, keys, connection strings, or other secret values.

## Filename

Derive the context filename from the AOD-YAML filename:

- `<project-slug>.aod.yaml` becomes `<project-slug>.aod-context.md`.

The context file must name its companion AOD-YAML file exactly. A package filename that does not follow this convention is invalid.

## Package Identity and Integrity

Use these identifiers:

- package format `aod-package/v1`;
- AOD profile `aod-yaml/v1`; and
- context format `aod-context/v1`.

For a new package, generate one lowercase UUID as its package ID and set its revision to `1`. Preserve the package ID across revisions. Increment the positive integer revision whenever either package file is intentionally changed, including a standalone or inline nonbehavioral AOD comment or a context wording change.

Compute the AOD specification digest from the exact bytes of the final AOD-YAML file after it has been written. Represent it as `sha256:` followed by exactly 64 lowercase hexadecimal characters. Never invent or estimate a digest. A package whose recorded digest does not match the attached AOD-YAML file is invalid.

## Required Structure

Use exactly these top-level sections in this order:

```markdown
# AOD Context: <application name>

- Package format: `aod-package/v1`
- Package ID: `<lowercase UUID>`
- Package revision: `<positive integer>`
- AOD profile: `aod-yaml/v1`
- Context format: `aod-context/v1`
- AOD specification: `<AOD-YAML filename>`
- AOD specification digest: `sha256:<64 lowercase hexadecimal characters>`

## Key Design Ideas
<compact bullets or `None.`>

## Design Decisions
<compact bullets or `None.`>

## Environment Contract
| ID | AOD reference | Environment responsibility | Success condition | Provisioning boundary | Basis |
| --- | --- | --- | --- | --- | --- |
| ENV-001 | `<path or Q -> P>` | <what must be supplied, observed, preserved, or accomplished> | <when the value is resolvable or the target is successfully attained> | <abstract provider boundary> | <user-stated, AOD-required, or generator-assumed> |

## Assumptions
<compact bullets or `None.`>

## Residual Concerns
<compact bullets or `None.`>
```

Do not add an implementation plan, generated code, lint report, prompt transcript, or duplicate copy of the AOD-YAML.

`Design Decisions` records only material application-specific choices traceable to the user's intent or explicit acceptance. Do not list consequences imposed by the AOD model, AOD-YAML profile, framework package profile, context format, lint rules, or mechanical package maintenance, such as occurrence-versus-startup semantics, unordered reaction targets, model-permitted implicit declarations, framework-required bare-entry normalization, or conformance repairs. When a rationale mixes an application choice with framework mechanics, retain only the application-specific choice.

`Design Decisions` and `Assumptions` must be semantically disjoint. In a newly generated context, prefix an assumption recording a material unaccepted behavior introduced while authoring AOD with `Authoring assumption:` and identify its AOD references; this records why the behavior entered the package even though AOD-YAML now declares it unambiguously. Prefix a genuinely additional environment-contract interpretation with ``Contract assumption for `ENV-nnn`:``. Do not use one assumption to serve both roles implicitly. After the user explicitly accepts an authoring assumption, remove it from `Assumptions` and, when still context-worthy, record it under `Design Decisions`.

For an existing `aod-context/v1` package, accept `Decisions After Linting` as a deprecated legacy heading rather than rejecting the package. New packages must use `Design Decisions`; when a legacy context is otherwise intentionally revised, rename the heading as a nonsemantic migration and account for the context revision. Under `Residual Concerns`, prefix a materially important rejected inference with `Deliberately excluded:` and a deliberately unresolved matter with `Deferred/unspecified:`. Do not list every optional feature that was considered and rejected; record only points that clarify a plausible material downstream inference.

## Environment Contract Coverage

Create one stable `ENV-nnn` item for every material environment responsibility implied by the user's intent or the final AOD-YAML, including where applicable:

- values supplied or otherwise resolved by the environment;
- observable user-interface, user, scheduler, host, or integration occurrences;
- material observation semantics, including standing values versus accepted valued observations, source or cadence, declared startup occurrences, and replay or redelivery behavior;
- current-user, session, view-instance, selected-item, row-instance, authorization, identity, or other context-sensitive resolution, including material ownership, partition, capture, lifetime, and isolation boundaries;
- persistence, persisted-set membership, persisted queries, and write-through updates;
- environment-backed attainment targets such as `.Persisted`, `.Sent`, `.Deleted`, or `.Notified`;
- standing definitions that an environment capability must resolve on demand;
- semantic bridges such as a successfully persisted new binding becoming a member of `all persisted <Entity>`;
- runtime-presence or timing requirements, such as a scheduler that must operate while clients are closed; and
- material success, non-attainment, durability, security, retry, idempotency, transaction, or failure requirements explicitly required by the user or behavior.

Do not create contract items for purely internal standing calculations or ordinary AOD syntax that need no environment support. Do not convert an optional operational improvement into a provided guarantee.

A recognized concept binding, a concept-rooted or binding-relative constituent inferred under the model, and a standing definition instantiated through that binding are AOD semantics and do not by themselves require separate contract rows. The framework-required bare entries that expose such paths remain declaration-only and likewise create no contract row by themselves. Add contract coverage only for environment support that their resolution, observation, attainment, persistence, or identity bridge actually requires. In particular, binding `P` as concept `T` does not establish persisted-set membership; when an explicit persistence target must place `P` in `all persisted T`, its contract row must preserve the bound value's identity and constituents and make that same value a member of the persisted collection.

The contract table may contain no data rows only when the final AOD-YAML and stated user requirements genuinely imply no material environment responsibility.

Every material environment dependency in the AOD-YAML must be covered by an `ENV-nnn` item, and every `ENV-nnn` item must be traceable to the AOD-YAML or a clearly identified user requirement. An item may cite several AOD references only when they share the same responsibility, success condition, and provisioning boundary.

## Contract Fields

### ID

Use unique identifiers `ENV-001`, `ENV-002`, and so on. On initial generation, assign them in the order of the first relevant AOD reference. When revising an existing context, preserve an identifier while its responsibility remains materially the same and allocate a new identifier for a new responsibility.

### AOD reference

Use exact path names and, for capability uses, compact causal references such as ``Decision.Persisted -> Decision.Notified``. List every distinct reaction context that directly uses the same environment capability; do not report only its first use. References may be separated by semicolons within one cell.

Technical support that is not itself a behavioral attainment may reference the affected construct, such as `all persisted Task`, `TaskItem.Task.Completed` write-through, or `User.Current`.

### Environment responsibility

State one concise responsibility in implementation-neutral language. Describe what the environment must supply, observe, preserve, resolve, or accomplish. Do not restate the whole business workflow.

### Success condition

State the condition under which the environment-provided value is resolvable or an environment-backed target is successfully attained:

- a supplied value succeeds when a valid value for the path is available in the required context;
- an observable occurrence succeeds when that occurrence has actually been observed;
- a valued observation succeeds once per accepted measurement or value and preserves that value throughout its causal reaction chain;
- a resultative capability succeeds only when the represented effect or state has actually been achieved under the stated guarantee;
- persistence succeeds only after the required storage, durability, acknowledgment, and persisted-set membership conditions hold; and
- failure or an unavailable partial binding leaves the target unattained unless the AOD explicitly declares separate failure behavior.

Do not silently strengthen `accepted for processing` into `delivered`, best-effort storage into durable persistence, or an inferred capability into a guaranteed one. If the needed success standard is not stated, use the weakest coherent assumption and record it under `Assumptions` or `Residual Concerns` as appropriate.

When material, state how an observable source supplies observations and whether replay or redelivery is possible. Separately accepted equal-valued observations and accepted replay deliveries remain distinct occurrences under the AOD model. Do not silently deduplicate them. A cadence required by the intended behavior must be declared in AOD; only a cadence deliberately left to the provider belongs solely in the contract. Initial standing resolution during operational startup is not an observation. Any application behavior triggered by startup must already be expressed through a startup occurrence declared in AOD-YAML; the contract may state how and when the environment supplies that occurrence but must not introduce it.

For a context-sensitive path or binding, state the applicable owner or partition, resolution or maintenance context, capture point, lifetime, and isolation or sharing boundary when materially different interpretations would change behavior. For example, an environment responsibility may maintain one selection per authenticated user and view instance for that view's lifetime, while its success condition captures the selected item when a click is observed and preserves that binding throughout the resulting reaction chain. The contract may describe environment-provided resolution, maintenance, capture, lifetime, and isolation, but a behaviorally significant scope boundary must already be stated by the AOD declarations.

### Provisioning boundary

Name only the abstract boundary expected to provide the responsibility, for example `user interaction`, `authenticated host`, `application runtime`, `persistent storage`, `scheduler`, `external notification service`, or `unspecified implementation environment`. Do not select a technology or vendor.

### Basis

Use one or more of:

- `user-stated` for a responsibility or guarantee directly required or explicitly confirmed by the user;
- `AOD-required` for support necessarily implied by an AOD path, declaration, binding, or reaction; and
- `generator-assumed` for a reasonable but unstated interpretation.

Basis classifies the authority of each specific contract claim, not the provenance of the corresponding AOD behavior. Environment support necessarily implied by explicit AOD is `AOD-required` even when the AOD behavior entered the package through an authoring assumption. Never add `generator-assumed` merely because AOD uses controlled natural language, implementation requires judgment, or a generator originally selected the behavior.

`AOD-required` and `generator-assumed` may coexist in one row only when `generator-assumed` identifies a genuinely additional inseparable contract point that is not entailed by AOD. Name it as a contract assumption under `Assumptions` and identify the affected `ENV-nnn` row. Split separable contract claims with different bases into separate `ENV-nnn` rows. If no distinct additional claim exists, use `AOD-required` without `generator-assumed`.

Every material `generator-assumed` contract point must appear exactly once as a contract assumption. Do not restate behavior already unambiguously declared by AOD as a contract assumption; this does not prohibit an authoring assumption from recording that behavior's provenance. Unresolved risks or guarantees that remain intentionally absent belong under `Residual Concerns`, not in the contract as if they were provided. A downstream generator must treat a matter identified as unspecified or residual as a no-inference boundary: it may preserve the limitation, but it must not silently select a business rule, guarantee, or externally observable policy that resolves it.

## Compactness and Readability

Write for a citizen developer. Prefer direct language such as "store the new request durably and make it queryable as a persisted VacationRequest" over infrastructure jargon. Keep one responsibility per row, combine only genuinely identical uses, and keep design ideas, design decisions, assumptions, and residual concerns short. The file should make the AOD package easier to understand, not reproduce the specification in prose.
