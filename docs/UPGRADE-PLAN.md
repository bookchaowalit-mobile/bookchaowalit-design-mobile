# Upgrade Plan — Design Mobile

## Current state

Score: 7.5/10 — palette/contrast tool with threshold-safe labels, broad edge-case tests, a11y guideline tests and fail-closed signing; no saved palettes, icon or E2E flow yet.

## Backlog

### P0
- None open. (Release signing now fails closed without `android/key.properties`.)

### P1
- Save favourite palettes locally and export them as CSS variables / Flutter code.
- Replace the template launcher icon with a real app icon (the application ID `com.bookchaowalit.*` is already set).
- Add a Maestro smoke flow for the main journey.
- Add a CI job that builds a signed release bundle from repository secrets (keystore decoded at runtime, never committed).

### P2
- Tablet layout (NavigationRail).
- Localisation (Thai/English) for UI strings.

## Done in this pass (pass 3)

- Bug fix: contrast ratios were shown with `toStringAsFixed(2)`, which rounds up, so e.g. `#003AFB` on black (2.998:1) displayed "3.00:1" next to a "Fail" rating (and 6.996:1 showed "7.00:1" with "AA"). New `formatRatio` truncates so the label never claims a threshold the rating denies.
- Edge-case unit tests: near-threshold labels, inclusive rating boundaries, contrast symmetry/range over sampled colours, `bestTextOn` always reaching 4.5:1 over ~65k sampled colours, near-miss hex input (full-width, 8-digit, `0x`), white/black scales, `mix` endpoints.
- Accessibility: decorative "Aa" preview excluded from semantics; swatch rows grow with text scale (min height 48). Widget tests: near-threshold label, 3-digit input full scale, a11y guidelines (tap target, labels, contrast), 200% text scale.
- The 200% text-scale widget test now runs at a 360 px phone width (it previously used the 800 px default test surface); no overflow found.

## Done in pass 2

- Release builds no longer sign with the debug key: `android/app/build.gradle.kts` reads the ignored `android/key.properties` and a Gradle guard fails any release assemble/bundle without it (pattern from `bookchaowalit-goal-tracker-mobile`). Root `.gitignore` also ignores `key.properties`, `*.jks`, `*.keystore`; README documents the setup. Not build-verified here (no Android SDK/Gradle in this environment).


## Done in pass 1

- Replaced the Expo/npm CI (which could never fail) with fail-closed Flutter CI: `dart format` check, `flutter analyze`, `flutter test`, debug APK on `main`.
- Implemented the core feature (turn a hex colour into a tint/shade palette and check wcag contrast) with pure-Dart logic in `lib/logic/`.
- Replaced placeholder Explore/Profile tabs with an About screen describing features and privacy.
- Added unit tests for the logic and widget tests for the main journey.
- Removed unused `go_router` / `flutter_riverpod` dependencies; README now matches the code.
