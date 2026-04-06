# Device Sentinel

[![pub package](https://img.shields.io/pub/v/device_sentinel.svg)](https://pub.dev/packages/device_sentinel)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A Flutter plugin for monitoring **physical button presses** and **device security events** on Android, iOS, macOS, and Windows.

Detects Volume Up, Volume Down, and Power button events with per-button interception, plus ~25 types of security events including network changes, screen lock, battery levels, USB debugging, screen capture, and more.

Built with the [Very Good Ventures](https://verygood.ventures/) federated plugin architecture.

> **Formerly `vol_spotter`** - renamed to `device_sentinel` in v1.0.0.

---

## Features

### Button Detection
- Detect **Volume Up**, **Volume Down**, and **Power** button events
- **Per-button interception** -- independently consume each volume button so the system volume stays unchanged
- Broadcast stream with multiple listeners

### Security Event Monitoring
- **~25 event types** organized in 5 categories (Shutdown, Connectivity, Screen/Lock, Power/USB, Security Posture)
- **String wire protocol** with forward compatibility -- unknown events return `null`
- **Granular control** via `SentinelConfig` to enable/disable categories
- Type-safe API using Dart 3 sealed classes and exhaustive pattern matching

### Unified API
- Single `events` stream delivers both button and security events
- One `SentinelConfig` controls per-button interception and security categories
- Typed `DeviceSentinelException` hierarchy -- no raw string errors

## Getting Started

```sh
flutter pub add device_sentinel
```

## Usage

```dart
import 'package:device_sentinel/device_sentinel.dart';

final sentinel = const DeviceSentinel();

// Listen to ALL events in a single stream.
sentinel.events.listen((event) {
  switch (event) {
    case ButtonEvent(:final button, :final action):
      print('Button: $button $action');
    case DeviceSecurityEvent():
      print('Security: $event');
  }
});

// Start with per-button interception + security categories.
await sentinel.start(
  config: SentinelConfig(
    interceptVolumeUp: true,
    interceptVolumeDown: false,
    monitorScreenLock: true,
    monitorConnectivity: true,
  ),
);

// Stop when done.
await sentinel.stop();
```

## Architecture

```
device_sentinel/                        # App-facing package (public API)
device_sentinel_platform_interface/     # Abstract interface + domain models
device_sentinel_android/                # Android implementation (Kotlin)
device_sentinel_ios/                    # iOS implementation (Swift)
device_sentinel_macos/                  # macOS implementation (Swift)
device_sentinel_windows/                # Windows implementation (C++)
device_sentinel_linux/                  # Stub
device_sentinel_web/                    # Stub
```

See the [`device_sentinel`](device_sentinel/) package README for full documentation, platform support tables, and API reference.

## Running Tests

```bash
for pkg in device_sentinel_platform_interface device_sentinel_android device_sentinel_ios \
           device_sentinel device_sentinel_linux device_sentinel_macos device_sentinel_windows \
           device_sentinel_web; do
  (cd "$pkg" && flutter test)
done
```

## Credits

Created and maintained by [DEVotion](https://github.com/Crdzbird) ([@Crdzbird](https://github.com/Crdzbird)).

Built with the [Very Good CLI][very_good_cli_link] federated plugin template by [Very Good Ventures][very_good_ventures_link].

## License

MIT License -- see the [LICENSE](LICENSE) file for details.

[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
[very_good_ventures_link]: https://verygood.ventures/?utm_source=github&utm_medium=banner&utm_campaign=device_sentinel
