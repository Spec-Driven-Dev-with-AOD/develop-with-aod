# AOD Implementation Traceability Format

`aod_traceability_format.md` defines the meaning and coverage rules of a generated `<project-slug>.aod-traceability.yaml` file. `aod_traceability.schema.json` defines its structure.

## Purpose and Authority

The traceability file is a derived, technology-independent index from AOD sources to implementation and tests, plus a reverse inventory of material business surfaces. It helps an AOD user, maintainer, reviewer, or LLM find the program parts that realize a declaration and detect implementation elements without an approved source.

The file is not AOD-YAML, does not declare behavior, and is not a runtime input. It never authorizes an implementation element. The AOD package governs behavior and environment responsibilities; the optional experience brief governs compatible presentation and editorial choices; the implementation profile governs technology and confirmed implementation choices; `aod-environment-realization.md` records environment realization and Technical Realization Decisions. If traceability conflicts with those sources or the code, traceability is invalid.

Creating a mapping cannot legitimize an additional business rule, persisted domain or audit field, data exposure, conflict or failure policy, API field, user-visible capability, or external effect. Such an element must already have a genuine governing source. A `TRD-nnn` may explain only a semantics-preserving technical mechanism.

## Filename and Schema

Place exactly one file named `<project-slug>.aod-traceability.yaml` in the generated project root. `<project-slug>` must match the implementation profile and AOD package filenames.

Parse the file as ordinary YAML and validate the resulting data against `aod_traceability.schema.json`, using JSON Schema Draft 2020-12. Use `schema: aod-traceability/v1`. The generated project contains an exact copy of that generic schema for local and CI validation. Paths are project-relative, use forward slashes, and must not escape the project root. Do not use absolute paths.

## Package and Implementation Pins

Store exact, non-secret-bearing provenance copies of the validated AOD-YAML, context, and implementation profile under the generated project's `aod/` directory. When the profile selects a brief, also store its exact copy under `aod/` and every pinned original resource under `aod/experience-resources/`. They are pinned generation inputs, not runtime inputs or independently editable authorities. Copy the package format, package ID, revision, AOD profile, context format, implementation-profile schema, experience mode, and all applicable project-relative provenance paths into the traceability file. Compute every exact-byte SHA-256 digest from those copies. Never estimate or copy a stale digest.

For `restrained-internal-tool-defaults`, record only that mode. For `brief`, record its format, copy path, and digest and preserve each resource's role, optional media type, copy path, and digest. Runtime-ready transformations or placements of a logo or other asset are implementation locations, not substitutes for the pinned originals.

Set `implementation.project_root` to `.` and name `aod-environment-realization.md` as the realization report. Record one project-local, read-only traceability-check command under `implementation.traceability_check.command`.

## Confirmed User Decisions

Use `confirmed_user_decisions` only for an explicit additional implementation direction that authorizes a presentation, data-exposure, or implementation choice not otherwise represented by the AOD package, experience brief, or profile. Assign stable `USER-001`, `USER-002`, and so on and record the decision narrowly.

Do not use `USER-nnn` to introduce business behavior. A decision affecting domain acceptance or rejection, state transitions, effects, conflict or failure policy, persistence semantics, or authorization belongs in a revised AOD package before generation continues. Use an empty list when no additional direction requires a durable trace source.

## Forward Mappings

Assign stable `TRACE-001`, `TRACE-002`, and so on. Each mapping identifies one coherent implementation concern and contains:

- `kind`: the represented AOD, environment, or technical concern;
- `sources`: exact governing references;
- `implementation`: one or more project files with typed locators and implementation roles; and
- `tests`: relevant test locations, or an empty list only when testing is genuinely inapplicable.

Use exact AOD path names and compact causal references such as ``Decision.Persisted -> Decision.Notified``. Use exact `ENV-nnn`, `TRD-nnn`, `USER-nnn`, concise profile-field references, and concise experience-brief heading or controlled-copy references. A mapping may combine references only when the same implementation locations jointly realize them. Do not map an entire specification or experience brief to one broad service or file.

Cover every explicit or inferred AOD path, recognized concept binding, binding-relative constituent, instantiated standing definition, reaction, capability use, progress or termination rule, and environment responsibility that materially affects generated behavior. A mapping may reference the nearest explicit declaration and name the inferred path or binding relation it implements. Editorial groups, comments, and implicit prefixes that require no separate implementation need no mapping.

Use typed locators rather than mandatory language-specific naming. Supported locator kinds are `symbol`, `route`, `selector`, `schema-field`, `source-marker`, `configuration`, `file`, `test`, and `other`. Prefer stable symbols, routes, selectors, schema fields, or source markers over line numbers. Never use line numbers as authoritative locators.

## Source Markers

At major causal, capability, persistence, and external-effect boundaries, place a concise inert source comment containing the mapping identifier, for example:

```typescript
// AOD TRACE-012: DecisionToRecord.Request.Decision
// -> EmployeeDecisionNotification.Sent
```

Use the native comment syntax of the generated language. Do not introduce decorators, annotations, reflection metadata, runtime registries, imports, dependencies, or naming distortions for traceability. Comments must not alter generated behavior. The mapping may locate the comment with `kind: source-marker`.

## Reverse Scope Inventory

Assign stable `SCOPE-001`, `SCOPE-002`, and so on to every material implementation surface covered by the closed-scope rule:

- user-visible behavior, controls, and views;
- material presentation styles and controlled editorial copy;
- business endpoints;
- persisted domain and audit fields;
- domain rejection rules;
- observable conflict and failure policies;
- API-exposed fields and other data exposure; and
- external effects.

Each surface records its implementation location and one or more `TRACE-nnn` mappings that genuinely authorize it. Several surfaces may cite one mapping, and one surface may require several mappings. Routine framework plumbing, formatting code, dependency declarations, and internal infrastructure with no material semantic or exposure consequence need no surface entry.

A business surface cannot be authorized solely by `TRD-nnn`. A presentation surface may cite a mapping grounded in the experience brief, an explicit `USER-nnn`, or a compatible profile decision; a data-exposure surface requires an explicit governing source for that exposure. A behavior, domain rule, state transition, or business effect requires an AOD source. Remove an unnecessary untraceable surface; if it is necessary, stop and obtain the appropriate package or profile revision.

## Generated Validation

Generate a project-local traceability checker using the confirmed project stack and expose the command recorded in the traceability file. It must be read-only and must:

1. parse YAML with a structured parser and validate it against `aod_traceability.schema.json`;
2. verify package identity, revision, filenames, project slug, experience policy and resources, and exact file digests;
3. require unique `USER-nnn`, `TRACE-nnn`, and `SCOPE-nnn` identifiers and valid cross-references;
4. verify referenced `ENV-nnn` and `TRD-nnn` entries exist in the context and realization report and every experience reference exists in the pinned brief;
5. verify every referenced project file exists within the project root;
6. verify each declared locator or source marker exists using a stack-appropriate parser or conservative exact lookup;
7. check declared forward coverage and require every reverse surface to cite an existing mapping; and
8. fail when a business surface relies only on a Technical Realization Decision.

The checker verifies declared structure and evidence. Technology-independent automation cannot prove that the generator found every semantic surface or that every mapping is substantively honest. The program generator must therefore perform the complete forward and reverse audit before writing the file, and the AOD user or reviewer may inspect the result.

## Generation and Maintenance

Generate traceability after the implementation and tests exist. Add source comments, create the traceability file and checker, validate them, and then rerun formatting, static analysis, tests, and the production build. Keep traceability outside runtime loading and deployment behavior; it may remain as project documentation or be excluded from runtime images.

When generated code, AOD package files, the experience brief or resources, the implementation profile, or material tests change, update and revalidate traceability in the same change. Do not preserve a stale mapping merely to satisfy the schema.

## Compact Example

```yaml
schema: aod-traceability/v1
package:
  format: aod-package/v1
  id: 72dec485-b593-4612-a59e-1a848f29ee2f
  revision: 2
  specification:
    file: aod/vacation-request.aod.yaml
    profile: aod-yaml/v1
    digest: sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  context:
    file: aod/vacation-request.aod-context.md
    format: aod-context/v1
    digest: sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
  implementation_profile:
    file: aod/vacation-request.aod-implementation.yaml
    schema: aod-implementation-profile/v1
    digest: sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
  experience:
    mode: brief
    file: aod/vacation-request.aod-experience.md
    format: aod-experience/v1
    digest: sha256:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
implementation:
  project_slug: vacation-request
  project_root: .
  realization_report: aod-environment-realization.md
  traceability_check:
    command: npm run aod:traceability
confirmed_user_decisions: []
mappings:
  - id: TRACE-001
    kind: reaction
    sources:
      aod:
        - DecisionToRecord.Request.Decision -> EmployeeDecisionNotification.Sent
      environment:
        - ENV-011
        - ENV-013
      experience:
        - Controlled Editorial Copy: decision notification framing
    implementation:
      - file: backend/src/vacation/vacation.service.ts
        locator:
          kind: symbol
          value: VacationService.decide
        role: reaction and effect boundary
    tests:
      - file: backend/test/vacation.service.spec.ts
        locator:
          kind: test
          value: persists decision before notification
        role: verifies causal ordering
implementation_surfaces:
  - id: SCOPE-001
    kind: external-effect
    description: Send the employee decision notification after persistence.
    location:
      file: backend/src/vacation/vacation.service.ts
      locator:
        kind: symbol
        value: VacationService.decide
      role: notification dispatch
    authorized_by:
      - TRACE-001
```
