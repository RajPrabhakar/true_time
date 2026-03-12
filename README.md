# TruTime

**Solar Time at Your Fingertips. No Timezones. No Politics. Just Physics.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-Stable-blue.svg)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20macOS-lightgrey.svg)](#)

---

## The Concept

Timezone clocks are legal conventions, not solar reality. Noon on your phone usually does **not** match true local solar noon at your exact longitude.

**TruTime** shows Local Mean Time (LMT):

$$\text{LMT} = \text{UTC} + (\text{Longitude} \times 4\text{ minutes})$$

Earth rotates 360 degrees in 24 hours, so each degree of longitude is 4 minutes of solar offset.

The app runs this calculation fully on-device using your current longitude and system UTC time.

No backend. No API calls. No timezone database lookups.

---

## Wiki

Project wiki pages are available in the `wiki/` directory:

- [Home](wiki/Home.md)
- [App Overview](wiki/App-Overview.md)
- [Architecture](wiki/Architecture.md)
- [Development Setup](wiki/Development-Setup.md)
- [Testing and Quality](wiki/Testing-and-Quality.md)
- [Roadmap](wiki/Roadmap.md)
- [Release Checklist](wiki/Release-Checklist.md)
- [Contributing](wiki/Contributing.md)

---

## Features

- Real-time Local Mean Time clock updated every second
- Live delta between solar time and device local time
- Theme gallery with free, premium, and skin categories
- Persisted preferences (theme and 12h/24h format)
- Home screen widget theme sync (Android/iOS via `home_widget`)
- Offline-first design with location-only permissions
- Golden tests, unit tests, and CI checks for stability

---

## Tech Stack

- Flutter + Dart
- `provider` for state management
- `geolocator` for location permissions and longitude
- `intl` for formatting
- `shared_preferences` for local settings persistence
- `home_widget` for widget integration
- `wakelock_plus` for active display mode
- `google_fonts` for theme typography support

---

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK (bundled with Flutter)
- iOS: Xcode + CocoaPods
- Android: Android Studio + SDK

### Install and Run

1. Clone your fork/repository:
   ```bash
   git clone <your-repo-url>
   cd true_time
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. List devices:
   ```bash
   flutter devices
   ```
4. Run:
   ```bash
   flutter run -d <device-id>
   ```

---

## Permissions

TruTime requests location access to calculate solar time from longitude.

- iOS: `NSLocationWhenInUseUsageDescription`
- Android: `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION`

No account, no analytics backend, and no network dependency for core functionality.

---

## Testing and Quality

Run all tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

Run formatting check:

```bash
dart format --output=none --set-exit-if-changed .
```

Update golden files (when visual output intentionally changes):

```bash
flutter test test/goldens --update-goldens
```

CI (`.github/workflows/flutter_ci.yml`) runs format checks, analysis, golden generation, and tests with coverage on pushes and pull requests.

---

## Build

Android APK:

```bash
flutter build apk --release
```

Android App Bundle:

```bash
flutter build appbundle --release
```

iOS release build:

```bash
flutter build ios --release
```

---

## Project Structure

```text
lib/
  main.dart
  models/
    app_theme.dart
    local_time_result.dart
    theme_types.dart
    themes/
  providers/
    theme_provider.dart
    true_time_provider.dart
  screens/
    home_screen.dart
    utils/delta_formatter.dart
    widgets/
  services/
    theme_service.dart
    time_calculator_service.dart
    widget_sync_service.dart
  themes/
    skins/

test/
  format_delta_test.dart
  theme_registry_test.dart
  time_calculator_service_test.dart
  goldens/

integration_test/
  theme_scroll_perf_test.dart

.github/workflows/
  flutter_ci.yml
```

---

## Roadmap

- Apparent solar time mode (Equation of Time)
- Sunrise/sunset indicators
- Additional premium skins and animation polish
- Expanded widget customization and lock-screen support

---

## Contributing

Issues and pull requests are welcome.

1. Fork the repository
2. Create a branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -m "Add your feature"`)
4. Push (`git push origin feature/your-feature`)
5. Open a pull request

---

## License

MIT License. See [LICENSE](LICENSE).
