$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root

$skillRoot = '.agents/skills/develop-with-aod'
$referencesRoot = "$skillRoot/references"
$scriptsRoot = "$skillRoot/scripts"

$sets = [ordered]@{
    'spec-generation' = @(
        "$skillRoot/SKILL.md",
        "$referencesRoot/aod_yaml_model_summary.md",
        "$referencesRoot/aod_framework_package_profile.md",
        "$referencesRoot/aod_context_format.md",
        "$referencesRoot/aod_yaml_lint_rules.md",
        "$referencesRoot/stage_create_package.md",
        "$referencesRoot/prompt_create_package.md"
    )
    'package-review' = @(
        "$skillRoot/SKILL.md",
        "$referencesRoot/aod_yaml_model_summary.md",
        "$referencesRoot/aod_framework_package_profile.md",
        "$referencesRoot/aod_context_format.md",
        "$referencesRoot/aod_yaml_lint_rules.md",
        "$referencesRoot/stage_review_package.md",
        "$referencesRoot/prompt_review_package.md"
    )
    'linting' = @(
        "$skillRoot/SKILL.md",
        "$referencesRoot/aod_yaml_model_summary.md",
        "$referencesRoot/aod_framework_package_profile.md",
        "$referencesRoot/aod_context_format.md",
        "$referencesRoot/aod_yaml_lint_rules.md",
        "$referencesRoot/stage_lint_package.md",
        "$referencesRoot/prompt_lint_package.md"
    )
    'logical-preview' = @(
        "$skillRoot/SKILL.md",
        "$referencesRoot/aod_yaml_model_summary.md",
        "$referencesRoot/aod_framework_package_profile.md",
        "$referencesRoot/aod_context_format.md",
        "$referencesRoot/stage_logical_preview.md",
        "$referencesRoot/prompt_logical_preview.md"
    )
    'profile-dialog' = @(
        "$skillRoot/SKILL.md",
        "$referencesRoot/aod_yaml_model_summary.md",
        "$referencesRoot/aod_framework_package_profile.md",
        "$referencesRoot/aod_context_format.md",
        "$referencesRoot/aod_experience_format.md",
        "$referencesRoot/aod_implementation_profile.schema.json",
        "$referencesRoot/stage_implementation_profile.md",
        "$referencesRoot/prompt_implementation_profile.md"
    )
    'program-generation' = @(
        "$skillRoot/SKILL.md",
        "$referencesRoot/aod_yaml_model_summary.md",
        "$referencesRoot/aod_framework_package_profile.md",
        "$referencesRoot/aod_context_format.md",
        "$referencesRoot/aod_experience_format.md",
        "$referencesRoot/aod_traceability_format.md",
        "$referencesRoot/aod_traceability.schema.json",
        "$referencesRoot/stage_generate_program.md",
        "$referencesRoot/prompt_generate_program.md"
    )
}

$budgets = @{
    'spec-generation' = 95000
    'package-review' = 122000
    'linting' = 88000
    'logical-preview' = 72000
    'profile-dialog' = 109000
    'program-generation' = 120000
}

$invocationContracts = @{
    "$referencesRoot/prompt_create_package.md" = @(
        'Stage: `create-package`', '`stage_create_package.md`',
        '{{PROJECT_NAME_OR_BLANK}}', '{{PROJECT_SLUG_OR_BLANK}}',
        '{{NATURAL_LANGUAGE_APPLICATION_DESCRIPTION}}'
    )
    "$referencesRoot/prompt_review_package.md" = @(
        'Stage: `review-package`', '`stage_review_package.md`',
        '{{AOD_YAML_FILENAME}}', '{{AOD_CONTEXT_FILENAME}}',
        '{{INITIAL_REVIEW_FOCUS_OR_USER_PROPOSALS_OR_NONE}}'
    )
    "$referencesRoot/prompt_lint_package.md" = @(
        'Stage: `lint-package`', '`stage_lint_package.md`',
        '{{AOD_YAML_FILENAME}}', '{{AOD_CONTEXT_FILENAME_OR_NONE}}'
    )
    "$referencesRoot/prompt_logical_preview.md" = @(
        'Stage: `logical-preview`', '`stage_logical_preview.md`',
        '{{AOD_YAML_FILENAME}}', '{{AOD_CONTEXT_FILENAME}}',
        '{{PREVIEW_SIMULATION_POLICY_OR_BLANK}}'
    )
    "$referencesRoot/prompt_implementation_profile.md" = @(
        'Stage: `implementation-profile`', '`stage_implementation_profile.md`',
        '{{AOD_YAML_FILENAME}}', '{{AOD_CONTEXT_FILENAME}}',
        '{{PROJECT_NAME_OR_BLANK}}',
        '{{EXISTING_IMPLEMENTATION_PROFILE_FILENAME_OR_NONE}}',
        '{{EXISTING_AOD_EXPERIENCE_FILENAME_OR_NONE}}',
        '{{EXPERIENCE_RESOURCE_FILENAMES_OR_NONE}}',
        '{{INITIAL_IMPLEMENTATION_PREFERENCES_OR_BLANK}}'
    )
    "$referencesRoot/prompt_generate_program.md" = @(
        'Stage: `generate-program`', '`stage_generate_program.md`',
        '{{AOD_YAML_FILENAME}}', '{{AOD_CONTEXT_FILENAME}}',
        '{{AOD_IMPLEMENTATION_PROFILE_FILENAME}}',
        '{{AOD_EXPERIENCE_FILENAME_AND_RESOURCE_FILENAMES_OR_NONE}}',
        '{{ADDITIONAL_IMPLEMENTATION_DIRECTIONS_OR_NONE}}'
    )
}

$stageProcedures = @(
    "$referencesRoot/stage_create_package.md",
    "$referencesRoot/stage_review_package.md",
    "$referencesRoot/stage_lint_package.md",
    "$referencesRoot/stage_logical_preview.md",
    "$referencesRoot/stage_implementation_profile.md",
    "$referencesRoot/stage_generate_program.md"
)

$errors = [System.Collections.Generic.List[string]]::new()
$activeFiles = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)

foreach ($set in $sets.Values) {
    foreach ($file in $set) {
        [void]$activeFiles.Add($file)
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            $errors.Add("Missing required file: $file")
        }
    }
}

[void]$activeFiles.Add("$skillRoot/SKILL.md")
[void]$activeFiles.Add("$skillRoot/agents/openai.yaml")
[void]$activeFiles.Add('docs/maintainers/aod_instruction_architecture.md')
[void]$activeFiles.Add('docs/aod_user_workflow.md')

$digestTool = "$scriptsRoot/get_aod_file_digest.ps1"
if (-not (Test-Path -LiteralPath $digestTool -PathType Leaf)) {
    $errors.Add("Missing required workflow tool: $digestTool")
}
elseif (
    (Get-Content -LiteralPath 'docs/aod_user_workflow.md' -Raw) -notmatch
    [regex]::Escape($digestTool)
) {
    $errors.Add("docs/aod_user_workflow.md does not reference $digestTool")
}

$requiredHeadings = @{
    "$referencesRoot/aod_yaml_model_summary.md" = @(
        '## YAML Profile',
        '## Paths, Declarations, and Definitions',
        '## Context Semantics',
        '## Occurrence Instances and Reaction Invocations',
        '## Attainment and Non-Attainment',
        '## Given Paths and Initialization',
        '## Implicit Declarations',
        '## Natural-Language Declarations and Binding',
        '## Effects and Environment Capabilities',
        '## Recursion and Progress'
    )
    "$referencesRoot/aod_framework_package_profile.md" = @(
        '## Explicit Path Declarations',
        '## Stage Enforcement'
    )
    "$referencesRoot/aod_context_format.md" = @(
        '## Package Identity and Integrity',
        '## Required Structure',
        '## Environment Contract Coverage',
        '## Contract Fields'
    )
    "$referencesRoot/aod_experience_format.md" = @(
        '## Purpose and Authority',
        '## Filename and Profile Pin',
        '## Required Structure',
        '## Content Boundary'
    )
    "$referencesRoot/aod_yaml_lint_rules.md" = @(
        '## Authority and Modes',
        '## Procedure',
        '## Findings, Severity, and Status'
    )
    "$referencesRoot/aod_traceability_format.md" = @(
        '## Purpose and Authority',
        '## Package and Implementation Pins',
        '## Forward Mappings',
        '## Source Markers',
        '## Reverse Scope Inventory',
        '## Generated Validation'
    )
}

$requiredTaskPhrases = @{
    "$referencesRoot/aod_yaml_model_summary.md" = @(
        'framework package profile may require explicit bare entries',
        'Path ::= UppercaseIdentifier',
        'Each identifier segment must begin with an uppercase letter',
        'declared without a standing definition',
        'attempt to attain `P`',
        'Judge compactness semantically',
        'a unique interpretation cannot generally be proved',
        'Target direct state or property changes directly',
        'Define derived collections and eligibility as current-state determinations',
        'introduce a draft boundary only when changes must remain provisional',
        'Tooling accepts clear equivalent formulations',
        'package writers normalize them and lint-only stages report them',
        'independently meaningful business rule',
        'Do not introduce a path merely to shorten prose',
        'concept-rooted path `T.X`',
        'binding-relative path `P.X`',
        'does not create a standing definition for `T.X`',
        'A source, condition, qualifier, or ordinary dependency mentioned by `D` is not thereby a constituent',
        'Successful attainment of `P` establishes the described value of `P.X`',
        'neither path is a later assignment or separate causal stage',
        'Lowercase `new task` is ordinary prose',
        'new Task that is not completed',
        'standing definition rooted at `T` applies to `P`',
        'does not itself produce, attain, or observe an occurrence',
        'In `all persisted Task`, the declaration determines a collection',
        '`NewTask.Persisted` is instead a separately and explicitly named attainment target',
        'Binding `NewTask` as `Task` does not itself store `NewTask`',
        'Choose groups by cohesive reading concern',
        'preserve group names, order, and declaration placement by default',
        '`if all values are valid`',
        'observation, not a reservation or transaction',
        'must recheck it atomically',
        'YAML mapping-key uniqueness does not detect repeated path keys',
        'may have at most one standing declaration',
        'may declare at most one reaction list for each triggering path `Q`',
        'each target path `P` may occur at most once',
        'Equivalent repetitions are redundant and must be consolidated',
        'reaction-invocation scope begins when an occurrence activates a reaction context',
        'Every occurrence instance acts as an event',
        'Reaction activation is occurrence-based, not value-filtered',
        'Boolean helper successfully attained as `false`',
        'takes precedence over any standing definition of `P`',
        'a later ordinary resolution of `P` again uses the standing definition',
        'startup occurrence declared in AOD-YAML',
        'does not implicitly deduplicate accepted observations',
        'standalone line beginning with `#` or follow a YAML node after separating whitespace',
        'must not derive paths, values, conditions, bindings, reactions, capability requirements, environment-contract meaning, or other behavior from either form',
        'adds new comments only as standalone lines and preserves existing standalone and inline comments'
    )
    "$referencesRoot/aod_context_format.md" = @(
        '## Design Decisions',
        'deprecated legacy heading',
        'records only material application-specific choices',
        'occurrence-versus-startup semantics',
        'assumption recording the smallest coherent interpretation needed to represent stated behavior',
        'An authoring assumption must not introduce optional functionality, including an unrequested lifecycle or stopping rule',
        'Absence of unrequested functionality, including a lifecycle or stopping rule, needs no assumption or residual concern by default',
        'directly required or explicitly confirmed by the user',
        '`Authoring assumption:`',
        'Contract assumption for `ENV-nnn`',
        'semantically disjoint',
        'not the provenance of the corresponding AOD behavior',
        'Split separable contract claims with different bases',
        '`AOD-required` and `generator-assumed` may coexist',
        'identify the affected `ENV-nnn` row',
        '`Deliberately excluded:`',
        '`Deferred/unspecified:`',
        'Do not use a generic placeholder',
        'startup occurrence declared in AOD-YAML',
        'resolution or maintenance context',
        'standalone or inline nonbehavioral AOD comment',
        'A recognized concept binding',
        'framework-required bare entries',
        'create no contract row by themselves',
        'do not by themselves require separate contract rows',
        'does not establish persisted-set membership'
    )
    "$referencesRoot/aod_framework_package_profile.md" = @(
        'does not change AOD semantics',
        'must either occur exactly in an AOD-YAML entry or be covered as a proper prefix of a longer path that occurs in an entry',
        'a triggering path `Q` with a reaction list',
        'Do not add a second bare entry',
        'paths referenced only in an unquoted determining declaration `D`',
        'undeclared prefix paths',
        'concept-rooted constituent path `T.X` and binding-relative constituent path `P.X`',
        'Normalize the inventory from longest paths to shortest',
        'is not a proper prefix of an entry already present or scheduled',
        'does not by itself require an environment-contract row',
        'clarify the interpretation first',
        'naming convention for transient values supplied directly by a user',
        'role-specific root containing `Input`',
        'existing package remains valid AOD and framework-conforming',
        '`review-package` presents missing entries as one exact, nonbehavioral framework-conformance proposal',
        'optional nonbehavioral proposal that atomically normalizes clearly identified input-family names and all references',
        '`lint-package` is nonmutating',
        '`STYLE001` `INFO` with an exact atomic rename',
        '`logical-preview`, `implementation-profile`, and `generate-program` stop',
        'not application behavior',
        'A `STYLE001` naming item never blocks downstream stages'
    )
    "$referencesRoot/aod_yaml_lint_rules.md" = @(
        '`aod_framework_package_profile.md` is the sole authority',
        '### 3. Audit the Framework Package Profile',
        'A textual reference inside `D` is not by itself an entry',
        'framework-profile `WARNING` with category `PROF001`',
        'exact bare entry `- P` to add',
        'Do not warn for a path already explicit in another entry form',
        'nonbehavioral package mechanics',
        'primary role is to hold transient values supplied directly by a user',
        'report nonblocking `STYLE001` `INFO`',
        'one exact atomic replacement for the root',
        'Do not report `PROF001`, a warning, or an error for this naming convention',
        'deprecated alias for `Design Decisions`',
        'every `generator-assumed` basis names a distinct additional contract claim',
        'every material AOD behavior is traceable',
        'each authoring assumption is necessary for the smallest coherent interpretation of stated behavior',
        'adds no unrequested user action, state transition, data item, external effect, lifecycle or stopping rule, or business policy',
        'absence of optional functionality or a nonblocking lifecycle or stopping condition is not a coverage defect',
        '`Design Decisions` and `Assumptions` are semantically disjoint',
        'every material authoring assumption identifies the AOD behavior',
        'separable contract claims with different bases use separate rows',
        'behaviorally material temporal wording',
        'Report a modeling-quality warning',
        'Exact canonical binding wording is optional',
        'report `INFO` with its exact canonical replacement',
        'linting never mutates',
        'whether `D` actually references its target path `P`',
        'explicit recursive, fixpoint, or prior-value semantics',
        'Do not confuse repeated application-concept wording with an actual path reference',
        'smallest useful extraction into named standing definitions',
        'simple one-off conjunction',
        'Report an `INFO`, not a warning or error',
        'uppercase-initial identifier matching AOD path syntax',
        'lowercase `new task` is ordinary prose',
        'concept-rooted path `T.X`',
        'binding-relative path `P.X`',
        'does not define `T.X`',
        'root substitution',
        'Do not infer from a bare given-context entry `P` alone',
        'target attempt rather than guaranteed attainment',
        'inference basis and confidence',
        'it does not declare `Task.Persisted` and is not a constituent description',
        'Binding `NewTask` as `Task` does not itself persist it',
        'neither produces nor observes the occurrence',
        'at most one local split into two cohesive groups',
        'uses a catch-all such as `if all values are valid`',
        'standing eligibility check over mutable shared state as atomic enforcement',
        'Normalize editorial groups away for semantic uniqueness checks',
        'more than one standing declaration in the given context',
        'more than one reaction list',
        'more than once in the reaction context after the same `Q`',
        'multiple occurrence instances and follow-on reactions',
        'every `Design Decisions` item states a material application-specific choice',
        'mixed rationales retain only their application-specific content',
        'startup-triggered behavior without a startup occurrence declared in AOD-YAML',
        'never infer true-only activation from a Boolean path name',
        'nonmatching case leaves its target unattained',
        'both a given-context standing definition and one or more contextual definitions',
        'incompatible shared or persisted state',
        'Exclude both forms from path and reference extraction',
        'must not use comment text as behavioral evidence'
    )
    'docs/maintainers/aod_instruction_architecture.md' = @(
        'Framework-only explicit-path authoring requirements',
        'framework package profile',
        'Keep model semantics and framework authoring policy distinct',
        'Review and revise an AOD package and its business design',
        'Invocation Contracts',
        'Implementation-traceability semantics and coverage',
        'Implementation-traceability structure',
        'Optional experience brief and restrained presentation defaults',
        'does not list canonical',
        'requests any missing application-specific stage input before loading',
        'separately or in bounded sections',
        'total static payload budgets including `SKILL.md`',
        'shared semantic phrases are asserted in their canonical source'
    )
    "$referencesRoot/stage_review_package.md" = @(
        '## Framework-Conformance Normalization',
        '## Optional Input-Naming Normalization',
        'Framework conformance proposal | Pending',
        'Include every missing path in one exact AOD-YAML patch',
        'Do not add a duplicate for a path already explicit',
        'stricter than the underlying AOD model',
        '`Reject`, `Defer`, or `Finish` applies nothing and leaves the same item pending',
        'Do not add a deferral remark for this mechanical item',
        'at most one optional nonbehavioral naming proposal',
        'Present it only after mandatory framework conformance and higher-priority material reviewer proposals',
        'Rename each complete family atomically',
        '`Defer` retains only its conversational deferred status and adds no context remark',
        '`Finish` skips an active naming item and finalizes accepted changes',
        'does not count toward the expected number of material reviewer proposals',
        'Never record framework-required bare-entry normalization',
        'If any `PROF001` warning remains, do not finalize',
        'at most one active unresolved item',
        'BR identifiers are task-local across repeated `review-package` invocations',
        'latest `Next business-review identifier: BR-nnn` completion marker',
        'Every assigned identifier remains consumed',
        'Immediately before the standard stage-completion menu',
        'Use monotonically increasing identifiers `BR-001`',
        'Reviewer backlog entries have no authority',
        'never use their domain content as proposal evidence',
        'systematic coverage pass',
        'roughly five to ten meaningful proposals',
        'soft expectation, not a quota',
        '`optional scope extension`',
        'does not violate closed scope',
        'an optional strengthening',
        'Do not prefer stronger guarantees by default',
        'ambiguous acknowledgment',
        'required abstract capability cooperation and stable cross-attempt identity',
        'Remove a residual concern only when this closes its uncertainty',
        'Before declaring the reviewer backlog empty',
        'can block, duplicate, skip, or otherwise materially alter declared user-visible behavior',
        'Do not end proposal generation merely because one proposal was accepted',
        '**No Reviewer Proposal Pending**',
        'Stage 2 remains open for your own change requests',
        'This open-review state receives no `BR-nnn` identifier',
        'Stage termination requires the standalone control `Finish` or `Discard all`',
        'Finalize only after the standalone response `Finish`',
        'Present exactly one active unresolved item per turn',
        'Apply the `Preview-Then-Accept Gate` to every user-requested package change',
        'Only a subsequent `Accept` in a later user turn applies that displayed patch',
        '## Preview-Then-Accept Gate',
        'No direct-user application shortcut exists',
        '`Accept deferred BR-nnn` is the sole exception to the active-proposal rule',
        'Every other decision command consumes only the proposal active when the user message began',
        'The first `Accept` never carries forward',
        'Never emit a `Direct user change` or `Applied artifact changes` shortcut',
        '`Revise: ...` replaces or refines the proposal under the same identifier',
        'It requires a subsequent `Accept`',
        'as the first user intervention after preflight',
        '**BR-004 | User decision | Applied**',
        'The displayed reply sentence is literal and mandatory',
        'Do not substitute `Modify` for `Revise: ...`',
        'omit `Finish`',
        '`Finish` ends the review',
        '## Artifact Placement and Exact Change Preview',
        'current working-draft line numbers',
        'complete affected declaration',
        'Never show an isolated folded-scalar continuation',
        '`Column | Before | After` table',
        'only permitted Environment Contract change representation',
        'first two body rows must be `ID` and `AOD reference`',
        'Never use a raw source-table row',
        'Follow them only with every other column whose value actually changes',
        'place it in AOD-YAML',
        'For a context-only candidate',
        'never hide application behavior in the environment contract',
        'only confirms, restates, relabels, or moves AOD behavior',
        'Metadata reclassification, renaming, reordering, and duplicate-prose cleanup are not business-design proposals',
        'A qualifying group split remains the sole editorial exception',
        'add it to the reviewer backlog',
        'smallest coherent patch under the canonical compactness',
        'Name independently meaningful policies',
        'ask before assigning an ambiguous binding or constituent meaning',
        'compare current and candidate drafts by semantic item',
        'Preserve unrelated declarations, contract rows, and context items verbatim and in place',
        'append without replacing neighbors',
        'resolve only the matching item',
        'Preserve existing standalone and inline AOD-YAML comments verbatim',
        'Never use comment text as evidence for behavior, design decisions, or environment-contract meaning',
        'Generate any new comment only as a standalone line',
        'Include directly associated standalone comments and any attached inline comment',
        'atomic enforcement and conflict non-attainment',
        '### Group Cohesion and Stability',
        'Inspect every group at Stage 2 preflight',
        'do not wait for the user to request it',
        'Preserve existing group names, order, and declaration placement by default',
        'Never rename, reorder, repartition, or balance groups merely by line count',
        'replacing that one group with two cohesive groups',
        'including when the user explicitly requests regrouping',
        'complete original group and both complete replacement groups',
        'material accepted application-specific changes',
        'mixes an application policy with framework mechanics',
        'applies exactly the displayed semantic patch',
        'show the regenerated preview and wait for a subsequent decision',
        '`Defer` leaves the matter open',
        '## Accepting a Deferred Proposal',
        'its latest status is `deferred`',
        'If the semantic patch remains applicable unchanged',
        'Remove exactly the matching deferral remark',
        'Do not allocate another BR identifier',
        'If the named identifier was never issued in the current task',
        'fail closed',
        'List the currently eligible deferred BR identifiers',
        'BR identifiers are not persisted in the AOD package',
        'has status `discarded`, not `deferred`',
        '`Discard all` immediately abandons',
        '## Discarding the Review',
        'explicit terminal rollback',
        'Restore the pre-session status of every BR issued earlier',
        'every BR first issued in this review session as `discarded`',
        'Do not increment the package revision',
        '`Discard all` is different from `Finish`',
        'canonical AOD-YAML and context files remain unchanged between dialog turns',
        'do not apply it silently',
        'use the folded block style `>` rather than `>-`',
        'increment the package revision exactly once',
        'Compute its exact-byte SHA-256 digest'
    )
    "$referencesRoot/stage_create_package.md" = @(
        'every inferred or assumed path that is absent from all four AOD entry forms and is not a proper prefix of an entry already present or scheduled receives exactly one bare given-context entry',
        'an added `Task.Completed` also covers structural prefix `Task`',
        'Do not add another bare entry for a path already explicit',
        'no unresolved framework-profile warning',
        'primary domain object and purpose or workflow',
        'private authority ledger',
        'Material choice | Authority | AOD reference | Context placement | Question required',
        'exactly one concise question per turn',
        'apply a scope-delta test to its proposed answers',
        'Every answer must resolve the stated behavior without adding an unrequested user action, state transition, data item, external effect, lifecycle or stopping rule, or business policy',
        'let closed scope prevail',
        'A domain convention or common lifecycle operation is not explicit intent',
        'An unspecified lifecycle or stopping condition is nonblocking',
        'repeated behavior then continues while its explicitly stated eligibility condition remains true',
        'Stage 2 may later propose the extension',
        'An absent optional lifecycle or stopping condition is not such an ambiguity',
        'Give each coherent family of transient values supplied directly by a user a role-specific root containing `Input`',
        'every material user requirement maps to AOD content',
        'every material AOD behavior maps to user-stated or user-confirmed intent or exactly one necessary authoring assumption',
        'no optional extension has entered through a Stage 1 question or assumption',
        'Do not write the package until the ledger, AOD, context placement, and ENV bases agree',
        'Map every behaviorally material temporal expression',
        'Never generate legacy `X = D`',
        'use the folded block style `>` rather than `>-`',
        'the not-yet-created context is not a finding',
        'Create exactly `<project-slug>.aod.yaml`',
        'Classify the authority of each specific contract claim',
        'only material user-stated or user-confirmed application choices as design decisions',
        'Record neither model semantics',
        'Do not generate new inline comments',
        'preserve both standalone and inline comments',
        'Never derive AOD behavior or environment-contract meaning from comment text'
    )
    "$referencesRoot/stage_lint_package.md" = @(
        'Report every model-valid path that is neither exactly explicit nor covered as a proper prefix of a longer entry as `PROF001`',
        'never add it silently',
        'nonblocking `STYLE001` information',
        'exact atomic rename covering the complete family',
        'never changes lint status from `PASS`',
        '| Path or relation | Use or location | Inference basis | Confidence |',
        'inferred referenced paths and prefixes',
        'concept-rooted and binding-relative constituent paths',
        'instantiated standing definitions'
    )
    "$referencesRoot/stage_implementation_profile.md" = @(
        'Compare every inferred or assumed path with all four AOD entry forms and apply the package profile''s proper-prefix coverage rule',
        'stop before technology questions',
        'direct the user to `review-package` or `create-package`',
        'Ask exactly one next highest-priority material question',
        "wait for the user's answer before asking another",
        'interrupts progression and is not acceptance of a recommendation',
        'resume at the earliest affected unresolved decision',
        'Present each pending decision unnumbered in this exact form',
        'The standalone response `Accept`',
        'does not accept it',
        'Never replace the standard reply line because a resource, provisioning, or readiness action remains',
        '`Accept` records the decision only',
        'keep the unmet prerequisite open',
        'first pending decision after preflight must be `Project name`',
        'derivation is a recommendation, not acceptance',
        'partial explicit choices, unsolicited future-topic choices, and a follow-up',
        'Do not announce an inferred choice as recorded',
        '## Provisioning Planning',
        'Current readiness is dialog state, not persistent profile data',
        'For the first `Target and architecture` decision after project name',
        'One canonical realization applies to local and operational deployment',
        'Ask whether to accept the complete matrix or change named rows',
        '`Accept` records the complete matrix',
        'Map `generated` to `generated-program`',
        'Prefer the most self-contained realization that remains secure, supportable, portable, and faithful',
        'For every required capability and architecture row, first determine whether a generated component',
        'audit every `confirmed external service` and `explicitly pending` row',
        'authority of organizational data',
        'is not sufficient',
        'Never externalize for convenience',
        'generated, host-runtime, confirmed external service, or explicitly pending',
        'An abstraction is not ownership',
        'An environment-contract responsibility is an implementation obligation, not evidence of an external service',
        'Separate implementation ownership from authoritative data provisioning',
        'operator-provided data does not externalize a generated component',
        'Use `explicitly pending` only when a named unresolved requirement prevents a defensible recommendation',
        'do not group unrelated realizations or defer safely generatable capabilities',
        'Default to one project repository containing all generated components',
        'Repository co-location does not imply one process, artifact, runtime, or deployment unit',
        'does not by itself justify another repository',
        'Apply this default without another question',
        'Ask about multiple repositories only when an established ownership',
        'record the exact source boundaries and consequences in `target.architecture`',
        'resolve `Runtime portability`',
        '`deployment.runtime_portability: portable`',
        'a dedicated host may later run the portable deployment',
        'Do not equate portability with containerization, OCI, or Linux',
        'OCI standardizes artifact/runtime interfaces',
        'Linux names the workload OS/kernel boundary',
        'When a recommendation introduces a specialist standard, packaging format, runtime boundary, protocol, or abbreviation',
        'add one short plain-language sentence stating the practical artifact',
        'say `compatible with` rather than equating a standard with a product',
        'never turn an explanatory example into a profile dependency',
        'Explain the term once unless its practical consequence changes',
        'do not require a remote host before profile generation',
        'turn the current verification host into a profile constraint',
        'Default to local-first, fully capable, operationally representative execution',
        'Local and operational environments use the same application components',
        'Operational-only inputs must not block local startup',
        'A later cloud deployment does not itself justify substituting a managed service',
        'Test doubles, captured transports, and mail-capture tools may support automated tests only',
        'generated component; setup-generated resource or value; derived value',
        'Do not presume an identity provider',
        'Give each provisioning plan a `mode`',
        '`setup-generated` secrets',
        'generated non-UI operator tooling',
        'Do not infer self-registration, password-reset, account-status',
        'login identifier and uniqueness policy',
        'password hashing, parameters, and upgrade policy',
        'post-login identifier rotation',
        'failed-login throttling',
        'idle and absolute expiration',
        'proposed profile choices with a security-usability basis',
        '`planned-output`, not missing',
        'If the generated deployment owns the proxy',
        'never ask the user to paste secret or key material',
        '`deployment.prerequisites`',
        '`non_secret_configuration`',
        '## Lifecycle and Verification Policy',
        'A disposable classification never itself authorizes deletion',
        '`verification_policy.real_external_effects`',
        '## Experience Guidance',
        'restrained-internal-tool-defaults',
        'Pin every normative non-secret guide'
    )
    "$referencesRoot/stage_logical_preview.md" = @(
        'Compare its complete inferred and assumed path inventory with all four AOD entry forms',
        'direct the user to `review-package` or `create-package`',
        'never add or assume it in the preview',
        'Compile that view without adding semantics',
        'occurrence-based and value-independent reaction activation',
        'concept bindings, constituents, and instantiated standing definitions',
        'Resolve capability inputs on demand',
        '### Closed Scope',
        'AOD Technical Realization Decision TRD-nnn',
        'no-inference boundaries',
        'not a visual-design prototype or implementation baseline',
        'illustrative and nonbinding',
        'do not present the HTML as a visual specification for the final program',
        'otherwise from the canonical project slug'
    )
    "$referencesRoot/stage_generate_program.md" = @(
        'Build the complete inferred and assumed path inventory',
        'stop before writing files',
        'never add or silently assume it during generation',
        'one authoritative runtime representation per semantic path',
        'Never replace those semantics with value-change listeners',
        'Resolve capability inputs on demand',
        'Add risk-appropriate tests across every semantic dimension',
        '### Closed-Scope Conformance',
        'bidirectional scope inventory',
        '## Technical Realization Decisions',
        'scope violation, not a Technical Realization Decision',
        '## AOD Implementation Traceability',
        'AOD TRACE-nnn:',
        'project-local read-only traceability checker',
        'AOD traceability digest',
        'fail when a business surface relies only on a Technical Realization Decision',
        '### Provisioning Readiness',
        'Never request, print, or report a secret',
        'A missing prerequisite is not an implementation conflict',
        'resume the blocked verification',
        'never invent an unnamed operator input or externalize a generated responsibility',
        'Current-host readiness never narrows a portable deployment contract',
        '`planned-output`, not missing',
        'An adapter or interface does not permit externalization',
        'follow recorded capability realization and provisioning ownership',
        'Operator-provided authoritative data does not make a generated component external',
        'Implement one canonical architecture across declared local and operational environments',
        'Do not let operational-only inputs block local setup or startup',
        'A cloud destination does not permit replacing a generated component with a managed service',
        'Keep test doubles, captured transports, and mail-capture tools inside automated tests',
        'Implement provisioning modes exactly',
        'During source generation create no populated secret file',
        'rather than an operator prerequisite',
        '`deployment.runtime_portability: portable`',
        'A dedicated host running a portable deployment remains `portable`',
        'OCI compatibility does not by itself imply Linux',
        'Verifying a declared Linux-container workload',
        'Setup must materialize every `setup-generated` item',
        'containing only unavailable `operator-provided` or `external-provider` items',
        '### Operational and Effect Safety',
        'Never delete, recreate, replace, or reset persistent data',
        'behave as `explicit-confirmation` and recommend refreshing the profile',
        '### Generated Operations',
        'documented, read-only diagnostic command',
        'one canonical operational path',
        'one source repository root containing all generated components',
        'do not divide them into independent repository roots',
        'Repository co-location never permits collapsing confirmed process',
        'For a confirmed split, create the exact named source roots',
        'Do not substitute a generic startup command',
        '### Apply the Experience Policy',
        'do not invent a brand',
        'pinned original resources under `aod/experience-resources/`'
    )
    "$referencesRoot/aod_traceability_format.md" = @(
        'every explicit AOD path and every inferred semantic relation',
        'recognized concept binding',
        'binding-relative constituent',
        'instantiated standing definition',
        'name the inferred binding or instantiation relation it implements',
        'Framework-required declaration-only entries'
    )
    'docs/aod_user_workflow.md' = @(
        'each one either appears exactly in an AOD entry',
        '`Task.Completed` covers structural prefix `Task`',
        'Such entries and prefix coverage add no behavior',
        'Stage 1 asks a follow-up question only when explicitly requested behavior cannot otherwise be represented by a coherent closed-scope package',
        'no proposed answer would add an unrequested action, state transition, data item, effect, lifecycle or stopping rule, or business policy',
        'Missing optional functionality or a nonblocking stopping condition stays outside the initial package',
        'transient family of values supplied directly by a user uses a role-specific root containing `Input`',
        'one nonbehavioral framework-conformance proposal',
        'must be accepted before Stage 2 can finalize',
        'optional nonbehavioral proposal that renames the complete family and every reference atomically',
        'Deferring this style-only item changes no package file or residual concern',
        'a `PROF001` warning identifies a model-valid path',
        'nonblocking `STYLE001` information item',
        'Stages 4 through 6 stop for `PROF001`, but not `STYLE001`',
        '## 2. Optionally Review the Business Design',
        '## 3. Lint the AOD Package',
        '## 4. Optionally Generate a Logical Preview',
        '`Stage: review-package`',
        '`Stage: logical-preview`',
        'The former identifiers `review-design` and `preview` remain compatibility aliases for `review-package` and `logical-preview`, respectively',
        'not a visual-design specification',
        'do not constrain the final program',
        'at most one unresolved proposal at a time',
        'roughly five to ten meaningful proposals are a soft expectation',
        'optional scope extension directly connected to the stated purpose',
        'numbering is task-local and remains continuous',
        'counter is not stored in the AOD package',
        'If no reviewer proposal remains, Stage 2 stays open',
        'Only an explicit standalone `Finish` or `Discard all` terminates the review',
        'Every user-requested package change is first translated into the same pending proposal form',
        'not applied until you subsequently reply `Accept` in a later turn',
        'An `Accept` applies only to the proposal that was already pending before that reply',
        'requires its own later `Accept`',
        'only the already previewed item is applied',
        'use the Stage 2 co-design review',
        '`<project-slug>.aod-traceability.yaml`',
        'read-only traceability-check command',
        'not loaded by the application at runtime',
        'closed business scope',
        '`Technical Realization Decisions`',
        'never as retrospective authorization',
        '`<project-slug>.aod-experience.md`',
        'restrained, accessible internal-tool defaults',
        'Exact content with business or legal meaning remains in the AOD package',
        '`Project name` is the first pending decision',
        'the pending decision remains open until explicitly resolved',
        'prefers a secure, supportable, self-contained deployment',
        'portable versus host-bound output',
        'Containers, OCI, and Linux are conditional technology choices',
        'current machine does not thereby become a profile constraint',
        'complete standards-grounded login-and-session decision',
        'account provisioning, recovery, and lifecycle remain separate',
        'Only genuine operator and external-provider items remain in `Required operator inputs`',
        'preserves a portable runtime boundary',
        'rather than using a generic filename',
        'Each invocation performs exactly one stage',
        'Continue with the next stage in the same task by default',
        'presents all six stages again',
        'red/green unified diff',
        'complete affected declaration',
        'does not ask you merely to reconfirm behavior',
        'Every pending proposal ends with exactly: Reply `Accept`, `Accept deferred BR-nnn`, `Reject`, `Revise: ...`, `Defer`, `Discard all`, `Finish`, or ask a follow-up question.',
        '`Modify` is not offered as a substitute for `Revise: ...`',
        'field-by-field `Column | Before | After` table',
        'Raw replacement rows are not used',
        'newly introduced, independently meaningful business policy',
        'Stage 2 also checks group cohesion',
        'never repartitions merely by line count',
        'replaces only that group with two cohesive groups',
        'complete original and replacement groups',
        'must present a pending BR proposal that replaces only that group with two cohesive groups',
        'sole editorial BR exception',
        'even when the user explicitly requests the regrouping',
        '`Design Decisions` section excludes behavior imposed by the AOD framework',
        'canonical files remain unchanged until finalization',
        '`Discard all` instead ends Stage 2',
        'Within the same Codex task, `Accept deferred BR-nnn` recalls a known deferred proposal',
        'An unknown or nondeferred identifier fails without changing drafts',
        'BR identifiers are not stored in the package',
        'are no longer deferred or eligible for `Accept deferred BR-nnn`',
        'returns to its pre-review deferred status',
        'It writes nothing'
    )
}

foreach ($entry in $requiredTaskPhrases.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf)) {
        continue
    }
    $text = (Get-Content -LiteralPath $entry.Key -Raw) -replace "`r`n?", "`n"
    $normalizedText = ($text -replace '\s+', ' ').Trim()
    foreach ($phrase in $entry.Value) {
        $normalizedPhrase = ($phrase -replace '\s+', ' ').Trim()
        if (-not $normalizedText.Contains($normalizedPhrase)) {
            $errors.Add("$($entry.Key) is missing required task guardrail '$phrase'")
        }
    }
}

foreach ($entry in $requiredHeadings.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf)) {
        continue
    }
    $text = Get-Content -LiteralPath $entry.Key -Raw
    foreach ($heading in $entry.Value) {
        if (-not $text.Contains($heading)) {
            $errors.Add("$($entry.Key) is missing required section $heading")
        }
    }
}

foreach ($entry in $invocationContracts.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf)) {
        continue
    }

    $text = Get-Content -LiteralPath $entry.Key -Raw
    $normalizedText = ($text -replace '\s+', ' ').Trim()
    if ($text.Length -gt 2200) {
        $errors.Add("Invocation contract exceeds 2200 characters: $($entry.Key)")
    }
    if ($text -match '(?im)^Attach (these|the following|:)') {
        $errors.Add("Invocation contract still requests bundled framework attachments: $($entry.Key)")
    }
    foreach ($phrase in $entry.Value) {
        $normalizedPhrase = ($phrase -replace '\s+', ' ').Trim()
        if (-not $normalizedText.Contains($normalizedPhrase)) {
            $errors.Add("$($entry.Key) is missing invocation marker $phrase")
        }
    }
}

foreach ($file in @($invocationContracts.Keys) + $stageProcedures) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        continue
    }
    $text = Get-Content -LiteralPath $file -Raw
    if ($text -notmatch 'standard\s+stage-completion menu required by\s+`SKILL\.md`') {
        $errors.Add("Stage source does not preserve the shared completion menu: $file")
    }
}

$skillFile = "$skillRoot/SKILL.md"
if (Test-Path -LiteralPath $skillFile -PathType Leaf) {
    $skillText = Get-Content -LiteralPath $skillFile -Raw
    if ($skillText -notmatch '(?s)\A---\r?\nname: develop-with-aod\r?\ndescription: .+?\r?\n---') {
        $errors.Add('SKILL.md has invalid or incomplete frontmatter')
    }
    if ($skillText.Contains('[TODO')) {
        $errors.Add('SKILL.md still contains scaffold TODO text')
    }
    if (-not $skillText.Contains('Perform exactly one AOD workflow stage per invocation')) {
        $errors.Add('SKILL.md does not enforce one stage per invocation')
    }
    if ($skillText -notmatch 'Continue with the next stage in the same task by\s+default') {
        $errors.Add('SKILL.md does not default to same-task stage continuation')
    }
    if ($skillText -notmatch 'Start a fresh\s+task only when') {
        $errors.Add('SKILL.md does not constrain fresh-task recommendations')
    }
    if ($skillText -notmatch 'preserve its task-local `BR-nnn` state') {
        $errors.Add('SKILL.md does not preserve task-local BR numbering across review invocations')
    }
    if ($skillText -notmatch 'Apply its deferred\s+recall and explicit completion rules only as defined by\s+`stage_review_package\.md`') {
        $errors.Add('SKILL.md does not delegate Stage 2 recall and completion rules to its procedure')
    }
    if (-not $skillText.Contains('## Complete The Stage')) {
        $errors.Add('SKILL.md does not define stage-completion navigation')
    }
    if (-not $skillText.Contains('**Stage Complete**')) {
        $errors.Add('SKILL.md is missing the stage-completion heading')
    }
    if (-not $skillText.Contains('**Choose The Next Stage**')) {
        $errors.Add('SKILL.md is missing the post-stage menu heading')
    }
    if (-not $skillText.Contains('Keep all six choices visible')) {
        $errors.Add('SKILL.md does not preserve all choices after stage completion')
    }
    if (-not $skillText.Contains('ask a follow-up question, or stop here')) {
        $errors.Add('SKILL.md does not preserve follow-up and stop choices')
    }
    if (-not $skillText.Contains('Accept `1` through `6` as aliases')) {
        $errors.Add('SKILL.md does not define numeric stage aliases')
    }
    if (-not $skillText.Contains('`preview` as a compatibility alias for `logical-preview`')) {
        $errors.Add('SKILL.md does not preserve the preview compatibility alias')
    }
    if (-not $skillText.Contains('accept `review-design` as a compatibility alias for `review-package`')) {
        $errors.Add('SKILL.md does not preserve the review-design compatibility alias')
    }
    if (-not $skillText.Contains('Treat stage selection as its own dialog turn')) {
        $errors.Add('SKILL.md does not isolate stage selection from stage inputs')
    }
    if (-not $skillText.Contains('ask only for the stage')) {
        $errors.Add('SKILL.md does not enforce a stage-only menu turn')
    }
    if (-not $skillText.Contains('Ask directly for one missing stage input before loading references, then stop')) {
        $errors.Add('SKILL.md does not request missing stage input before loading references')
    }
    if ($skillText -notmatch 'Read files separately or in\s+bounded sections') {
        $errors.Add('SKILL.md does not require bounded per-file reference loading')
    }
    if (-not $skillText.Contains('never concatenate bundle output')) {
        $errors.Add('SKILL.md does not prohibit truncation-prone combined bundle reads')
    }
    if ($skillText -notmatch 'Keep loading internal: do not\s+mention commands, limits, truncation, or rereading') {
        $errors.Add('SKILL.md does not keep routine reference loading out of the user dialog')
    }
    if (-not $skillText.Contains('Never ask the user to attach a bundled framework reference')) {
        $errors.Add('SKILL.md does not prohibit requesting bundled framework references')
    }

    foreach ($obsoletePhrase in @(
        '## Confirm Memory Isolation',
        'Memory: off',
        '/memories',
        'Start a fresh task for the next stage'
    )) {
        if ($skillText.Contains($obsoletePhrase)) {
            $errors.Add("SKILL.md retains obsolete workflow text: $obsoletePhrase")
        }
    }

    $stageRouting = [ordered]@{
        'create-package' = $sets['spec-generation']
        'review-package' = $sets['package-review']
        'lint-package' = $sets['linting']
        'logical-preview' = $sets['logical-preview']
        'implementation-profile' = $sets['profile-dialog']
        'generate-program' = $sets['program-generation']
    }
    foreach ($stage in $stageRouting.GetEnumerator()) {
        if (-not $skillText.Contains("``$($stage.Key)``")) {
            $errors.Add("SKILL.md does not name stage $($stage.Key)")
        }
        foreach ($file in $stage.Value) {
            $skillRelativePath = $file.Substring($skillRoot.Length + 1)
            if (-not $skillText.Contains("``$skillRelativePath``")) {
                $errors.Add("SKILL.md stage $($stage.Key) does not load $skillRelativePath")
            }
        }
    }
}

$metadataFile = "$skillRoot/agents/openai.yaml"
if (Test-Path -LiteralPath $metadataFile -PathType Leaf) {
    $metadataText = Get-Content -LiteralPath $metadataFile -Raw
    foreach ($marker in @(
        'display_name: "Develop with AOD"',
        'short_description: "Create and implement applications through AOD"',
        'allow_implicit_invocation: false'
    )) {
        if (-not $metadataText.Contains($marker)) {
            $errors.Add("agents/openai.yaml is missing $marker")
        }
    }
    if ($metadataText -match '(?m)^\s*default_prompt\s*:') {
        $errors.Add('agents/openai.yaml must omit default_prompt so explicit UI selection does not duplicate the skill invocation chip')
    }
}

$legacyActiveNames = @(
    'aod_yaml_spec_generator_instructions.md',
    'aod_business_design_review_instructions.md',
    'aod_yaml_linter_instructions.md',
    'aod_yaml_frontend_generator_instructions.md',
    'aod_implementation_profile_generator_instructions.md',
    'aod_program_generator_instructions.md',
    'aod_yaml_spec_generator_prompt_template.md',
    'aod_business_design_review_prompt_template.md',
    'aod_yaml_linter_prompt_template.md',
    'aod_yaml_frontend_generator_prompt_template.md',
    'aod_implementation_profile_generator_prompt_template.md',
    'aod_program_generator_prompt_template.md',
    'stage_preview.md',
    'prompt_preview.md'
)
foreach ($file in $activeFiles) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        continue
    }
    $text = Get-Content -LiteralPath $file -Raw
    foreach ($legacyName in $legacyActiveNames) {
        if ($text.Contains($legacyName)) {
            $errors.Add("Legacy active filename $legacyName is referenced by $file")
        }
    }
}

$forbiddenOutsideCanonical = @(
    'Document      ::= Group+',
    '## AOD Model Summary',
    '## Frontend-Relevant AOD Interpretation',
    '## Program-Relevant AOD Interpretation',
    '### Accepted AOD-YAML Forms',
    '### Declare vs Define'
)

$forbiddenLegacySemanticTerms = @(
    'startup emission',
    'startup-emission',
    'valued emissions',
    'equal valued emissions',
    'equal emissions',
    'emission policy',
    'occurrence emission',
    'invocation frame',
    'parent frame',
    'child frames',
    'instantiates those paths',
    'environment-provided instantiation',
    'instantiation context'
)

foreach ($file in $activeFiles) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        continue
    }

    $text = Get-Content -LiteralPath $file -Raw
    $fenceCount = ([regex]::Matches($text, '(?m)^```')).Count
    if (($fenceCount % 2) -ne 0) {
        $errors.Add("Unbalanced Markdown fences: $file")
    }
    if ($text -match '[^\x00-\x7F]') {
        $errors.Add("Non-ASCII character found: $file")
    }
    if ($text.Contains('<name>.aod')) {
        $errors.Add("Ambiguous <name> AOD filename placeholder found: $file")
    }
    foreach ($pattern in $forbiddenLegacySemanticTerms) {
        if ($text.Contains($pattern)) {
            $errors.Add("Legacy occurrence or scope terminology '$pattern' found: $file")
        }
    }
    if ($file -ne "$referencesRoot/aod_yaml_model_summary.md") {
        foreach ($pattern in $forbiddenOutsideCanonical) {
            if ($text.Contains($pattern)) {
                $errors.Add("Canonical model content '$pattern' is duplicated in $file")
            }
        }
    }
}

try {
    $profileSchema = Get-Content -LiteralPath "$referencesRoot/aod_implementation_profile.schema.json" -Raw |
        ConvertFrom-Json

    $requiredSchemaPaths = @{
        'deployment.runtime_portability' = $profileSchema.properties.deployment.properties.runtime_portability
        'deployment.prerequisites' = $profileSchema.properties.deployment.properties.prerequisites
        'deployment.lifecycle' = $profileSchema.properties.deployment.properties.lifecycle
        'verification_policy' = $profileSchema.properties.verification_policy
        'experience' = $profileSchema.properties.experience
        '$defs.experiencePolicy' = $profileSchema.'$defs'.experiencePolicy
        '$defs.experienceResource' = $profileSchema.'$defs'.experienceResource
        '$defs.deploymentLifecycle' = $profileSchema.'$defs'.deploymentLifecycle
        '$defs.deploymentLifecycle.properties.persistent_data' =
            $profileSchema.'$defs'.deploymentLifecycle.properties.persistent_data
        '$defs.deploymentLifecycle.properties.migrations' =
            $profileSchema.'$defs'.deploymentLifecycle.properties.migrations
        '$defs.deploymentLifecycle.properties.seed' =
            $profileSchema.'$defs'.deploymentLifecycle.properties.seed
        '$defs.deploymentLifecycle.properties.destructive_reset' =
            $profileSchema.'$defs'.deploymentLifecycle.properties.destructive_reset
        '$defs.nonSecretConfiguration' = $profileSchema.'$defs'.nonSecretConfiguration
        '$defs.provisioningPlan' = $profileSchema.'$defs'.provisioningPlan
        '$defs.provisioningPlan.properties.mode' =
            $profileSchema.'$defs'.provisioningPlan.properties.mode
        '$defs.realization.properties.provisioning' =
            $profileSchema.'$defs'.realization.properties.provisioning
        '$defs.verificationPolicy.properties.real_external_effects' =
            $profileSchema.'$defs'.verificationPolicy.properties.real_external_effects
    }
    foreach ($entry in $requiredSchemaPaths.GetEnumerator()) {
        if ($null -eq $entry.Value) {
            $errors.Add("Implementation-profile schema is missing $($entry.Key)")
        }
    }

    $requiredProvisioningModes = @(
        'profile-defined', 'setup-generated', 'derived',
        'operator-provided', 'external-provider'
    )
    $provisioningModes = $profileSchema.'$defs'.provisioningPlan.properties.mode.enum
    foreach ($mode in $requiredProvisioningModes) {
        if ($provisioningModes -notcontains $mode) {
            $errors.Add("Implementation-profile schema is missing provisioning mode $mode")
        }
    }

    $requiredRuntimePortabilityModes = @('portable', 'host-bound')
    $runtimePortabilityModes = $profileSchema.properties.deployment.properties.runtime_portability.enum
    foreach ($mode in $requiredRuntimePortabilityModes) {
        if ($runtimePortabilityModes -notcontains $mode) {
            $errors.Add("Implementation-profile schema is missing runtime portability mode $mode")
        }
    }
}
catch {
    $errors.Add("Implementation-profile schema is not valid JSON: $($_.Exception.Message)")
}

try {
    $traceSchema = Get-Content -LiteralPath "$referencesRoot/aod_traceability.schema.json" -Raw |
        ConvertFrom-Json

    if ($traceSchema.'$schema' -ne 'https://json-schema.org/draft/2020-12/schema') {
        $errors.Add('Traceability schema does not declare JSON Schema Draft 2020-12')
    }
    if ($traceSchema.'$id' -ne 'urn:aod:schema:traceability:v1') {
        $errors.Add('Traceability schema has an unexpected $id')
    }
    if ($traceSchema.properties.schema.const -ne 'aod-traceability/v1') {
        $errors.Add('Traceability schema does not require schema: aod-traceability/v1')
    }

    $requiredTraceProperties = @(
        'schema', 'package', 'implementation', 'confirmed_user_decisions',
        'mappings', 'implementation_surfaces'
    )
    foreach ($property in $requiredTraceProperties) {
        if ($traceSchema.required -notcontains $property) {
            $errors.Add("Traceability schema does not require top-level property $property")
        }
    }

    $requiredTraceSchemaPaths = @{
        '$defs.packagePin' = $traceSchema.'$defs'.packagePin
        '$defs.implementation' = $traceSchema.'$defs'.implementation
        '$defs.userDecision' = $traceSchema.'$defs'.userDecision
        '$defs.mappingSources' = $traceSchema.'$defs'.mappingSources
        '$defs.locator' = $traceSchema.'$defs'.locator
        '$defs.location' = $traceSchema.'$defs'.location
        '$defs.mapping' = $traceSchema.'$defs'.mapping
        '$defs.implementationSurface' = $traceSchema.'$defs'.implementationSurface
        '$defs.experiencePin' = $traceSchema.'$defs'.experiencePin
        '$defs.experienceResourcePin' = $traceSchema.'$defs'.experienceResourcePin
    }
    foreach ($entry in $requiredTraceSchemaPaths.GetEnumerator()) {
        if ($null -eq $entry.Value) {
            $errors.Add("Traceability schema is missing $($entry.Key)")
        }
    }

    if ($traceSchema.'$defs'.packagePin.required -notcontains 'experience') {
        $errors.Add('Traceability schema package pin does not require experience')
    }
    if ($null -eq $traceSchema.'$defs'.mappingSources.properties.experience) {
        $errors.Add('Traceability schema mapping sources do not support experience references')
    }

    $requiredLocatorKinds = @(
        'symbol', 'route', 'selector', 'schema-field', 'source-marker',
        'configuration', 'file', 'test', 'other'
    )
    $locatorKinds = $traceSchema.'$defs'.locator.properties.kind.enum
    foreach ($kind in $requiredLocatorKinds) {
        if ($locatorKinds -notcontains $kind) {
            $errors.Add("Traceability schema is missing locator kind $kind")
        }
    }
}
catch {
    $errors.Add("Traceability schema is not valid JSON: $($_.Exception.Message)")
}

$rows = foreach ($entry in $sets.GetEnumerator()) {
    if ($entry.Value | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Leaf) }) {
        continue
    }
    $payload = ($entry.Value | ForEach-Object {
        (Get-Content -LiteralPath $_ -Raw) -replace "`r`n?", "`n"
    }) -join "`n"
    $characters = $payload.Length
    if ($characters -gt $budgets[$entry.Key]) {
        $errors.Add(
            "$($entry.Key) payload is $characters characters; budget is $($budgets[$entry.Key])"
        )
    }
    [pscustomobject]@{
        Stage = $entry.Key
        Files = $entry.Value.Count
        Characters = $characters
        Words = ([regex]::Matches($payload, '\S+')).Count
        ApproxTokens = [math]::Ceiling($characters / 4)
        Budget = $budgets[$entry.Key]
    }
}

$rows | Format-Table -AutoSize

if ($errors.Count -gt 0) {
    Write-Host ''
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host ''
Write-Host 'AOD instruction consistency check passed.'
