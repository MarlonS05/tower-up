<!--
  TEMPLATE — copy to docs/<feature>-design-spec.md and fill in the
  {{PLACEHOLDERS}}. One spec per feature. The goal: a coding agent can implement
  the feature end-to-end from this document without guessing. Delete sections
  that don't apply, but keep the AGENT METADATA header and the checklist.
-->

# {{FEATURE_NAME}} — Design & Layout Specification

<!--
  AGENT METADATA — parse before implementing
  feature_id: {{feature_id}}
  product_name: {{PRODUCT_NAME}}
  source: {{DESIGN_SOURCE_URL_OR_NA}}
  target_platform: {{TARGET_PLATFORM}}
  status: {{design-only | in-progress | shipped}}
-->

> **Purpose:** Machine-readable design spec for implementing {{FEATURE_NAME}}.
> **Audience:** Coding agents and contributors. Follow `AGENTS.md` and
> `docs/architecture.md` before writing code.

---

## Document map

| § | Section |
|---|---------|
| 0 | [Repo conventions](#0-repo-conventions) |
| 1 | [Feature overview](#1-feature-overview) |
| 2 | [Data model](#2-data-model) |
| 3 | [Component reuse](#3-component-reuse) |
| 4 | [Screens](#4-screens) |
| 5 | [Navigation & state](#5-navigation--state) |
| 6 | [Interaction & tokens](#6-interaction--tokens) |
| 7 | [Out of scope](#7-out-of-scope) |
| A | [Implementation checklist](#appendix-a-implementation-checklist) |

---

## 0. Repo conventions

How the repo-wide rules from `AGENTS.md` apply to this feature. One row per rule.

| Rule | This feature |
|------|--------------|
| {{STATE/CONTROLLER}} + codegen | {{Controller class names}} |
| All screens registered in {{ROUTER}} | Add route when adding a screen; BLoCs navigate only via registered routes |
| All navigation in BLoCs / {{STATE/CONTROLLER}} | Views dispatch events only; BLoC calls {{ROUTER}} — never navigate from views |
| Widget classes | Screen-specific private widgets in the same `*_view.*` file; shared widgets under `screens/components/` (subdirs OK) — no separate widget files inside a screen folder |
| Infra I/O | {{Which domain ports this feature uses}} |
| Persistence | {{Repository + use cases involved}} |
| Writes | {{Use cases under `domain/use_cases/<entity|function>/` — controllers do not write directly}} |
| Errors | {{Error-handling pattern}} |
| Theme | {{Design tokens used}} |

**Replaces:** {{existing placeholder/route, or "N/A".}}

**Reference implementations:** {{point to an existing feature folder to copy.}}

---

## 1. Feature overview

### 1.1 Screens

| Screen | Route | Top bar |
|--------|-------|---------|
| {{Screen}} | `{{/route}}` | {{Title}} |

Entry: {{how the user reaches this feature.}}

### 1.2 Flows

- **{{Flow name}}:** {{step → step → outcome.}}
- **Back:** {{back behavior.}}

---

## 2. Data model

```{{lang}}
{{enums / entities / value objects this feature introduces}}
```

| Value | Label | Notes |
|-------|-------|-------|
| {{value}} | {{label}} | {{behavior}} |

**Default:** {{default value.}}

**Persistence:** {{use cases / repository methods for read and write.}}

---

## 3. Component reuse

### 3.1 Reuse as-is
{{Existing components used unchanged.}}

### 3.2 Adapt
{{Existing components needing small changes; describe the change.}}

### 3.3 Do not reuse
{{Components that look similar but must not be used here, and why.}}

### 3.4 Build new
{{Screen-specific: private Widget classes in the screen’s `*_view.*`. Shared:
path under `screens/components/` (subdirs OK) + props/API. Never add separate
widget files inside a screen folder.}}

---

## 4. Screens

Repeat this block per screen.

```yaml
route: {{/route}}
folder: {{path/to/feature/screen/}}
{{controller}}: {{ControllerName}}
view: {{ViewName}}
```

```
{{Widget/component tree — indentation shows nesting. Include the shell,
 error-handling wrapper, top bar, and the body layout.}}
```

**Selection / actions:** {{what taps do, which use case runs, resulting nav.}}

**States & styling:** {{selected / pressed / disabled / loading tokens.}}

---

## 5. Navigation & state

### Routes

```{{lang}}
{{route constants to add}}
```

### {{Controller}} events

**{{ControllerName}}:** `started`, {{event}}, `backTapped`
- {{event}}: {{what it does — request, refresh, navigate, etc.}}

---

## 6. Interaction & tokens

- {{Spacing, gaps, tint constants, icon sizes — reference the design tokens,
   never hardcoded values.}}
- All screens: {{error-handling wrapper}} on error state.

---

## 7. Out of scope

{{Explicitly list what this version does NOT do, so the agent doesn't build it.}}

---

## Appendix A. Implementation checklist

```
[ ] {{Data model + persistence (entity, repository, use cases)}}
[ ] {{New/updated shared widgets}}
[ ] {{Controllers + views (error-handling pattern)}}
[ ] {{Routes + DI wiring}}
[ ] {{Verify: analyzer + architecture import test}}
```
