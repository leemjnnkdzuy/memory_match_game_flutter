## 📝 Mô tả thay đổi

<!-- Mô tả ngắn gọn về những gì đã thay đổi trong PR này -->

## 🎯 Loại thay đổi

-   [ ] 🐛 Bug fix (thay đổi không breaking và sửa lỗi)
-   [ ] ✨ Feature mới (thay đổi không breaking và thêm tính năng)
-   [ ] 💥 Breaking change (fix hoặc feature làm thay đổi API hiện tại)
-   [ ] 📚 Documentation (chỉ cập nhật documentation)
-   [ ] 🔧 Refactor (không thay đổi tính năng, chỉ cải thiện code)
-   [ ] ⚡ Performance (cải thiện hiệu suất)
-   [ ] 🧪 Tests (thêm hoặc cập nhật tests)
-   [ ] 🔨 Build/CI (thay đổi build process hoặc dependencies)

## 🏗️ Kiến trúc và Cấu trúc

### Clean Architecture Compliance

-   [ ] Code tuân thủ cấu trúc Clean Architecture
-   [ ] Domain layer không import Flutter/UI dependencies
-   [ ] Data layer implements domain repositories
-   [ ] Presentation layer chỉ chứa UI logic

### File Organization

-   [ ] Files được đặt đúng thư mục theo chuẩn:
    -   [ ] `core/` - Utils, constants, themes, errors
    -   [ ] `data/` - Models, datasources, repository implementations
    -   [ ] `domain/` - Entities, repository interfaces, usecases
    -   [ ] `presentation/` - Screens, widgets, providers, routes
    -   [ ] `services/` - External services (Firebase, notifications, etc.)

## 📱 Testing

-   [ ] Unit tests đã được viết cho business logic
-   [ ] Widget tests đã được viết cho UI components
-   [ ] Integration tests (nếu cần thiết)
-   [ ] Tất cả tests đều pass
-   [ ] Code coverage >= 80%

## 🔍 Code Quality

-   [ ] Code đã được format (`dart format`)
-   [ ] Dart analyzer không có warnings (`flutter analyze`)
-   [ ] Tuân thủ [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
-   [ ] Đã xóa debug prints và unused imports
-   [ ] Variable/function names có ý nghĩa và rõ ràng

## 📱 Device Testing

-   [ ] Tested trên Android
-   [ ] Tested trên iOS
-   [ ] Tested trên different screen sizes
-   [ ] Tested trên dark/light themes

## 🔗 Related Issues

<!-- Link đến issues liên quan -->

Closes #(issue number)

## 📷 Screenshots/GIFs

<!-- Thêm screenshots hoặc GIFs để show thay đổi UI -->

### Before

<!-- Screenshot trước khi thay đổi -->

### After

<!-- Screenshot sau khi thay đổi -->

## 🧠 Implementation Details

<!-- Giải thích cách implement, design patterns sử dụng, trade-offs -->

### Key Changes:

-
-
-

### Design Patterns Used:

-   [ ] Provider/Riverpod for state management
-   [ ] Repository pattern for data access
-   [ ] Use case pattern for business logic
-   [ ] Factory pattern (nếu có)
-   [ ] Singleton pattern (nếu có)

## 📋 Review Checklist

### For Reviewer:

-   [ ] Code follows Flutter/Dart best practices
-   [ ] Architecture is clean and maintainable
-   [ ] No hardcoded strings (use localization)
-   [ ] Error handling is implemented properly
-   [ ] Performance considerations are addressed
-   [ ] Security considerations (API keys, sensitive data)
-   [ ] Accessibility features are implemented

### Breaking Changes:

<!-- Nếu có breaking changes, liệt kê và hướng dẫn migration -->

## 📝 Additional Notes

<!-- Bất kỳ thông tin bổ sung nào mà reviewer cần biết -->

---

## ✅ Final Checklist

-   [ ] Tôi đã test code trên local
-   [ ] Tôi đã chạy `flutter analyze` và fix tất cả issues
-   [ ] Tôi đã chạy `dart format` để format code
-   [ ] Tôi đã update documentation (nếu cần)
-   [ ] Tôi đã thêm tests cho code mới
-   [ ] Project structure tuân thủ Clean Architecture guidelines
