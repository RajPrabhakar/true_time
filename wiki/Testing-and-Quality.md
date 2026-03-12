# Testing and Quality

## Test Types

- Unit tests for service and formatting logic
- Theme registry tests for theme metadata integrity
- Golden tests for visual regressions
- Integration performance test for theme scroll behavior

## Run Test Suite

- flutter test

## Golden Workflow

When intentional visual changes occur:

1. Run: flutter test test/goldens --update-goldens
2. Review image diffs in pull request
3. Confirm expected design changes before merge

## Static Quality Gates

- Formatting: dart format --output=none --set-exit-if-changed .
- Analyzer: flutter analyze

## CI Expectations

CI should block merges when:

- formatting check fails
- static analysis fails
- tests fail
- golden verification fails
