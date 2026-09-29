# Project structure

Recommended folder scaffolding for Tower Up. The key idea: **one directory per
layer**, **one directory per screen** in presentation (BLoC + Freezed
event/state + UI together), a separate **lint-rules package**, a **Flame game**
folder, and an **architecture test** that guards the whole thing.

## Recommended tree

```
towerup/
├── AGENTS.md                         # terse agent rules
├── docs/
│   ├── architecture.md               # layers + strict import table
│   ├── project-structure.md          # this file
│   ├── enforcement.md                # import-boundary enforcement guide
│   ├── agent-guidelines/             # Dart/Flutter practices + templates
│   └── <feature>-design-spec.md      # one machine-readable spec per feature
├── towerup_lint_rules/               # planned — deny-list rules class
│   └── lib/
│       └── layer_import_rules.*      # path-keyed deny-lists (single source of truth)
├── lib/
│   ├── domain/                       # PURE: entities, models, repositories (interfaces),
│   │   ├── entities/                 #        services (ports), use_cases, business, formatters, validators
│   │   ├── models/
│   │   ├── repositories/             # interfaces only
│   │   ├── services/                 # ports (interfaces) to infra
│   │   ├── use_cases/                # thin orchestration; grouped by entity/function
│   │   │   ├── <entity>/             # e.g. save/, wave/
│   │   │   │   └── <verb>_<noun>_use_case.*
│   │   │   └── <function>/           # e.g. sync/ — when not tied to one entity
│   │   │       └── <verb>_<noun>_use_case.*
│   │   ├── business/                 # non-trivial domain logic extracted from use cases
│   │   │   ├── <entity>/             # same grouping as use_cases/
│   │   │   │   └── <descriptive_name>.*
│   │   │   └── <function>/
│   │   │       └── <descriptive_name>.*
│   │   ├── formatters/
│   │   └── validators/
│   ├── repo/                         # repository implementations (fulfil domain interfaces)
│   ├── db/                           # persistence — connection, schema, migrations, DAOs
│   │   ├── app_database.*            # open/close, version, transaction()
│   │   ├── schema/                   # CREATE TABLE DDL
│   │   ├── migrations/               # incremental upgrade steps
│   │   └── daos/                     # one DAO per table/aggregate — SQL CRUD
│   │       └── <entity>_dao.*
│   ├── platform/                     # OS/plugin adapters implementing domain ports
│   ├── game/                         # Flame — FlameGame, components, overlays
│   │   └── …                         # no repo/db/di/router imports
│   ├── screens/                      # PRESENTATION — one directory per screen
│   │   ├── components/               # shared / reusable widgets only
│   │   │   ├── <widget>.*            # not screen-specific; subdirs OK
│   │   │   └── <group>/              # optional subdirectories (e.g. menu/, hud/)
│   │   │       └── <widget>.*
│   │   └── <feature>/
│   │       └── <screen>/             # e.g. main_menu/ — view + BLoC files only
│   │           ├── <screen>_view.*   # UI (+ private screen-specific Widget classes OK)
│   │           ├── <screen>_bloc.*   # logic + navigation; NO plugins/data-access
│   │           ├── <screen>_event.*  # Freezed-friendly events
│   │           ├── <screen>_state.*  # Freezed-friendly state
│   │           ├── <screen>_bloc.freezed.dart   # codegen (do not edit)
│   │           └── … other generated parts as needed
│   ├── router/                       # route table — register every screen here
│   │   └── …                         # BLoCs call these registered routes only
│   ├── di/                           # dependency injection wiring
│   ├── theme/                        # design tokens (colors, spacing, radius, text styles)
│   ├── logger/                       # shared Logger instance (see Logger setup below)
│   │   └── logger.*
│   └── main.* (entrypoint)
└── test/
    └── architecture/
        └── layer_import_test.*       # planned — walks lib/, fails on denied imports
```

## Folder purposes

| Folder | Contains | Never contains |
|--------|----------|----------------|
| `domain/` | Pure business types, interfaces, use cases, business logic | Framework, Flame, UI, DB, platform imports |
| `repo/` | Repository implementations | UI, routing, DI, state-mgmt, game |
| `db/` | `AppDatabase`, schema, migrations, DAOs | UI, repo, routing, DI, game |
| `platform/` | Adapters for OS/plugins (implement domain ports) | UI, repo, db, routing, DI, game |
| `game/` | Flame `FlameGame`, components, overlays | `repo/`, `db/`, `di/`, `router/` |
| `screens/<feature>/<screen>/` | One screen’s view + BLoC + Freezed event/state (+ generated); private Widget classes may live in `*_view.*` | Separate widget *files*; other screens; data-access / navigation packages |
| `screens/components/` | Shared / reusable UI widgets (subdirs OK) | Data-access, routing, DI, state-mgmt; screen BLoC/view files |
| `router/` | Route table — every screen registered here | Business logic; ad-hoc unregistered routes |
| `di/`, `theme/`, `logger/` | Cross-cutting wiring, tokens, logging | Business logic |

## Naming conventions

- **One directory per screen.** Every screen gets its own folder under
  `screens/<feature>/`. That folder holds only the screen’s view, BLoC,
  Freezed event/state, and generated parts — no separate widget *files*.
  Example:

  ```
  screens/menu/main_menu/
  ├── main_menu_view.dart      # UI (+ private screen-specific Widget classes)
  ├── main_menu_bloc.dart      # BLoC
  ├── main_menu_event.dart     # Freezed events
  ├── main_menu_state.dart     # Freezed state
  └── main_menu_bloc.freezed.dart   # generated — do not edit
  ```

- **Widget classes:** Prefer small `Widget` subclasses over methods returning
  `Widget`. Screen-only pieces: private classes in `*_view.*`. Shared:
  `screens/components/` only — do not add separate widget files inside a
  screen directory. Subdirectories under `components/` are allowed for
  grouping.

  ```
  screens/components/
  ├── primary_button.dart
  ├── currency_badge.dart
  └── menu/
      └── level_row.dart
  ```

- **Feature folders**: one folder per feature under `screens/`, then one
  subfolder per screen (as above).
- **Presentation files** use consistent suffixes so the enforcement test can key
  rules off them:
  - `*_view.*` — the UI view (render + dispatch only; **no navigation**)
  - `*_bloc.*` (or `*_controller.*`) — logic + **all navigation** (calls router)
  - `*_event.*` / `*_state.*` — Freezed inputs/outputs (codegen-friendly)
  - `*.freezed.dart` — generated Freezed parts (never hand-edit)
- **Navigation & routes:** register every screen and its route in `router/`
  when adding a screen. Only BLoCs navigate — a view that needs to leave
  dispatches an event; the BLoC calls the router for that registered route.
  Never navigate from `*_view.*` or `screens/components/`, and never use
  paths that are not registered in the router.
- **Use cases**: one class per write/delete operation, named
  `<Verb><Noun>UseCase` (e.g. `CreateOrUpdateSaveUseCase`,
  `DeleteSaveUseCase`). Sort them into subdirectories under
  `domain/use_cases/` by the entity they serve, or by function when the
  operation is not tied to a single entity — never a flat dump of all use
  cases in `use_cases/`.

  ```
  domain/use_cases/
  ├── save/
  │   ├── create_or_update_save_use_case.dart
  │   └── delete_save_use_case.dart
  └── wave/
      └── resolve_wave_outcome_use_case.dart
  ```

  Blueprint-style examples (`vehicle/`, `reminder/`, garage) in older docs are
  illustrative only until Tower Up entities exist.
- **Business logic:** Use cases should mostly orchestrate (load via
  repositories/ports, call domain helpers, persist). If a use case grows
  more than a little business logic — multi-step rules, non-trivial
  calculations, or reusable domain decisions — put that logic in
  `domain/business/`, grouped like `use_cases/` by entity or function.
  Create `business/` (and the needed subdirs) only when extracting; do not
  invent empty folders up front.

  ```
  domain/business/
  ├── save/
  │   └── save_slot_eligibility.dart
  └── combat/
      └── tower_damage_calculator.dart
  ```
- **Repository interfaces** live in `domain/repositories/`; their `...Impl` live
  in `repo/`.
- **Service ports** (interfaces to infra) live in `domain/services/`; their
  adapters live in `platform/`.
- **DAOs**: one class per table/aggregate in `db/daos/`, named
  `<Entity>Dao` in `<entity>_dao.*` (e.g. `SaveDao` in `save_dao.dart`).
  DAOs own SQL CRUD and return domain entities.
- **`AppDatabase`**: connection handle, version, `onCreate`/`onUpgrade`, and
  `transaction()` for cross-DAO writes. No per-table queries — those belong in DAOs.
- **Flame game:** gameplay under `lib/game/`; menus host `GameWidget` from
  `screens/`. See `docs/architecture.md` and
  https://docs.flame-engine.org/latest/README.html.

## Wiring (DI)

`di/` constructs concrete implementations and provides them to the presentation
layer. Controllers receive use cases and repositories via DI — they never
construct DB or platform objects directly.

**Split registration into private helpers**, then call them from one public
startup method (e.g. `configureDependencies()` / `setupDi()`) invoked from
`main` before `runApp`. Typical helpers:

- `_registerSingletons` — `AppDatabase`, DAOs, repository impls, platform
  adapters, shared clients (order: DB → DAOs → repos/adapters)
- `_registerUseCases` — domain use cases
- `_registerScreens` — BLoC / screen factories

Inside each helper, group registrations into **comment-marked sections** when
there is more than one feature area (e.g. `// save use cases`,
`// menu screens`). Do not dump every registration into one flat list.

**Database exceptions:** Every DB call path (open, migrate, DAO CRUD) must
catch database exceptions — see
[07-database-exceptions.md](agent-guidelines/07-database-exceptions.md).
`main` must wrap startup DB init in `try`/`catch`; on failure apply the
project’s documented startup-failure behavior (do not invent one).

```dart
// lib/di/di.dart (conceptual)
Future<void> configureDependencies() async {
  _registerSingletons();
  _registerUseCases();
  _registerScreens();
}

void _registerSingletons() {
  // database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<SaveDao>(() => SaveDao(getIt()));

  // save repos
  getIt.registerLazySingleton<SaveRepository>(
    () => SaveRepositoryImpl(getIt()),
  );
}

void _registerUseCases() {
  // save use cases
  getIt.registerLazySingleton(() => CreateOrUpdateSaveUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteSaveUseCase(getIt()));
}

void _registerScreens() {
  // menu screens
  getIt.registerFactory(() => MainMenuBloc(getIt(), getIt()));
}
```

## Logger setup

Centralize the `logger` package in `lib/logger/logger.*`. Import it everywhere —
do not create ad-hoc `Logger` instances. See
[architecture.md — Logger setup](architecture.md#logger-setup)
for `PrettyPrinter` configuration (`methodCount: 1`, `errorMethodCount: 1`).
Use `logger.i` / `logger.w` / `logger.d` per AGENTS.md.
