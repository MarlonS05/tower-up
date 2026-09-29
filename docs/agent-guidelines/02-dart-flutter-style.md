# Dart & Flutter style

Does not override folder layout, screen suffixes (`*_view`, `*_bloc`, …),
use-case naming, or layer import rules in `project-structure.md` /
`architecture.md`.

## Naming

- Classes / enums / typedefs: `PascalCase`
- Members, variables, functions, parameters: `camelCase`
- Files and directories: `snake_case`
- Keep existing project conventions (e.g. `<screen>_view.dart`,
  `<Verb><Noun>UseCase`, `<Entity>Dao`).

## Language

- Follow [Effective Dart](https://dart.dev/effective-dart).
- Prefer sound null safety; avoid `!` unless the value is guaranteed non-null.
- Use `async`/`await` for single async results; `Stream`s for event sequences.
- Prefer exhaustive `switch`; use pattern matching and records when they
  simplify code.
- Handle errors with `try`/`catch` and domain-appropriate exceptions; do not
  fail silently. **Database exceptions must always be caught** — see
  [07-database-exceptions.md](07-database-exceptions.md).
- Prefer arrow syntax for simple one-line functions.

## Performance

- Prefer `const` constructors for widgets and in `build()` when possible.
- Use `ListView.builder` / `SliverList` (or `GridView.builder`) for long lists.
- Run expensive work (e.g. large JSON parse) off the UI isolate via `compute()`.
- Do not perform network I/O or heavy computation directly inside `build()`.

## Widgets & immutability

- Prefer immutable widgets; keep `StatelessWidget` / immutable configuration.
- Prefer `StatelessWidget` first; only use `StatefulWidget` when the widget
  must own ephemeral local state that cannot live in the screen BLoC.
- Prefer small `Widget` classes over private methods that return a `Widget`.
- **Placement:**
  - Screen-specific widgets: private classes in the same `*_view.*` file.
  - Shared / reusable widgets: `screens/components/` (subdirs OK).
  - Do not add separate widget *files* inside a screen folder (only the
    screen’s view/BLoC/event/state files belong there).
- Break large `build()` methods into those Widget classes.
