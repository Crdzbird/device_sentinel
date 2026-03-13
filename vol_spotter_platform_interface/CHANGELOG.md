# Changelog

## 0.2.0

- Extract `ButtonEventChannelMixin` to eliminate Dart-layer duplication across platforms.
- Android: add ProGuard consumer rules, `@Volatile` event sink, try-catch in key dispatch, double-registration guard.
- iOS: weak-capture slider in `resetVolume`, add `PrivacyInfo.xcprivacy` manifest.
- Lower SDK constraint to Dart `^3.0.0` / Flutter `>=3.10.0` for wider compatibility.
- Expand test coverage to 92 tests (up from 62).
- Add error handling to example app.

## 0.1.0+2

- Add `CHANGELOG.md`, `LICENSE`, `.pubignore`, and `repository` field to all packages.

## 0.1.0+1

- Initial release.
- Detect physical button presses: Volume Up, Volume Down, Power.
- Configurable event interception (consume or observe).
- Android support via `Window.Callback` and `BroadcastReceiver`.
- iOS support via `AVAudioSession` KVO and `MPVolumeView`.

