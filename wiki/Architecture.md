# Architecture

## Directory Layout

- lib/main.dart: app bootstrap and provider wiring
- lib/models: app domain types and theme models
- lib/providers: app and theme state
- lib/screens: primary UI surfaces
- lib/services: logic for time calculation, persistence, and widget sync
- lib/themes: curated theme and skin definitions

## High-Level Flow

1. App starts and initializes providers.
2. Location permission and longitude are resolved.
3. UTC and longitude feed the local mean time calculation service.
4. Provider emits updates to UI each second.
5. Theme and format preferences are read/written via local persistence.
6. Widget sync service mirrors relevant theme settings to platform widgets.

## Key Components

- Time calculator service: converts UTC plus longitude into LMT and delta values.
- Theme provider: manages theme selection, filters, and premium state presentation.
- True time provider: owns live clock updates and derived display values.
- Widget sync service: pushes selected appearance values to home widgets.

## Performance Notes

- UI updates every second, so avoid unnecessary widget rebuilds.
- Heavy carousel/theme cards should isolate paint work when possible.
- Keep expensive visual effects scoped behind repaint boundaries.
