<!--
  TEMPLATE — copy to docs/architecture.md and fill in the {{PLACEHOLDERS}}.
  This document is the single source of truth for the dependency graph. The
  lint-rules class and the architecture test (see enforcement.md) mirror the
  "Strict import table" below. Keep all three in sync.
-->

# Architecture — {{PROJECT_NAME}}

{{ONE_PARAGRAPH: what the app is and the guiding principle — e.g. "a layered
architecture where the domain is pure and every other layer depends inward."}}

## Layers

Order layers from innermost (most pure, fewest dependencies) to outermost.

| Layer | Directory | Responsibility | May depend on |
|-------|-----------|----------------|---------------|
| Domain | `{{DOMAIN_DIR}}` | {{Entities, models, repository interfaces, service ports, use cases (grouped under `use_cases/`), non-trivial logic under `business/` when extracted from use cases, formatters, validators. Pure — no framework.}} | (nothing internal) |
| Data-access | `{{REPO_DIR}}` | {{Repository implementations that fulfil domain interfaces.}} | Domain, DB |
| Persistence | `{{DB_DIR}}` | {{Connection (`AppDatabase`), schema, migrations, DAOs — one DAO per table/aggregate.}} | Domain |
| Infra adapters | `{{PLATFORM_DIR}}` | {{OS/plugin adapters implementing domain service ports.}} | Domain |
| Presentation | `{{SCREENS_DIR}}` | {{Views + state/controllers (BLoCs). Views render; controllers hold logic.}} | Domain, {{router}}, {{di}}, {{theme}} |
| Cross-cutting | `{{ROUTER_DIR}}`, `{{DI_DIR}}`, `{{THEME_DIR}}` | {{Routing, dependency injection, design tokens.}} | Domain + presentation as needed |

## Core rules

1. **{{STATE/CONTROLLER}}** performs writes/deletes through a **{{WRITE_UNIT}}**
   and simple reads through a **{{READ_UNIT}}**.
2. **All navigation happens in BLoCs / {{STATE/CONTROLLER}}** — never in
   views or shared widgets. Every screen must be registered with a route in
   `{{ROUTER_DIR}}`. Views only dispatch events (e.g. `backTapped`); the BLoC
   navigates by calling `{{ROUTER}}` with that registered route. Views must
   not import the router or navigation package.
3. **No {{INFRASTRUCTURE}} in {{STATE/CONTROLLER}} or views** — infrastructure is
   reached only through domain ports implemented in `{{PLATFORM_DIR}}` /
   `{{REPO_DIR}}`.
4. **The domain is pure** — it must not import any outer layer or framework.
5. **API HTTP calls** are made from `{{REPO_DIR}}` or `{{PLATFORM_DIR}}` (not
   from controllers/views). Completion logging is centralized in the shared HTTP
   client — see AGENTS.md for format (`Success …` / `Failed …`; `logger.i` /
   `logger.w`). Temporary diagnostic logs: `logger.d` only — remove before
   finishing.
6. **Database exceptions are always caught** — at `{{DB_DIR}}` (open,
   migrations, DAOs) and at any other call site that talks to the DB.
   Never leave them uncaught. On app startup, wrap DB init in `try`/`catch`
   and apply `{{DATABASE_STARTUP_FAILURE_BEHAVIOR}}` (project-specific;
   document here when adapting). See
   `docs/agent-guidelines/07-database-exceptions.md`.

## Logger setup

Centralize the `logger` package in `lib/logger/logger.*`. Configure
`PrettyPrinter` with a short stack trace from the log call site:

```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 1,
    lineLength: 120,
  ),
);
```

## Strict import table

This is the authoritative deny-list. For each file group, list the import
prefixes it must **not** contain. The lint-rules class and architecture test
encode exactly this table.

- **`{{DOMAIN_DIR}}/**`** must not import: {{framework}}, `{{SCREENS_DIR}}`,
  `{{REPO_DIR}}`, `{{DB_DIR}}`, `{{PLATFORM_DIR}}`, `{{ROUTER_DIR}}`,
  `{{DI_DIR}}`, `{{THEME_DIR}}`, {{state-management framework}}.
- **`{{REPO_DIR}}/**`** must not import: {{framework}}, `{{SCREENS_DIR}}`,
  `{{ROUTER_DIR}}`, `{{DI_DIR}}`, {{state-management framework}}.
- **`{{DB_DIR}}/**`** must not import: {{framework}}, `{{SCREENS_DIR}}`,
  `{{REPO_DIR}}`, `{{ROUTER_DIR}}`, `{{DI_DIR}}`, {{state-management framework}}.
- **`{{PLATFORM_DIR}}/**`** must not import: `{{SCREENS_DIR}}`, `{{REPO_DIR}}`,
  `{{DB_DIR}}`, `{{ROUTER_DIR}}`, `{{DI_DIR}}`, {{state-management framework}}.
- **Views (`*_view.*`)** must not import: `{{REPO_DIR}}`, `{{DB_DIR}}`,
  `{{ROUTER_DIR}}`, `{{DI_DIR}}`, {{navigation package}}.
- **Controllers (`*_bloc.*` / `*_event.*` / `*_state.*`)** must not import:
  `{{REPO_DIR}}`, `{{DB_DIR}}`, {{navigation package}}, {{infrastructure plugins}}.
- **Shared components** must not import: `{{REPO_DIR}}`, `{{DB_DIR}}`,
  `{{ROUTER_DIR}}`, `{{DI_DIR}}`, {{state-management framework}}, {{navigation package}}.

## Data flow

```mermaid
flowchart TD
    View["View *_view.*"]
    Controller["Controller / BLoC *_bloc.*"]
    UseCase["Use case domain/use_cases/<group>/"]
    Repo["Repository iface domain/repositories/"]
    RepoImpl["Repository impl {{REPO_DIR}}/"]
    HttpClient["HTTP client {{REPO_DIR}}/"]
    EntityDao["EntityDao {{DB_DIR}}/daos/"]
    AppDb["AppDatabase {{DB_DIR}}/"]
    Migrations["Migrations {{DB_DIR}}/migrations/"]
    Port["Domain service port"]
    Platform["Infra adapter {{PLATFORM_DIR}}/"]
    Router["Router {{ROUTER_DIR}}/"]
    DI["DI {{DI_DIR}}/"]

    View -->|events| Controller
    Controller -->|writes/deletes| UseCase
    Controller -->|simple reads| Repo
    Controller -->|navigate| Router
    UseCase --> Repo
    UseCase --> Port
    Repo --> RepoImpl
    RepoImpl --> EntityDao
    RepoImpl --> HttpClient
    EntityDao --> AppDb
    AppDb --> Migrations
    Port --> Platform
    DI --> Controller
    DI --> RepoImpl
    DI --> EntityDao
    DI --> AppDb
    DI --> Platform
```

Domain interfaces (`Repo`, `Port`, `UseCase`) live in the domain layer;
`RepoImpl` and `Platform` implement them from outer layers and are wired in
`{{DI_DIR}}`. Repository impls call **DAOs** (not raw `Database`); DAOs return
domain entities directly.

## Remote DTOs

JSON DTOs (`json_serializable`) belong in the repo/HTTP path. Map to domain
entities before crossing into controllers. DAOs continue to own SQL and return
domain entities — see `docs/agent-guidelines/03-serialization.md`.

### Persistence layout (`{{DB_DIR}}/`)

```
{{DB_DIR}}/
├── app_database.*          # connection, version, transaction()
├── schema/tables.*         # CREATE TABLE DDL
├── migrations/             # incremental upgrade steps
└── daos/<entity>_dao.*     # one DAO per table — SQL CRUD
```

- **`AppDatabase`** — open/close, `onCreate`/`onUpgrade`, `transaction()` for
  cross-DAO writes. No per-table queries.
- **`<Entity>Dao`** — table-specific SELECT/INSERT/UPDATE/DELETE; maps query
  results to domain entities.
- **Repository impls** — the only callers of DAOs; may combine local DAO data
  with remote HTTP responses.

### Read path (example)

1. BLoC calls `ReminderRepository.getById(id)` (domain interface).
2. `ReminderRepositoryImpl` calls `ReminderDao.findById(id)` → domain `Reminder`.
3. Impl may merge remote data via HTTP before returning.
4. BLoC receives domain type only.

### Write path (example)

1. BLoC dispatches to `CreateOrUpdateReminderUseCase`.
2. Use case calls `ReminderRepository.save(reminder)`.
3. `ReminderRepositoryImpl` calls `ReminderDao.upsert(reminder)`.
4. Cross-table write: `AppDatabase.transaction((db) async { ... })` with DAOs
   receiving the transactional `db` handle.

### Example snippets

`app_database.*` — connection shell only (callers must catch; open can throw):

```dart
class AppDatabase {
  static const _version = 3;
  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async { /* sqflite openDatabase / onCreate / onUpgrade */ }

  Future<T> transaction<T>(Future<T> Function(Database db) action) async {
    final db = await database;
    return db.transaction((txn) => action(txn));
  }
}
```

`main.*` — wrap startup DB init; on failure apply project behavior:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await configureDependencies(); // opens / registers AppDatabase
  } on DatabaseException catch (e, st) {
    logger.w('Failed opening database on startup', error: e, stackTrace: st);
    // {{DATABASE_STARTUP_FAILURE_BEHAVIOR}} — e.g. runApp(DatabaseFatalApp()),
    // exit(1), show retry, etc. Project decides; do not invent here.
    return;
  }
  runApp(const MyApp());
}
```

`daos/vehicle_dao.*` — per-table CRUD:

```dart
class VehicleDao {
  VehicleDao(this._appDb);
  final AppDatabase _appDb;

  Future<List<Vehicle>> findAll({Database? db}) async { ... }
  Future<void> upsert(Vehicle vehicle, {Database? db}) async { ... }
}
```

`repo/vehicle_repository_impl.*` — orchestrates DAO + HTTP:

```dart
class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._vehicleDao, this._http);
  final VehicleDao _vehicleDao;
  final HttpClient _http;

  @override
  Future<List<Vehicle>> getAll() async {
    final local = await _vehicleDao.findAll();
    // optionally merge with remote via _http
    return local;
  }
}
```

`di/di.*` — split registration into private helpers (`_registerSingletons`,
`_registerUseCases`, `_registerScreens`, …), group entries with section
comments (e.g. `// garage use cases`), and call those helpers from one public
startup method run from `main` before `runApp`. Inside `_registerSingletons`,
order is AppDatabase → DAOs → repository impls / platform adapters:

```dart
Future<void> configureDependencies() async {
  _registerSingletons();
  _registerUseCases();
  _registerScreens();
}

void _registerSingletons() {
  // database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<VehicleDao>(() => VehicleDao(getIt()));

  // garage repos
  getIt.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(getIt(), getIt()),
  );
}

void _registerUseCases() {
  // garage use cases
  getIt.registerLazySingleton(() => CreateOrUpdateVehicleUseCase(getIt()));
}

void _registerScreens() {
  // garage screens
  getIt.registerFactory(() => GarageBloc(getIt()));
}
```

## Changing a boundary

A boundary change is a three-file change, all in the same commit:

1. Update the **Strict import table** above.
2. Update the deny-lists in `{{LINT_RULES_PACKAGE}}` (see
   [enforcement.md](../blueprint/enforcement.md)).
3. Update / re-run `{{ARCHITECTURE_TEST_PATH}}`.

If they disagree, the table wins and the other two are bugs.
