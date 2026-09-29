# AGENTS.md — Tower Up

Flutter tower-defense game with local saves (Flame). Read `docs/architecture.md`
and the relevant `docs/*-design-spec.md` before making changes. For Dart/Flutter
practices, see `docs/agent-guidelines/`.

## Architecture & layers

- **Layers:** `domain/` (entities, models, repository interfaces, service ports,
  use cases, business, formatters, validators) · `repo/` (repository impls) ·
  `db/` (SQLite via `AppDatabase` + DAOs) · `platform/` (OS/plugin adapters) ·
  `game/` (Flame game, components, overlays) · `screens/` (menus/HUD shells +
  BLoCs) · `router/`, `di/`, `theme/`, `logger/`.
- **BLoC** talks to a **use case** for writes/deletes and to a **repository**
  for simple reads.
- **All navigation happens in BLoCs** — views only dispatch events; never
  call the router or navigator from a view/widget. BLoCs navigate via the
  registered router API — never `context.push` / `context.go` / `Navigator`
  route changes from a view.
- **Register every screen in `router/`** — each screen has a route entry;
  BLoCs navigate only via those registered routes (never ad-hoc paths or
  view-level navigation).
- **No infrastructure in BLoCs** (no `sqflite`, `path_provider`, `shared_preferences`,
  raw Flame engine wiring beyond injecting a domain-facing game port, `http`, etc.).
- **`lib/domain/` must not import** `package:flutter/`, `package:flame/`,
  `screens/`, `game/`, `repo/`, `db/`, `platform/`, `router/`, `di/`, `theme/`,
  `flutter_bloc/`, or `go_router/`.
- Import boundaries are documented in `docs/architecture.md`. Planned
  enforcement: `towerup_lint_rules` and
  `test/architecture/layer_import_test.dart` (not created yet). Update the
  architecture table (and enforcement artifacts when they exist) if boundaries
  change.

## Conventions

- **One directory per screen** under `screens/<feature>/<screen>/` — BLoC,
  Freezed event/state, and UI (`*_view`) live together; never share a folder
  across screens (see `docs/project-structure.md`).
- **Widget classes.** Prefer `Widget` classes over helper methods that return
  a `Widget`. Screen-specific private widgets live in the same `*_view.*`
  file; shared widgets live under `screens/components/` (see
  `docs/project-structure.md`). Prefer `StatelessWidget` before `StatefulWidget`.
- **Dart/Flutter practices.** Interaction, tooling, style, serialization,
  testing, layout/assets, and dartdoc — see `docs/agent-guidelines/`.
- **Use cases grouped by entity/function** under `domain/use_cases/<group>/`
  — do not dump all use cases in one flat folder (see `docs/project-structure.md`).
- **Non-trivial business logic** lives under `domain/business/<group>/`
  — keep use cases thin; extract multi-step rules, calculations, and
  reusable domain decisions (see `docs/project-structure.md`).
- **DI registration split by kind** in `di/` — `_registerSingletons`,
  `_registerUseCases`, `_registerScreens` (etc.), with comment-marked
  sections inside; call them from one startup method in `main` (see
  `docs/project-structure.md`).
- **Routes + navigation.** Register every new screen and its route in
  `router/`. Views dispatch navigation-intent events; the BLoC calls the
  router for that registered route. No `context.go` / `Navigator` / router
  imports in `*_view.*` or shared components.
- **Keep docs in sync.** When you add or change functionality, structure, or
  layer boundaries, update the relevant docs in the same change — especially
  `docs/architecture.md`, affected `docs/*-design-spec.md`, and enforcement
  artifacts (lint rules, architecture tests) when boundaries change.
- State classes use **freezed**; run
  `dart run build_runner build --delete-conflicting-outputs` after editing
  `*_event.dart` / `*_state.dart` (or other Freezed/json_serializable sources).
- UI uses tokens under `lib/theme/` (`TowerTheme` / spacing / radius / text
  styles). Menu/shell errors via `BlocConsumer` + a shared error dialog; in-game
  feedback via Flame overlays (not view-level navigation).
- SQLite: bump `AppDatabase` version, add a migration under `db/migrations/`,
  and mirror additive DDL in schema for fresh installs.
- Log API interactions at completion in the shared HTTP client when one exists —
  see `docs/architecture.md`; use `Success …` / `Failed …` with `logger.i` /
  `logger.w`. Configure the shared logger in `lib/logger/`.
- Temporary diagnostic logs while investigating: `logger.d` only — remove before
  considering work done.
- **Catch every database exception** — never let DB errors propagate
  uncaught. Detail: `docs/agent-guidelines/07-database-exceptions.md`.
- **DB open on startup** must be `try`/`catch`ed in `main` (before
  `runApp`). On failure: log with `logger.w` and `runApp` a fatal-error screen
  only — do not enter the main UI.

## Flame / game loop

Gameplay lives under `lib/game/` (Flame `FlameGame`, components, overlays).
Menu and meta-UI live under `screens/` and host `GameWidget` where needed.
The game layer may use domain types and ports; it must not import `repo/`,
`db/`, `di/`, or `router/`. Persist progress through use cases / repository
interfaces (local saves), not by opening SQLite from game code. Flame docs:
https://docs.flame-engine.org/latest/README.html

## Plan mode

When using Plan mode, the plan body contains only three sections — see
[plan.template.md](../agent-instructions/plan.template.md): **Description**,
**Files & layers** (mermaid diagram), and **Code to add** (exact snippets, not
prose about what to write). Omit goals-as-bullets, step narratives, checklists,
assumptions, and file-touch summaries.

## Commits

Use this format for commit messages:

```
[<type>] <short description>
```

Choose `type` from:

| Type | Use for |
|------|---------|
| `feat` | Feature |
| `fix` | Bug fix |
| `style` | Styling |
| `refrac` | Verbesserung des Codes |
| `test` | Automatisierte Tests |
| `docs` | Dokumentation |
| `project` | Änderungen der Projektkonfiguration |
| `perf` | Verbesserung der Performance |
| `wip` | Work in Progress / Zwischenstände |

Example: `[feat] Add order export to CSV`

## Verify

```bash
flutter analyze
flutter test
```
