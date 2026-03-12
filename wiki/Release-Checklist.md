# Release Checklist

Use this checklist before tagging a release.

## Quality

- Run formatter check: dart format --output=none --set-exit-if-changed .
- Run analyzer: flutter analyze
- Run tests: flutter test
- Regenerate goldens if needed and review diffs

## Product

- Validate core LMT calculation behavior on at least one iOS and one Android device
- Verify location permission flows for fresh install and denied state
- Verify widget sync behavior with selected theme
- Verify 12h/24h preference persistence after restart

## Release Artifacts

- Android: build apk/appbundle
- iOS: archive or build ios release target
- Update release notes with feature and fix summary

## Documentation

- Update README if user-visible behavior changed
- Update Roadmap statuses
- Add migration notes if settings behavior changed
