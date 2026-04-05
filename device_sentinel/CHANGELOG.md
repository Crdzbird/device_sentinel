# Changelog

## 1.0.0

- **BREAKING**: Renamed from `vol_spotter` to `device_sentinel`.
- Add `DeviceSecurityEvent` system with ~25 sealed-class event types.
- New `SecurityEventChannelMixin` for string-based EventChannel.
- New `SecurityConfig` for granular category-based monitoring control.
- Android: BroadcastReceiver, ConnectivityManager.NetworkCallback, ContentObserver, battery monitoring, screen capture (API 34+).
- iOS: NWPathMonitor, Darwin notification center, UIDevice battery, UIScreen capture detection.
- Unclean shutdown detection on both Android and iOS.
- Expand test coverage to 159 tests across all packages.

## 0.2.1

- Fix cross-package dependency constraints for pub.dev resolution.
- Update README with macOS and Windows platform details.

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
