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

## 0.1.0+1

- Initial release.
- Detect Volume Up, Volume Down, and Power button presses on Android and iOS.
- Configurable event interception (consume volume events or observe only).
- Type-safe API using Dart 3 sealed classes.
- Federated plugin architecture with stub implementations for unsupported platforms.
