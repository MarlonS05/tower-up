# Documentation & reusable APIs

## dartdoc

- Document public APIs with `///` (classes, constructors, methods, top-levels).
- First sentence: concise summary ending with `.`, then a blank line.
- Explain *why* / non-obvious behavior; do not restate the obvious from names.
- No trailing comments. Docs come before annotations.
- Prefer documenting one of getter/setter when both exist.
- Library-level `///` when a library needs an overview.
- Use backticks for code; keep Markdown light.

## Reusable API design

When extracting a reusable library or shared module: design for the caller,
keep the surface small and hard to misuse, and document with short examples.
