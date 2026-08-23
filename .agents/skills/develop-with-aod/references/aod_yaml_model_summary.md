# AOD-YAML Model Summary

`aod_yaml_model_summary.md` defines the shared syntax and semantics of the current Attainment-Oriented Declarations (AOD) model and its AOD-YAML profile. Process-specific instructions for generation, linting, or application creation may add workflow rules, but they must not change these model semantics.

## Purpose

AOD describes application behavior as compact declarations over paths. An AOD-YAML specification is an inspectable behavioral intermediate representation between natural-language intent and generated application artifacts. It expresses path declarations, standing definitions, reaction contexts, attainment targets, bindings, and environment capabilities without prescribing imperative implementation steps.

## AOD Package and Environment Contract

An implementation-ready, platform-independent AOD package consists of a `*.aod.yaml` specification and its companion `*.aod-context.md` file. The current AOD profile identifier is `aod-yaml/v1`. The `*.aod.yaml` specification is authoritative for application behavior. The `*.aod-context.md` file records key design decisions, assumptions, residual concerns, and an environment contract; `aod_context_format.md` defines its exact structure.

The environment contract states what the environment must supply, observe, preserve, or accomplish and what counts as successful environment-backed attainment. It must trace every material environment responsibility to AOD paths or causal relationships, but it does not declare additional application behavior. Technology choices for realizing those responsibilities belong in a later AOD implementation profile.

The context metadata serves as the package manifest. It records `aod-package/v1`, a stable package ID, a revision, the AOD profile, the context format, the exact AOD filename, and its exact-byte SHA-256 digest. A later implementation profile must copy the package identity and pin both package files by digest. These integrity fields do not add AOD behavior.

## YAML Profile

AOD-YAML is valid YAML with a restricted structure:

- The document root is a mapping with one or more top-level entries.
- Each top-level mapping entry is an AOD group. The group name is the mapping key and the indented sequence is its value.
- A group is editorial only. It does not define an entity, create a namespace, or establish scope.
- Choose groups by cohesive reading concern, not scope or line count. When revising an existing specification, preserve group names, order, and declaration placement by default. Split only a group that has accumulated distinct concerns and become difficult to scan; replace it locally with two cohesive groups and leave unaffected groups unchanged.
- Each group contains a nonempty sequence of AOD entries.
- YAML indentation establishes nesting. A sequence item starts with `-`.
- A scalar is a single value, expression, or natural-language declaration. A block scalar such as `>` may hold a multiline declaration as one value.
- Outside quoted or block-scalar content, YAML comments may occupy a standalone line beginning with `#` or follow a YAML node after separating whitespace. Both forms are presentation-only and ignored by AOD semantics. Tooling must not derive paths, values, conditions, bindings, reactions, capability requirements, environment-contract meaning, or other behavior from either form. Package-writing tooling adds new comments only as standalone lines and preserves existing standalone and inline comments, including their association with adjacent entries, unless an accepted change explicitly modifies or removes them.
- Mapping keys must be unique. Duplicate keys are invalid because parsers may overwrite declarations or reactions.
- Anchors, aliases, merge keys, custom tags, and other YAML presentation features add no AOD semantics. Tooling may warn when they resolve to an otherwise conforming node structure and must reject them when they prevent profile conformance.

The compact grammar is:

```text
Document      ::= Group+
Group         ::= GroupName ":" NewLine Indent EntryList Dedent
EntryList     ::= EntryItem+
EntryItem     ::= "-" Entry
Entry         ::= Path
                | Path ":" Declaration
                | Path ":" NewLine Indent ReactionList Dedent
ReactionList  ::= ReactionItem+
ReactionItem  ::= "-" Reaction
Reaction      ::= Path
                | Path ":" Declaration
Path          ::= UppercaseIdentifier ("." UppercaseIdentifier)*
Declaration   ::= YAMLScalar
                | YAMLBlockScalar
```

`UppercaseIdentifier` denotes an identifier whose first character is uppercase. The controlled-language conventions for path and application-concept references inside `D` are semantic rules rather than additional grammar productions.

Consequently, the accepted AOD-YAML forms are:

```yaml
- P
- P: D
- Q:
    - P
    - P: D
```

A mapping value that is a scalar or block scalar is a determining declaration `D`. A mapping value that is a nested block sequence is a reaction list. Declaration values cannot themselves be mappings or sequences, and reaction blocks cannot be nested inside reaction lists.

The grammar permits repeated sequence items, and YAML mapping-key uniqueness does not detect repeated path keys contained in separate sequence items. The context-specific uniqueness constraints below are therefore semantic well-formedness rules applied after YAML parsing.

The YAML node containing `D` is syntactically scalar, but the semantic result it determines may be a Boolean or other primitive value, a structured value, a collection, or a binding. `D` is one declarative determination of its target, not an ordered statement list. Semicolons and line breaks have no assignment or sequencing semantics; equality expressions state relations.

## Paths, Declarations, and Definitions

A path is an identifier composed of one or more segments separated by dots, such as `Task`, `Task.Completed`, `TaskItem.Task`, or `ReminderRun.Task.Owner.Email`. Depending on its declaration and context, a path may denote an entity, property, value, state, binding, event, UI occurrence, or environment capability.

Each identifier segment must begin with an uppercase letter, be nonempty, and contain no whitespace or dot. The current profile does not otherwise define a complete identifier alphabet; tooling may warn about unusual punctuation rather than silently impose another naming language.

Within an unquoted determining declaration `D`, an uppercase-initial identifier matching the path syntax denotes an AOD path or application-concept reference. Descriptive connective text is normally lowercase. Quoted scalar content is unaffected. Paths may be declared explicitly or through the controlled declaration-by-use rules below.

Use the terms consistently:

- To **declare** means to introduce or state the role of a path in the AOD specification.
- To **define** means to provide a determining declaration `D` for a path.
- Every definition is a declaration, but not every declaration is a definition.

AOD commonly distinguishes two semantic roles, without giving them different YAML syntax:

- A resultative Boolean path, such as `Task.Completed`, `Mail.Sent`, or `Button.Clicked`, denotes a state or occurrence that can become true or occur.
- A valued path, such as `Task.DueDate`, `User.Current`, or `ReminderRun.Task`, denotes a current value, source, reference, binding, or valued occurrence.

A standing state or value is resolved or recomputed without autonomously producing an occurrence. An occurrence path or valued occurrence path represents separately observed or attained runtime facts. The declaration, causal use, and environment source must make that role sufficiently clear; path names alone do not determine it.

## Context Semantics

Every entry is interpreted by its context and target form:

| Context | Bare path `P` | Determined path `P: D` |
| --- | --- | --- |
| Given context | `P` is declared without a standing definition. Whether `P` must be resolved, observed, or attained follows from its uses; any required environment support is recorded in the environment contract. | `P` is declared and defined by `D` as a standing definition. Whenever `P` is ordinarily resolved, `D` determines its current state or value. |
| Reaction context after `Q` | After each successful attainment or accepted observation of `Q`, an attempt is made to attain `P` using an applicable standing definition, an existing binding, or an environment capability. A standing definition may be instantiated through a concept binding. | After each successful attainment or accepted observation of `Q`, an attempt is made to attain `P`, with `D` serving as the contextual determining declaration for that reaction invocation. |

The given context consists of entries directly in a group's sequence. A reaction context is the nested sequence under `Q`. It is entered only after a successful attainment or accepted observation of `Q`.

A given-context definition `P: D` is standing and dependency-driven. Whenever `P` is resolved, `D` determines its current state or value, resolving paths referenced by `D` as needed. This resolution does not autonomously produce an occurrence or trigger a reaction.

Read a reaction block as "on `Q`, attempt ...":

```yaml
- Q:
    - P
```

This means: on each successful attainment or accepted observation of `Q`, attempt to attain `P`.

```yaml
- Q:
    - P: D
```

This means: on each successful attainment or accepted observation of `Q`, attempt to attain `P` as determined by `D` for that reaction invocation.

Target attempts are declarative, not imperative steps, and their order within a reaction context has no semantics. Several targets may be declared in the same reaction context when none depends on the successful attainment of another target in that context. Distinguish a data dependency from a causal dependency: data needed to determine or attain a target is resolved as part of that target attempt. If target `B` must wait for the successful attainment of target `A`, place `B` in `A`'s follow-on reaction context. `A` may be a valued or resultative path. Prefer an already meaningful prerequisite path; do not introduce a helper path solely to impose order.

Within the given context, a path `P` may have at most one standing declaration, either bare or determined. A separate reaction list under `P` may coexist because it declares a different context: the reaction context after `P`. An AOD-YAML document may declare at most one reaction list for each triggering path `Q`, and each target path `P` may occur at most once in that reaction context. Equivalent repetitions are redundant and must be consolidated; incompatible determinations are invalid. If several declarations are intended jointly or conditionally to determine `P`, their combined meaning must be expressed through one unambiguous `D`. These constraints apply across editorial groups because groups create no scope.

## Occurrence Instances and Reaction Invocations

A path is a declaration-level name. At runtime, an **occurrence instance** is one successful attainment or accepted observation of that path. Each occurrence instance has a distinct, opaque identity and may carry a value or payload, a source, a reference to the occurrence whose reaction context caused it (the causal parent), and contextual bindings. This is conceptual runtime semantics, not AOD-YAML syntax.

Each separately accepted observation and each successful target attempt creates a distinct occurrence instance. Successfully reattaining an unchanged state or value creates another occurrence instance. To create another occurrence instance, an observation must be accepted anew or a target must be successfully attained in its current target attempt; an occurrence instance from an earlier invocation cannot be reused. A failed target attempt creates no occurrence instance, nor does merely resolving or recomputing a standing definition.

Every occurrence instance acts as an event. Reaction activation is occurrence-based, not value-filtered: a reaction context after `Q` is activated once by every occurrence instance of `Q`, regardless of whether that occurrence carries a value and, if so, what that value is. A successful attainment or accepted observation carrying `false` therefore activates the reaction context just as one carrying `true` does. When follow-on behavior applies only to particular values, AOD must express a value-specific occurrence or a partial determination whose nonmatching case leaves its target unattained. A Boolean helper successfully attained as `false` is still an occurrence and does not filter its follow-on reaction.

Interpretive AOD has no explicit scope annotations. User, session, view, selection, and row scope is inferred from contextual path names and declarations; the environment resolves or maintains the corresponding values and bindings for the applicable scope. A recognized concept-binding declaration adds to the applicable scope the relation that role-specific binding path `P` is bound as application-concept path `T`. While `P` remains bound as `T`, standing definitions rooted at `T` apply to corresponding `P`-rooted paths, and that binding relation is inherited by causal descendants.

A reaction-invocation scope begins when an occurrence activates a reaction context. It captures the trigger occurrence and applicable transient bindings and preserves them for that invocation and its causal descendants. Sibling target attempts within the same reaction invocation inherit these captured bindings but cannot use transient bindings created only by one another. When a successfully attained target activates a follow-on reaction context, the resulting reaction-invocation scope inherits the preceding bindings and adds the new trigger occurrence, together with its value or binding where applicable. Within that reaction invocation and its causal descendants, a value or binding established for a path `P` by a contextual declaration is the applicable value of `P` and takes precedence over any standing definition of `P`. It does not replace the standing definition: unless persisted or written through, it remains applicable only within those reaction invocations; a later ordinary resolution of `P` again uses the standing definition. The transient bindings of concurrent reaction-invocation scopes remain isolated and cannot overwrite one another; all transient bindings cease to apply after their invocation and causal descendants have ended. Persisted and write-through state lies outside reaction-invocation scope; its sharing and partitioning follow the AOD declarations and environment contract. Where materially different scope interpretations would change application behavior, the AOD declarations must further clarify the intended scope; the environment contract may clarify environment-provided resolution, capture, lifetime, and isolation.

The source of an accepted observation must be identifiable. Its cadence, meaning the timing or frequency with which it supplies observations, is declared in AOD when behaviorally relevant; otherwise the environment contract may leave it to the provider. Initial standing resolution during operational startup is not an accepted observation and therefore does not trigger reactions. Any application behavior that must be triggered by startup must be expressed through a startup occurrence declared in AOD-YAML, whose reaction context declares the required attainment targets.

Each replay or redelivery accepted as another observation creates a new occurrence instance and repeats reactions, even when its payload or source identifier is unchanged. A state reload merely reconstructs existing standing state and creates no occurrence instance. An adapter retry remains part of its existing target attempt and does not itself create another instance. The AOD model does not implicitly deduplicate accepted observations; required suppression must be explicit.

## Attainment and Non-Attainment

To attain a resultative path means to establish the represented state as determined for the current target attempt or to make the represented occurrence happen. A contextual declaration may determine a Boolean state as `true` or `false`; successfully establishing either value creates the occurrence instance described above. To attain a valued path means to bind or produce a value for it. Successful attainment creates an occurrence instance.

A path is resolvable when the specification or environment can determine what it denotes and where its value, state, occurrence, or binding comes from. A reaction target is attainable when the system can attempt to make that state hold, occurrence happen, or value become bound.

Where a valued reaction target `P` is determined by `D`, `D` may describe one structured value for `P`. If a recognized concept-binding declaration binds `P` as concept `T`, a clearly expressed constituent may implicitly declare the corresponding concept-rooted path `T.X`, if otherwise undeclared, and the binding-relative path `P.X`. Successful attainment of `P` establishes the described value of `P.X` as part of the same attainment. The constituent description does not create a standing definition for `T.X`, and neither path is a later assignment or separate causal stage. A source, condition, qualifier, or ordinary dependency mentioned by `D` is not thereby a constituent. A reaction on a constituent established by the structured value belongs to the same logical attainment as the enclosing binding.

Attainment succeeds only when the state, occurrence, value, or binding is actually established. If a determining declaration yields no value, the target path is not attained and its reaction context is not entered. For example:

```yaml
- ReminderRun.Task: first Task from ReminderRun.Candidates, if any
```

If there is no candidate, `ReminderRun.Task` remains unattained and reactions after it do not occur.

## Given Paths and Initialization

The given context is not an initialization context:

- `- Button.Clicked` declares the path without observing a click. When another entry uses it as triggering path `Q`, the environment must provide accepted click observations; declaration alone creates no startup click.
- `- Task.Completed` declares the path without resolving, observing, attaining, or initializing it. Its other uses determine which of those roles are required.
- A given-context definition such as `- Task.Completed: false` is a standing definition, not a one-time initial value.

AOD does not assume a universal Boolean default. When an initial value matters, define it contextually during creation or another suitable reaction:

```yaml
- CreateButton.Clicked:
    - NewTask.Completed: false
```

This initializes only the newly created or bound instance and does not redefine all persisted instances.

## Implicit Declarations

AOD-YAML permits controlled implicit declarations and does not require every path to have a separate bare entry:

- An otherwise undeclared path referenced in `D`, including each prefix of a longer path, is implicitly declared when its role, source, and binding are clear; do not add bare or prefix-path declarations merely for completeness.
- A recognized concept-binding formulation uses the exact spelling and capitalization of an application-concept path `T`, such as `new Task`, and binds its target `P` as a role-specific binding of `T`. Lowercase `new task` is ordinary prose and establishes no such relation. The binding is Interpretive AOD semantics, not an executable type or instance declaration.
- In a recognized concept-binding declaration, a clearly expressed constituent of the structured value may implicitly declare concept-rooted path `T.X`, if otherwise undeclared, and binding-relative path `P.X`. Successful attainment of `P` establishes the described value of `P.X` as part of `P`'s structured value but does not define `T.X`. A mere source, condition, collection qualifier, or ordinary dependency does not introduce a constituent path.
- A path used as a reaction context is thereby declared implicitly; a separate bare declaration is optional and may be added only for readability, validation, or to make its resolvable or observable role explicit. Using the path as the triggering path `Q` does not itself produce, attain, or observe an occurrence; the actual observation or attainment source must remain identifiable.
- A projection or write-through path based on an explicit binding, such as `TaskItem.Task.Completed`, need not be separately declared when `TaskItem.Task` binds a `Task` and `Task.Completed` is known.
- A capability-backed outcome such as `ReminderMail.Sent` is explicitly declared by its use as a reaction target and needs no separate bare declaration in the given context.

An implicit declaration is not a definition unless a determining declaration `D` supplies one for the path. Tooling must surface inferred referenced paths and prefixes, recognized concept bindings, concept-rooted constituent paths and their binding-relative counterparts, instantiated standing definitions, projections, semantic bridges, and capabilities together with their inference basis and confidence. If an inference is unclear or materially affects behavior, clarify it rather than silently inventing semantics.

For example, the contextual declaration `NewTask: new Task that is not completed` recognizes `NewTask` as a binding of concept `Task`; its clear constituent description implicitly declares `Task.Completed` and `NewTask.Completed`, and successful attainment establishes `NewTask.Completed` as `false`. It does not create a standing definition for `Task.Completed`. The inference follows from the clear concept-bound relation and constituent meaning, not from a reserved word such as `with`.

## Natural-Language Declarations and Binding

A declaration `D` may be formal, semiformal, or controlled natural language. Under Interpretive AOD it describes one intended result clearly enough for coherent environment or generator resolution; a unique interpretation cannot generally be proved. Clarify materially behavior-changing alternatives rather than choose silently. A valued `D` may describe one structured value, including an entity, but not a property-assignment sequence.

`D` must fit its target's role: one state or Boolean condition for a resultative path; one value, entity, collection, or binding for a valued path. Avoid `Prepared`, `Ready`, or `Recorded` helpers that only bundle properties or manufacture sequence; retain them for genuine independent conditions, bindings, acknowledgments, or capabilities.

Judge compactness semantically, not by line count. Keep a simple one-off qualifier in `D`. Name and reference an independently meaningful business rule when reviewable, changeable, testable, reusable, or obscured inline. Do not introduce a path merely to shorten prose. Replace `if all values are valid` with resolution of required paths and precise, named material rules.

Use role-specific bound-instance names to avoid apparent self-reference: `DecisionToRecord: decision for SupervisorReview.Request with value approved` is clearer than `VacationRequestDecision: VacationRequestDecision for ...`. Treat an actual target reference in `D` as ambiguous unless recursive or prior-value semantics are explicit.

Canonical concept-binding idioms carry Interpretive AOD semantics but are not additional YAML node types. In `new T`, `current T`, `selected T`, `first T from M, if any`, and `arbitrary T from M` in an explicitly local item or row context, `T` denotes an application-concept path and target `P` becomes a role-specific binding of `T`. Tooling accepts clear equivalent formulations; package writers normalize them and lint-only stages report them. `arbitrary T from M` denotes a stable local binding, never random choice or repeated reselection. Clarify wording that could instead express a Boolean quantifier or another binding.

While `P` is bound as `T`, a standing definition rooted at `T` applies to `P` by replacing root `T` with `P`, including `T`-rooted references inside its determining declaration. Merely resolving the resulting `P`-rooted path creates no occurrence. An explicit standing definition for the same binding-relative path must not conflict with the instantiated definition.

Contextual wording may clarify a material scope boundary without adding syntax:

```yaml
- SupervisorReview.Request: >
    selected VacationRequest from SupervisorReview.PendingRequests
    in the current supervisor view, if any
- SupervisorRequestItem.Request: >
    arbitrary VacationRequest from SupervisorReview.PendingRequests
    represented by this row instance
```

The phrase `all persisted Task` denotes a collection of persisted values of concept `Task`. Here, `persisted` qualifies the source collection; it is neither an AOD path reference nor a constituent description and therefore does not declare `Task.Persisted`. Binding `NewTask` as `Task` does not itself persist `NewTask` or place it in that collection. After the explicitly named target `NewTask.Persisted` succeeds, the environment contract must require the bound value to retain its identity and constituent values and become a member of the persisted `Task` universe.

## Effects and Environment Capabilities

A bare reaction target can ask the environment to attain an effectful outcome:

```yaml
- SendButton.Clicked:
    - Mail.Sent
```

The environment may attain `Mail.Sent` by sending a message using declared recipient, subject, and body values. In contrast, the contextual target `Mail.Sent: true` requests attainment of the represented state as true; it does not by itself require the mail-sending effect unless the environment contract gives that determination the corresponding effectful semantics.

When a bare capability target is attempted, the environment resolves its required standing definitions on demand. Those definitions are not preceding reaction steps and require no attainment order. The environment contract identifies the required inputs and the capability's success condition when they are material.

A standing definition that tests eligibility against mutable shared state is an observation, not a reservation or transaction. When its invariant must still hold as persistence or another environment-backed effect succeeds, the responsible capability must recheck it atomically. A conflict leaves the capability target unattained; the environment contract records the enforcement and success boundary.

Every business-relevant outcome that relies on an environment capability shall be declared as a target in the reaction context that requires it, or shall be causally traceable from that context through follow-on reactions. If several reaction contexts require the outcome, each causal path shall be explicit. A declaration is not duplicated merely because it may be attained repeatedly at runtime. Environment support that does not itself represent a behavioral attainment belongs in the environment contract rather than as an AOD target.

Attaining a property through a binding to an already persisted structured value is a write-through update of that value unless a draft or separate persistence boundary is declared. A separate `.Persisted` target is needed when a new structured value enters the persisted universe or when successful persistence is itself a distinct observable capability. If later behavior depends on that capability, place it in the `.Persisted` path's follow-on reaction context.

Path names alone do not prove that a capability exists. Persistence, scheduling, sending, notification, deletion, and similar effects depend on the target environment. Idempotency, retries, transactions, duplicate events, and failure handling are operational policies that AOD-YAML does not provide automatically.

## Recursion and Progress

Reaction cycles may express repeated behavior without an imperative loop. Every intended cycle must have a credible progress measure or termination condition, such as:

- a shrinking candidate set;
- a state update that removes the current item from eligibility; and
- a partial binding that remains unattained when no candidate exists.

If progress requires one target to be visible before another is re-attained, use a follow-on reaction context instead of relying on target order in the same reaction context.

Reattaining an unchanged state or value still activates its follow-on reaction and is therefore not, by itself, a cycle progress measure or termination condition.
