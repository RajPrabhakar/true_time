# App Overview

## Product Goal

Timezone clocks are legal conventions. TruTime displays time based on solar longitude math so users can see their local mean time.

## Core User Experience

- See live local mean time updates every second.
- Compare solar time against device local time.
- Switch visual themes and styles.
- Keep preferences persisted locally.
- Sync selected theme to supported home screen widgets.

## Core Formula

LMT = UTC + (longitude x 4 minutes)

- 360 degrees rotation in 24 hours
- 1 degree longitude = 4 minutes

## Platform Notes

- Flutter app targets iOS, Android, macOS, Linux, Windows, and web.
- Primary user flow relies on location permissions for longitude.

## Dependencies (High Level)

- provider: state management
- geolocator: location permissions and longitude
- intl: formatting
- shared_preferences: persisted settings
- home_widget: widget sync
- wakelock_plus: keep display active when needed
- google_fonts: typography support
