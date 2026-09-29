# Interaction & tooling

## Interaction

- Assume the user knows programming but may be new to Dart.
- When generating code, briefly explain Dart-specific features you use
  (null safety, `Future`/`async`/`await`, `Stream`s) where they are non-obvious.
- If a request is ambiguous, ask which functionality and target platform
  (mobile, web, desktop) are intended.
- When suggesting a new dependency from pub.dev, state why it fits this project.

## Dart / Flutter tools

Prefer these MCP / CLI tools when available (do **not** use `dart_fix`):

| Task | Tool / command |
|------|----------------|
| Format | `dart_format` tool, or `dart format` |
| Analyze / lint | `analyze_files` tool, or `flutter analyze` |
| Packages | `pub` tool (see Package management) |
| Discover packages | `pub_dev_search` tool, else pub.dev |
| Tests | `run_tests` tool, else `flutter test` |

Also run the project Verify commands from `AGENTS.md`.

## Package management

Use the `pub` tool when available; otherwise the Flutter CLI:

- Regular dep: `flutter pub add <package_name>`
- Dev dep: `flutter pub add dev:<package_name>`
- Override: `flutter pub add override:<package_name>:<version>`
- Remove: `dart pub remove <package_name>`
