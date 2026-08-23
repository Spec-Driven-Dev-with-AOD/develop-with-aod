# AOD Framework Package Profile

`aod_framework_package_profile.md` defines authoring requirements imposed by the `develop-with-aod` framework in addition to the AOD model. It does not change AOD semantics.

## Explicit Path Declarations

The AOD model permits controlled implicit path declarations. A package produced, revised, accepted for downstream use, or used for generation by this framework follows a stricter profile: every AOD path inferred or assumed during semantic interpretation must also occur explicitly as an AOD-YAML entry.

A path is already explicit when it occurs in any of the four AOD entry forms: a bare or determined entry in the given context, a triggering path `Q` with a reaction list, or a bare or determined target in a reaction list. Do not add a second bare entry for such a path.

Build the complete path inventory under `aod_yaml_model_summary.md`, including:

- paths referenced only in an unquoted determining declaration `D`;
- undeclared prefix paths of longer paths;
- application-concept path `T` recognized through a concept binding;
- concept-rooted constituent path `T.X` and binding-relative constituent path `P.X` inferred from a clear constituent description;
- projection or write-through paths implied by a binding; and
- any other AOD path on which the interpretation depends but which has not appeared as an entry.

For every inventory path absent from all entry forms, add exactly one bare given-context entry:

```yaml
- P
```

Place it in the most relevant existing group near its first semantic use. Add a new group only when no existing reading concern fits. Preserve existing groups and declaration order as far as possible. Do not add duplicate bare entries or repeat a path across groups.

The added entry declares `P` only. It does not define, initialize, resolve, observe, attain, persist, or expose `P`, and it does not by itself require an environment-contract row. Required roles and environment support still follow from the path's substantive uses under the AOD model.

Do not invent a path merely to make prose look structured. If a possible path, concept binding, constituent, projection, or prefix is materially ambiguous, clarify the interpretation first; add the bare entry only after the path inference is justified.

## Stage Enforcement

- `create-package` adds every required bare entry before final lint and package creation.
- `review-package` presents missing entries as one exact, nonbehavioral framework-conformance proposal and applies them only after the normal preview-and-accept gate. It cannot finalize a working draft that still omits required entries.
- `lint-package` is nonmutating. It reports each missing bare entry as a framework-profile `WARNING`, explains that the input may still be valid AOD, and gives the exact entries to add.
- `logical-preview`, `implementation-profile`, and `generate-program` stop when required explicit entries are missing and direct the user to `review-package` or `create-package`. They never assume or silently add paths.

Explicit-declaration normalization is package mechanics, not application behavior. Do not record it under `Design Decisions`, create environment-contract rows solely for it, or treat it as authority for an implementation feature.
