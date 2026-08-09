# AOD-YAML Lint Rules

`aod_yaml_lint_rules.md` defines the shared inspection and finding policy for AOD-YAML. It does not redefine the model or context format.

## Authority and Modes

1. `aod_yaml_model_summary.md` is the sole authority for AOD model and AOD-YAML syntax and semantics.
2. `aod_context_format.md` is the sole authority for `*.aod-context.md` structure and meaning.
3. This file governs lint procedure, severities, and required analysis data.

Use **AOD-only mode** for one `*.aod.yaml` file. Use **package mode** when its companion `*.aod-context.md` is supplied. An absent context is not a finding in AOD-only mode unless the calling workflow explicitly requires a package.

## Procedure

### 1. Parse and Inventory

Parse the complete AOD-YAML with a YAML parser that preserves node types and source locations and detects duplicate keys. Do not install dependencies or use network access merely to obtain a parser. If no suitable parser exists, disclose the best-effort fallback and do not issue an unqualified `PASS`.

Treat standalone and inline YAML comments as presentation-only. Exclude both forms from path and reference extraction, semantic inference, capability discovery, environment-contract assessment, and findings about application behavior. A `#` character inside quoted or block-scalar content remains scalar content according to YAML parsing and is not a comment. Linting is nonmutating and must not use comment text as behavioral evidence.

Without treating groups as scopes, inventory:

- every declared path and location;
- every standing and contextual definition and conservatively extracted path reference;
- every reaction context and target;
- every inferred declaration, projection, constituent path, semantic bridge, and environment capability, with all use sites, inference basis, and confidence;
- the standing-definition dependency graph; and
- the reaction graph from each context to each target.

Distinguish likely path references from quoted text, concept names, and ordinary words. When controlled natural language appears to reuse an application concept from AOD path vocabulary, treat matching spelling and capitalization, such as `new Task` for `Task`, as supporting evidence rather than formal type syntax or proof. If a different spelling or capitalization leaves a material relation unclear, report the uncertainty rather than silently infer it. Expose uncertainty rather than inventing structure.

### 2. Audit the Complete AOD Model

Validate every applicable rule in every section of `aod_yaml_model_summary.md`. The audit must explicitly cover:

| Model area | Required lint focus |
| --- | --- |
| YAML Profile | YAML validity, root and group shape, reading-concern cohesion, stable local grouping, compact grammar, node types, nonempty lists, unique keys, paths, and unsupported presentation features. |
| Paths, Declarations, and Definitions | Path-segment validity, target roles, conflicts, ambiguous overlaps, and distinction between declarations and definitions. |
| Context Semantics | Given versus reaction context, standing dependencies, target resolvability and attainability, unordered targets, data versus causal dependency, and meaningful follow-on contexts. |
| Occurrence Instances and Reaction Invocations | Standing versus occurrence roles, observation source and cadence, repeated attainment, startup, replay, stable payloads and bindings, context-sensitive ownership, partition, capture, lifetime and isolation, invocation isolation, and shared persistent state. |
| Attainment and Non-Attainment | Actual success before follow-ons, valued and resultative attainment, structured constituent paths, partial bindings, and non-attainment. |
| Given Paths and Initialization | Mistaken startup or universal initialization and correct instance scoping. |
| Implicit Declarations | Accepted implicit paths, unclear sources or projections, and every inferred capability use without demands for redundant declarations. |
| Natural-Language Declarations and Binding | One coherent result of the right role, statement-like syntax, self-reference, semantic compactness, vague catch-alls, hidden independent policies, avoidable helpers, stable row or singleton bindings, equivalent wording, canonicalization, and controlled semantic bridges. |
| Effects and Environment Capabilities | Represented state versus effectful environment capability, every causal capability use, on-demand inputs, observational eligibility versus atomic enforcement, write-through versus persistence acknowledgment, success or failure boundaries, and unsupported operational guarantees. |
| Recursion and Progress | Definition cycles, reaction cycles, credible progress, termination or partial non-attainment, and order-independent recursion. |

For each reaction target, identify the declaration, binding, write-through relation, observable mechanism, or environment capability that makes attainment possible. Report an unclear mechanism; never invent one. Report irreducible standing-definition cycles unless a coherent fixpoint meaning is declared. Reaction cycles are valid only when their progress and stopping behavior can be explained.

Normalize editorial groups away for semantic uniqueness checks. Report an `ERROR` when a path `P` has more than one standing declaration in the given context, a triggering path `Q` has more than one reaction list, or a target path `P` occurs more than once in the reaction context after the same `Q`, regardless of whether a repetition is bare or determined or appears in another group. Allow one standing declaration for `P` to coexist with one reaction list under `P`, and allow the same target `P` in reaction contexts after different triggering paths. Equivalent repetitions remain errors until consolidated because duplicate contextual targets could create multiple occurrence instances and follow-on reactions; incompatible determinations are invalid. If several determinations are intended jointly or conditionally, require one unambiguous `D`. Lint-only stages report these findings and never consolidate declarations automatically.

Report an `INFO`, not a warning or error, when one group has accumulated distinct reading concerns enough to impede scanning. Recommend at most one local split into two cohesive groups, preserve all unaffected group names and order, and never rebalance groups merely by line count. Remember that grouping has no AOD semantics.

Report a modeling-quality warning when a natural-language `D` accumulates independently meaningful business policies that should remain separately inspectable or uses a catch-all such as `if all values are valid` instead of precise material rules. Recommend the smallest useful extraction into named standing definitions. Do not warn merely because `D` contains a simple one-off conjunction or because required referenced paths must resolve, and do not demand a path whose only purpose is to shorten prose.

Exact canonical binding wording is optional. If a noncanonical phrase has one clear meaning, treat it as valid and report `INFO` with its exact canonical replacement; linting never mutates. Distinguish valued bindings from Boolean quantifiers. If `some Z in M` could mean a local-row binding, singleton, existential condition, or reselection, warn; report an error only if no coherent secure meaning remains.

For every definition `P: D`, determine whether `D` actually references its target path `P`. Require explicit recursive, fixpoint, or prior-value semantics; otherwise report the declaration as ambiguous. Do not confuse repeated application-concept wording with an actual path reference. When role-specific naming resolves only apparent self-reference, recommend the exact clearer name as `INFO`; report a warning for unresolved ambiguity or an error when no coherent interpretation remains.

For each valued `P: D` that describes a structured value, distinguish target-relative constituent roles from source paths, condition paths, and ordinary dependencies. Infer a constituent path of `P` only when `D` clearly identifies its role and source, and report the inference basis and confidence. Merely mentioning another path in `D` does not make it a constituent of `P`. Verify separately that successful attainment of `P` establishes the inferred constituent values within that same attainment, not as later assignments or causal stages.

Treat `persisted` in a phrase such as `all persisted Task` as a collection-source qualifier: it does not declare `Task.Persisted`. Inventory the persistence-backed source and any controlled semantic bridge separately, and recognize a `.Persisted` path only when that path is actually used.

For every path with a reaction context, identify whether activations come from successful target attempts or separately accepted observations, including valued observations. Its use as triggering path `Q` implicitly declares it but neither produces nor observes the occurrence and never substitutes for an identifiable activation source. Treat every occurrence instance as activating that reaction context independently of whether it carries a value and, if so, what that value is. For a `Q` that may carry behaviorally distinct values, verify whether its targets are intended for every value; never infer true-only activation from a Boolean path name. If only particular values should continue the causal path, require an explicit value-specific occurrence or partial determination whose nonmatching case leaves its target unattained; a Boolean helper successfully attained as `false` is not a filter. Warn when the intended value sensitivity remains materially ambiguous, or report an error when no coherent or secure interpretation remains. Report ambiguity between standing resolution and accepted observation, an undeclared behaviorally required cadence, startup-triggered behavior without a startup occurrence declared in AOD-YAML, same-value coalescing, unstable occurrence payloads or bindings, or invocation-local bindings treated as global. Initial standing resolution during operational startup is not an observation and cannot trigger reactions. Reattaining the same state or value is a new occurrence and cannot count as cycle progress.

For every context-sensitive path or binding, test whether plausible user, session, view, selection, row, reaction-invocation, or other scopes would materially change behavior, authorization, exposure, or causal results. If so, require identifiable ownership or partition, capture, lifetime, and isolation or sharing. Put behavioral boundaries in AOD and environment-provided resolution, maintenance, capture, lifetime, or isolation in the contract. Warn when unresolved; report an error when alternatives conflict or no coherent secure interpretation remains. Do not demand scope declarations when the declarations, contract, and standard invocation semantics already determine them.

When a path `P` has both a given-context standing definition and one or more contextual definitions, determine whether each contextual target establishes an invocation-local value or binding or instead denotes persisted or write-through state. For invocation-local use, verify that the contextual value or binding takes precedence over the standing definition only within that reaction invocation and its causal descendants, does not replace the standing definition, and ceases to apply afterward. For persisted or write-through use, verify that the combined declarations are coherent and that the environment contract covers the required state transition. Warn when the relationship or lifetime is materially unclear; report an error when the standing and contextual definitions require incompatible shared or persisted state. Do not report a clear transient contextual specialization merely because the same path also has a standing definition.

When several targets share a reaction context, determine whether any dependency is merely data needed during target resolution or instead requires another target's successful attainment. Report reliance on YAML order and incorrect use of a constituent path as a later causal stage.

Treat every accepted replay or redelivery as a new occurrence unless suppression is explicitly required; do not recommend silent deduplication. Distinguish that replay from an adapter retry within one target attempt. Record material idempotency, retry, transaction, duplicate-effect, failure, delivery, durability, or acknowledgment uncertainty. These are semantic or operational risks, not grammar errors, unless a governing requirement makes the missing guarantee incoherent.

Do not treat a standing eligibility check over mutable shared state as atomic enforcement. When the checked invariant must hold at persistence or effect success, verify that the responsible capability and environment contract enforce it atomically and define conflict as non-attainment; otherwise report the resulting race or consistency risk.

### 3. Audit the Context in Package Mode

Apply every rule in `aod_context_format.md` and verify:

- package identifiers, UUID, revision, versions, canonical project slug and companion filenames, required section order and columns, unique `ENV-nnn` IDs, and exact-byte SHA-256 digest, while accepting legacy `Decisions After Linting` as the deprecated alias for `Design Decisions` in an existing `aod-context/v1` package;
- absence of secrets, implementation technologies, and behavior introduced only by the context;
- complete coverage of every material environment-resolved value, occurrence, identity or selection source, persistence or persisted-set responsibility, scheduler, standing capability input, semantic bridge, and capability-backed target;
- traceability of every contract item to exact AOD references or a clearly identified user requirement, including every distinct causal use of a shared capability;
- every `Design Decisions` item states a material application-specific choice traceable to user intent or acceptance rather than restating framework semantics, lint conformance, editorial conventions, or package mechanics, and mixed rationales retain only their application-specific content;
- responsibilities, provisioning boundaries, basis values, and success conditions that preserve the AOD's actual resolution, attainment, non-attainment, and follow-on semantics;
- every `generator-assumed` basis has a distinct additional assumption explicitly identified under `Assumptions`, and no behavior already unambiguously entailed by AOD is redundantly classified as `generator-assumed`;
- material observation source, cadence, declared startup occurrence, replay, and delivery assumptions without behavior added only by the context;
- material context-sensitive ownership, partition, capture, lifetime, and isolation boundaries without behavior added only by the context; and
- correct placement of generator assumptions and unresolved risks without presenting them as guarantees.

Coverage and traceability are bidirectional. Report both an uncovered AOD dependency and an untraceable contract item.

## Findings, Severity, and Status

Use stable category IDs such as `YAML001`, `AOD001`, `SEM001`, `CTX001`, and `ENV001`.

- `ERROR`: invalid YAML or AOD grammar; irreconcilable definitions; invalid required context structure or metadata; digest mismatch; duplicate contract ID; exposed secret; or another issue preventing coherent interpretation.
- `WARNING`: an interpretable but incomplete, ambiguous, contradictory, or materially risky declaration, capability, trace, binding, initialization, causal relation, progress condition, success condition, or operational property.
- `INFO`: an accepted inference, optional explicit declaration, environment dependency, or nonblocking improvement.

Status is `FAIL` with any error, `PASS WITH WARNINGS` with warnings and no errors, and `PASS` with neither. Informational findings do not prevent `PASS`; unavailable parser validation requires an explicit status qualification.

The lint result required by the calling workflow must retain:

- status and counts;
- each finding's ID, severity, source location, affected path when applicable, precise issue, and smallest useful recommendation;
- inferred declarations and capabilities with every relevant use, basis, and confidence;
- package integrity and environment-contract assessments in package mode;
- dependency and reaction graph assessment, including cycles, progress, and termination; and
- material assumptions, semantic uncertainties, and validation limitations.

Sort findings by severity and source location. Do not stop at the first issue, silently repair input, or turn an uncertain semantic judgment into a false syntax error.
