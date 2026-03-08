# True Time

**Solar Time at Your Fingertips. No Timezones. No Politics. Just Physics.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.5.3%2B-blue.svg)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)](#)

---

## The Concept

Timezones are a political fiction. The "official" noon in your timezone—whether that's Indian Standard Time (IST), Eastern Standard Time (EST), or any other—rarely aligns with actual solar noon, when the sun is at its highest point in the sky.

IST, for example, spans nearly 30° of longitude from northwest India to the northeast, yet the sun reaches its zenith hours apart across this span. Most of the Indian subcontinent runs an hour or more ahead of their local solar noon.

**True Time** strips away this convention and shows you *Local Mean Time (Solar Time)*—the time your longitude actually experiences based on the sun's position. It's a radical simplification: no timezone database, no political boundaries, no battery drain from network calls.

Just GPS, math, and the physics of Earth's rotation.

---

## How It Works: The Math

Local Mean Time is calculated using a straightforward formula:

$$\text{Local Mean Time} = \text{UTC} + (\text{Longitude} \times 4 \text{ minutes})$$

**Why 4 minutes?** The Earth rotates 360° in 24 hours, so each degree of longitude represents 4 minutes of solar time offset from UTC.

**The Process:**
1. Your device's GPS retrieves your current longitude (accurate to ~5 meters)
2. The app fetches UTC time from your system clock
3. The longitude offset is calculated instantly, client-side
4. Local Mean Time is displayed in real-time

**Zero Backend. Zero APIs. 100% Offline.** All computation happens on your device. No server calls, no cloud dependency, no privacy concerns.

---

## Features

- **Hyper-Minimalist OLED Black UI** — A stark, distraction-free interface designed for readability and minimal battery consumption on OLED screens
- **Tabular-Numeral Clock** — Monospace, anti-jitter font that updates smoothly without visual noise
- **Real-Time Timezone Delta** — Displays the offset between Local Mean Time and your device's current timezone, so you understand exactly how far off UTC±X you are
- **Battery-Efficient GPS Polling** — Smart location updates that respect power constraints and only fetch coordinates at reasonable intervals
- **Offline Operation** — Works entirely without internet; no permissions beyond location access
- **Lightweight Footprint** — Minimal dependencies, fast startup, minimal RAM overhead

---

## Tech Stack

- **Flutter** — Cross-platform native mobile development
- **Dart** — Type-safe, performant language
- **geolocator** — Hardware GPS access with permission handling
- **intl** — Time and date formatting utilities
- **wakelock_plus** — Screen-on management for continuous time display
- **platform_channels** (optional) — Direct access to native GPS APIs for precision tuning

---

## Getting Started

### Prerequisites

- **Flutter SDK** (version 3.5.3 or higher)
- **Dart SDK** (bundled with Flutter)
- **iOS**: Xcode 13+ (for iOS deployment)
- **Android**: Android Studio with Android SDK 21+

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/true_time.git
   cd true_time
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on iOS simulator:**
   ```bash
   flutter run -d ios
   ```

4. **Run on Android emulator:**
   ```bash
   flutter run -d android
   ```

5. **Run on real device:**
   ```bash
   flutter run
   ```

### Permissions

The app requests **location permission (When In Use)** to access your GPS coordinates:

- **iOS**: Automatically prompted via `NSLocationWhenInUseUsageDescription` in `Info.plist`
- **Android**: Runtime permission requested on first launch via `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION`

No other permissions are required.

---

## Building for Release

### iOS

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode and follow the standard App Store submission flow.

### Android

```bash
flutter build apk --release
```

Or for Google Play (AAB format):
```bash
flutter build appbundle --release
```

---

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data structures (Location, Time calculations)
├── services/              # GPS service, time calculation logic
├── screens/               # UI pages (Home screen with time display)
└── utils/                 # Formatting, constants
```

---

## Roadmap

### v0.2.0 (Planned)
- **Apparent Solar Time Toggle** — Display Apparent Solar Time using the Equation of Time (accounts for Earth's elliptical orbit and axial tilt), providing even more astronomical accuracy
- **Sunrise/Sunset Indicators** — Show local solar sunrise and sunset times
- **UI Theme Unlocks** — Additional color schemes and typography options

### v0.3.0 (Future)
- **Persistent Settings** — Save user preferences (refresh rate, theme, units)
- **Widget Support** — Quick-access home screen widgets
- **Wear OS Support** — True Time for smartwatches
- **Accuracy Metrics** — Display GPS accuracy indicator and last-update timestamp

### v1.0.0 (Stable Release)
- Full feature parity across platforms
- Comprehensive testing and performance optimization
- Production-ready privacy policy and terms

---

## Contributing

Contributions are welcome! Please submit issues and pull requests to help improve True Time.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add YourFeature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- The solar time calculation is inspired by the NOAA Solar Calculation work and basic geophysics
- Built with [Flutter](https://flutter.dev) and [Dart](https://dart.dev)
- Icons and design philosophy influenced by minimalist science instruments

---

**Questions?** Open an issue or reach out. Enjoy discovering your true solar time.
