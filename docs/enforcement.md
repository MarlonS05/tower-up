# Enforcement — making import boundaries real

Prose in `docs/architecture.md` rots unless something fails the build when it's
violated. Tower Up will enforce the **strict import table** with two artifacts
(planned — **not implemented yet**):

1. A **rules class** (`towerup_lint_rules/lib/layer_import_rules.dart`) that,
   given a file path, returns the list of import prefixes that file may not
   contain.
2. A **test** (`test/architecture/layer_import_test.dart`) that walks every
   source file under `lib/`, extracts its imports, and asserts none match a
   denied prefix.

Until those exist, **`docs/architecture.md` is the sole source of truth**. When
the artifacts are added, they plus the table are the **three sources that must
stay in sync**. Change a boundary → change all three in the same commit.

## 1. The rules class (path-keyed deny-lists)

Shape (language-agnostic pseudocode):

```
denyListForDomain      = [ framework, flame, screens, game, repo, db, platform, router, di, theme, stateMgmt, navPkg ]
denyListForDataAccess  = [ framework, flame, screens, game, router, di, stateMgmt, navPkg ]
denyListForPersistence = [ framework, flame, screens, game, repo, router, di, stateMgmt, navPkg ]
denyListForInfra       = [ screens, game, repo, db, router, di, stateMgmt, navPkg ]
denyListForGame        = [ repo, db, di, router, stateMgmt, navPkg ]
denyListForView        = [ repo, db, router, di, navPkg ]
denyListForController  = [ repo, db, navPkg, ...infrastructurePlugins ]
denyListForComponent   = [ repo, db, router, di, stateMgmt, navPkg ]

function denialsForFile(path):
    if path under domainDir:            return denyListForDomain
    if path under dataAccessDir:        return denyListForDataAccess
    if path under persistenceDir:       return denyListForPersistence
    if path under infraDir:             return denyListForInfra
    if path under gameDir:              return denyListForGame
    if path under sharedComponentsDir:  return denyListForComponent
    if path is a presentation file:
        if path ends with view suffix:       return denyListForView
        if path ends with controller suffix: return denyListForController
    return []   # no restrictions

function importMatchesDenial(importUri, denialPrefix):
    return importUri startsWith denialPrefix   # plus intra-package suffix handling
```

Keep the deny-lists as plain constants keyed by a `denialsForFile(path)`
dispatcher so the mapping between file location and its rules is obvious and
greppable. Mirror the prefixes in `docs/architecture.md` (Strict import table).

## 2. The test (walk sources, assert no denied imports)

Pseudocode:

```
for each source file under sourceRoot:
    denials = denialsForFile(file.path)
    if denials is empty: continue
    for each line in file:
        if line is an import/export directive:
            uri = extractUri(line)
            for each denial in denials:
                if importMatchesDenial(uri, denial):
                    record violation "file: line"
assert violations is empty   # message lists every violation
```

Run it in CI and locally. Because the rules class is shared between the test and
(optionally) any editor-integrated linter, there's exactly one definition of the
boundaries.

## 3. The sync rule

The `docs/architecture.md` strict import table, the rules-class deny-lists, and
the test must agree. If they disagree, **the table is the spec** and the other
two are bugs. Make boundary changes as one commit touching all three (or the
table + this doc until enforcement code exists).

## Adapting to other ecosystems

The pattern (path predicate → deny-list → build-failing check) ports directly:

| Ecosystem | Mechanism |
|-----------|-----------|
| Dart / Flutter | Custom rules class + a `flutter test` that walks `lib/` (this project). |
| TypeScript / JS | `eslint-plugin-boundaries` or `eslint-plugin-import` `no-restricted-paths`; zones map to layers. |
| Python | `import-linter` contracts (`forbidden` / `layers` contract types). |
| Java / Kotlin | ArchUnit `layeredArchitecture()` / `noClasses().should().dependOnClassesThat()`. |
| Go | `depguard` / `go-arch-lint`. |

Whatever the tool, keep the source of truth human-readable in
`docs/architecture.md` and mechanically checked in CI once enforcement exists.
