# Testing

Architecture import tests remain mandatory. Also write:

| Kind | Package |
|------|---------|
| Unit | `package:test` (domain, data, BLoC logic) |
| Widget | `package:flutter_test` |
| Integration | `package:integration_test` (`sdk: flutter` dev_dependency) |

- Follow Arrange–Act–Assert (Given–When–Then).
- Prefer fakes/stubs over mocks; if mocks are needed, `mocktail` or `mockito`.
- Prefer expressive assertions (`package:checks`) when the project already
  uses them; otherwise default matchers are fine.
- Aim for meaningful coverage of domain, repositories, and critical UI.
- Prefer injectability (`file` / `process` / `platform` or constructor DI)
  so tests can substitute fakes.
