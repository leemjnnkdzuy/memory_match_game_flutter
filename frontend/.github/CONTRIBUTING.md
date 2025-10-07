# Contributing to Memory Match Game

Cảm ơn bạn đã quan tâm đến việc contribute cho Memory Match Game! 🎮

## 🏗️ Architecture Overview

Project này sử dụng **Clean Architecture** với Flutter. Hãy đọc kỹ structure trước khi bắt đầu:

```
lib/
├── main.dart                # Entry point
├── app.dart                 # App configuration
├── core/                    # Shared utilities (constants, utils, error, theme)
├── data/                    # Data layer (models, datasources, repositories_impl)
├── domain/                  # Business logic (entities, repositories, usecases)
├── presentation/            # UI layer (screens, widgets, providers, routes)
└── services/                # External services (Firebase, notifications, etc.)
```

## 🚀 Getting Started

### Prerequisites

-   Flutter SDK (3.24.3+)
-   Dart SDK (3.5.3+)
-   Android Studio hoặc VS Code
-   Git

### Setup

1. Fork repository này
2. Clone fork của bạn:
    ```bash
    git clone https://github.com/YOUR_USERNAME/memory_match_game.git
    cd memory_match_game
    ```
3. Cài đặt dependencies:
    ```bash
    flutter pub get
    ```
4. Chạy app:
    ```bash
    flutter run
    ```

## 📋 Development Workflow

### 1. Tạo Branch Mới

```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### Branch Naming Convention

-   `feature/feature-name` - Tính năng mới
-   `fix/bug-description` - Bug fixes
-   `refactor/component-name` - Code refactoring
-   `docs/description` - Documentation updates

### 2. Development

-   Tuân thủ [Code Quality Guidelines](.github/CODE_QUALITY_GUIDELINES.md)
-   Viết tests cho code mới
-   Chạy `flutter analyze` và fix tất cả warnings
-   Chạy `dart format .` để format code

### 3. Testing

```bash
# Chạy tất cả tests
flutter test

# Chạy tests với coverage
flutter test --coverage

# Check coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 4. Commit Guidelines

Sử dụng [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

feat(game): add multiplayer mode
fix(ui): resolve card flip animation issue
docs(readme): update setup instructions
refactor(data): simplify repository pattern
test(game): add unit tests for game logic
```

### 5. Pull Request Process

1. Push branch lên fork của bạn
2. Tạo Pull Request từ fork về repository gốc
3. Điền đầy đủ PR template
4. Đợi code review và CI checks
5. Resolve feedback nếu có
6. Merge sau khi approved

## 🧪 Testing Guidelines

### Test Organization

```
test/
├── unit/                    # Unit tests
│   ├── core/
│   ├── data/
│   ├── domain/
│   └── services/
├── widget/                  # Widget tests
│   └── presentation/
└── integration/             # Integration tests
```

### Test Requirements

-   **Unit tests**: >= 80% coverage cho business logic
-   **Widget tests**: Critical UI components
-   **Integration tests**: Key user flows

### Writing Tests

```dart
// Unit test example
group('GameUseCase', () {
  test('should return game state when started', () {
    // Arrange
    final useCase = GameUseCase();

    // Act
    final result = useCase.startGame();

    // Assert
    expect(result.isSuccess, true);
  });
});

// Widget test example
testWidgets('GameCard should display Pokemon image', (tester) async {
  // Arrange
  const pokemon = Pokemon(name: 'Pikachu', imageUrl: 'url');

  // Act
  await tester.pumpWidget(GameCard(pokemon: pokemon));

  // Assert
  expect(find.byType(Image), findsOneWidget);
});
```

## 🎨 UI/UX Guidelines

### Design Principles

-   **Consistency**: Sử dụng design system
-   **Accessibility**: Support screen readers, high contrast
-   **Performance**: 60fps animations, fast loading
-   **Responsive**: Support multiple screen sizes

### Widget Organization

-   Tạo reusable widgets trong `presentation/widgets/`
-   Organize theo category (buttons/, cards/, forms/, etc.)
-   Sử dụng const constructors khi có thể

## 🔒 Security Guidelines

### Best Practices

-   Không commit API keys hoặc sensitive data
-   Validate user inputs
-   Use HTTPS cho network calls
-   Handle errors gracefully

### Sensitive Data

```dart
// ❌ Don't do this
const apiKey = 'your-secret-key';

// ✅ Do this
final apiKey = const String.fromEnvironment('API_KEY');
```

## 📱 Platform Considerations

### Cross-platform Support

-   Test trên cả Android và iOS
-   Handle platform-specific behaviors
-   Use responsive design
-   Consider platform design guidelines

### Performance

-   Optimize images (size, format, caching)
-   Use ListView.builder cho long lists
-   Avoid unnecessary rebuilds
-   Profile với Flutter DevTools

## 🤝 Code Review Process

### Reviewer Checklist

-   [ ] Code follows architecture guidelines
-   [ ] Tests are written và pass
-   [ ] No hardcoded strings
-   [ ] Proper error handling
-   [ ] Performance considerations
-   [ ] Security best practices
-   [ ] Documentation is updated

### Author Checklist

-   [ ] Feature is fully implemented
-   [ ] All tests pass locally
-   [ ] `flutter analyze` returns no issues
-   [ ] Code is properly formatted
-   [ ] PR description is complete
-   [ ] Breaking changes are documented

## 🆘 Getting Help

### Resources

-   [Flutter Documentation](https://flutter.dev/docs)
-   [Dart Language Tour](https://dart.dev/guides/language/language-tour)
-   [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Community

-   GitHub Issues - Bug reports và feature requests
-   GitHub Discussions - General questions và ideas
-   Code Reviews - Learning opportunities

### Common Issues

1. **Build errors**: Check Flutter và Dart versions
2. **Test failures**: Ensure proper test setup
3. **Lint errors**: Run `dart fix --apply`
4. **Import errors**: Check relative paths

## 🎯 Feature Requests

### Before Submitting

1. Search existing issues
2. Check project roadmap
3. Consider scope và feasibility
4. Prepare detailed specification

### Feature Template

-   Problem description
-   Proposed solution
-   User stories
-   Technical considerations
-   UI/UX mockups (nếu có)

## 🐛 Bug Reports

### Information Needed

-   Flutter version (`flutter --version`)
-   Device information
-   Steps to reproduce
-   Expected vs actual behavior
-   Screenshots/videos
-   Error logs

### Bug Priority

-   **Critical**: App crashes, data loss
-   **High**: Major features broken
-   **Medium**: Minor features broken
-   **Low**: Cosmetic issues

## 📊 Release Process

### Version Numbering

Sử dụng [Semantic Versioning](https://semver.org/):

-   MAJOR.MINOR.PATCH
-   Example: 1.2.3

### Release Checklist

-   [ ] All tests pass
-   [ ] Documentation updated
-   [ ] Changelog updated
-   [ ] Version bumped
-   [ ] Git tags created
-   [ ] App stores updated

---

## 🏆 Recognition

Contributors sẽ được ghi nhận trong:

-   README.md
-   Release notes
-   About screen trong app

Cảm ơn bạn đã contribute! 🙏
