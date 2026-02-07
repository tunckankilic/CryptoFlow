# Contributing to CryptoWave

Thank you for considering contributing to CryptoWave!

## Development Setup

1. Fork and clone the repository
2. Run `flutter pub get`
3. Run `dart run build_runner build`
4. Create a feature branch

## Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Run `dart format .` before committing
- Ensure `flutter analyze` returns 0 issues
- Use Conventional Commits: `feat:`, `fix:`, `docs:`, etc.

## Testing

- Write unit tests for new business logic
- Write widget tests for new UI components
- Maintain >80% code coverage
- Run `flutter test` before pushing

## Pull Request Process

1. Update README.md if adding user-facing features
2. Add tests for new code
3. Ensure CI passes (analyze + test)
4. Request review from maintainer

## Architecture Guidelines

- Follow Clean Architecture (domain/data/presentation layers)
- Use BLoC for state management
- Keep widgets small and composable
- Inject dependencies via GetIt

## Commit Messages

Format: `type(scope): message`

Examples:
- `feat(journal): add emotion tracking to trades`
- `fix(portfolio): correct P&L calculation for shorts`
- `docs(readme): update architecture diagram`
- `test(analytics): add max drawdown calculation tests`
