# AOD Experience Brief Format

`aod_experience_format.md` defines the optional `<project-slug>.aod-experience.md` artifact used during final program generation. The brief records confirmed presentation, brand, and editorial guidance without extending AOD behavior.

## Purpose and Authority

The experience brief may govern audience, language and locale, tone, terminology, accessibility, information density, corporate identity, supplied visual resources, controlled interface copy, editorial notification wording, and the generator's presentation latitude.

It is not AOD-YAML, an environment contract, or an implementation profile. It must not add actors, data, controls, workflows, domain rules, state transitions, effects, authorization, persistence, or capability success semantics. The AOD package remains authoritative for behavior and for notification content with business or legal meaning. The environment contract and implementation profile remain authoritative for provider technology, delivery, and success semantics. On conflict, stop for correction of the appropriate governing artifact.

## Filename and Profile Pin

When the user opts into an experience brief, create exactly one `<project-slug>.aod-experience.md`. The implementation profile records `experience.mode: brief`, the canonical filename, `format: aod-experience/v1`, and the exact-byte SHA-256 digest. It also pins every attached non-secret experience resource used as normative input.

When the user opts out, create no brief and record `experience.mode: restrained-internal-tool-defaults`. In that mode, use the package's language and terminology when available, otherwise concise neutral English; build a compact, accessible internal-tool interface; use plain editorial wording; and do not invent a brand, logo, slogan, marketing voice, or decorative identity.

## Required Structure

Use this compact structure and retain every heading. Write `None` where no guidance is supplied.

```markdown
# AOD Experience Brief: <project name>

- Experience format: `aod-experience/v1`
- Project slug: `<project-slug>`

## Audience and Locale
<audience, user-facing language, locale, and any role-sensitive wording>

## Brand and Resources
<corporate identity, design-guide references, logo and asset filenames, or `None`>

## Tone and Terminology
<tone, preferred terms, prohibited terms, capitalization, or `None`>

## Accessibility and Information Density
<accessibility requirements, density, responsive priorities, or `None`>

## Controlled Editorial Copy
<exact labels, headings, greetings, subject/body framing, reusable phrases, or `None`>

## Generator Discretion
<presentation choices the generator may make and explicit presentation exclusions>
```

Keep the brief concise and implementation-independent. Reference resources by the exact relative filenames pinned under `experience.resources` in the implementation profile; do not embed binary data. Do not include passwords, tokens, private keys, personal credentials, confidential production data, or other secret material.

## Content Boundary

Exact labels, greetings, layout wording, and visual presentation belong in the brief. A notification's declared recipient, triggering condition, required facts, and any exact content with business or legal meaning belong in the AOD package. Editorial framing may be specified in the brief only when it preserves that declared meaning. SMTP, messaging-provider, delivery, retry, and success behavior belong in the environment contract and implementation profile.

If proposed experience guidance implies new behavior or data, do not dilute it into presentation prose. Return to the AOD package or environment contract and revise that authority first.
