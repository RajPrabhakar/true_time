# Development Setup

## Prerequisites

- Flutter SDK (stable)
- Xcode and CocoaPods for iOS/macOS
- Android SDK for Android development

## First-Time Setup

1. Clone the repository.
2. Run: flutter pub get
3. Verify toolchain: flutter doctor
4. List devices: flutter devices
5. Run app: flutter run -d <device-id>

## Common Commands

- Analyze: flutter analyze
- Test: flutter test
- Format check: dart format --output=none --set-exit-if-changed .
- Build APK: flutter build apk --release
- Build app bundle: flutter build appbundle --release
- Build iOS: flutter build ios --release

## Permissions

TruTime requires location permission to calculate solar time offset from longitude.

- iOS: NSLocationWhenInUseUsageDescription
- Android: ACCESS_FINE_LOCATION and ACCESS_COARSE_LOCATION

## Notes for Contributors

- Keep logic testable in services/providers.
- Prefer small, composable widgets in screens/widgets.
- Maintain stable visual baselines for goldens when UI changes intentionally.
