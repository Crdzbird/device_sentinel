# device_sentinel

[![pub package](https://img.shields.io/pub/v/device_sentinel.svg)](https://pub.dev/packages/device_sentinel)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A Flutter plugin for monitoring **physical button presses** and **device security events** on Android, iOS, macOS, and Windows.

## Features

### Button Detection
- Detect **Volume Up**, **Volume Down**, and **Power** button events
- **Per-button interception** -- independently consume each volume button so the system volume stays unchanged
- Works on Android, iOS, macOS, and Windows

### Security Event Monitoring
- **~25 event types** across 5 categories
- Network connectivity, VPN, airplane mode
- Screen lock/unlock, screen on/off
- Battery level (low/critical), charger state
- USB debugging, developer mode
- Screen capture/recording detection
- Shutdown, reboot, unclean shutdown detection

## Getting Started

```sh
flutter pub add device_sentinel
```

## Usage

### Observe Buttons (no interception)

Detect button presses without blocking the default OS behaviour. The system
volume still changes, the screen still locks -- you just get notified.

```dart
import 'package:device_sentinel/device_sentinel.dart';

const sentinel = DeviceSentinel();

// 1. Listen for button events.
sentinel.events.whereType<ButtonEvent>().listen((event) {
  print('${event.button} ${event.action}'); // VolumeUpButton() ButtonPressed()
});

// 2. Start with defaults -- all buttons observed, none intercepted.
await sentinel.start();
```

### Intercept Volume Buttons

Consume a button press so the OS does **not** perform its default action.
For example, prevent volume from changing when the user presses Volume Up:

```dart
await sentinel.start(
  config: const SentinelConfig(
    interceptVolumeUp: true,   // consume -- system volume won't change
    interceptVolumeDown: false, // observe -- system volume still changes
  ),
);
```

You still receive a `ButtonEvent` for every press. The only difference is
whether the OS also processes it.

### Monitor Security Events

Listen for device-level security events such as network changes,
screen lock, battery state, and more:

```dart
sentinel.events.whereType<DeviceSecurityEvent>().listen((event) {
  switch (event) {
    case NetworkConnected():
      print('Back online');
    case NetworkDisconnected():
      print('Network lost');
    case DeviceLocked():
      print('Device locked');
    case BatteryLow(:final level):
      print('Battery low: $level%');
    case ScreenCaptureStarted():
      print('Screen recording detected!');
    case _:
      print('Event: $event');
  }
});

// Only monitor connectivity and screen/lock -- skip shutdown, battery, etc.
await sentinel.start(
  config: const SentinelConfig(
    monitorConnectivity: true,
    monitorScreenLock: true,
    monitorShutdown: false,
    monitorPowerUsb: false,
    monitorSecurityPosture: false,
  ),
);
```

### Listen to Everything

A single stream delivers **both** button and security events:

```dart
sentinel.events.listen((event) {
  switch (event) {
    case ButtonEvent(:final button, :final action):
      print('Button: $button $action');
    case DeviceSecurityEvent():
      print('Security: $event');
  }
});
```

### Stop Monitoring

```dart
await sentinel.stop();
```

### Error Handling

```dart
try {
  await sentinel.start();
} on PlatformUnsupportedException catch (e) {
  print('Not available on ${e.platform}');
} on DeviceSentinelException catch (e) {
  print('Sentinel error: $e');
}
```

## Platform Support

### Button Events

| Feature | Android | iOS | macOS | Windows |
|---|:---:|:---:|:---:|:---:|
| Volume Up/Down | ✅ | ✅ | ✅ | ✅ |
| Power button | ✅ | ✅ | ✅ | ✅ |
| Per-button interception | ✅ | ✅ | ✅ | ✅ |
| `pressed` + `released` | ✅ | `pressed` only | ✅ | ✅ |

### Security Events

| Event | Android | iOS |
|---|:---:|:---:|
| Shutdown / Reboot | ✅ | -- |
| Unclean shutdown | ✅ | ✅ |
| Airplane mode | ✅ | -- |
| Network connected/disconnected | ✅ | ✅ |
| WiFi/Mobile capabilities | ✅ | ✅ |
| VPN established/disconnected | ✅ | ✅ |
| Screen on/off | ✅ | ✅ |
| Device locked/unlocked | ✅ | ✅ |
| Power connected/disconnected | ✅ | ✅ |
| Battery low/critical | ✅ | ✅ |
| USB debugging | ✅ | -- |
| Screen capture | ✅ (API 34+) | ✅ |
| Developer mode | ✅ | -- |

## Models

| Class | Variants |
|---|---|
| `PhysicalButton` | `VolumeUpButton`, `VolumeDownButton`, `PowerButton` |
| `ButtonAction` | `ButtonPressed`, `ButtonReleased` |
| `ButtonEvent` | Combines `PhysicalButton` + `ButtonAction` |
| `DeviceSecurityEvent` | ~25 sealed subtypes (see table above) |
| `SentinelConfig` | Per-button interception + 5 security category flags |
| `DeviceSentinelException` | `PlatformUnsupportedException`, `InvalidEventDataException`, `UnknownButtonException`, `UnknownButtonActionException` |

## Architecture

| Package | Purpose |
|---|---|
| [`device_sentinel`](https://pub.dev/packages/device_sentinel) | App-facing API |
| [`device_sentinel_platform_interface`](https://pub.dev/packages/device_sentinel_platform_interface) | Shared interface and models |
| [`device_sentinel_android`](https://pub.dev/packages/device_sentinel_android) | Android (Kotlin) |
| [`device_sentinel_ios`](https://pub.dev/packages/device_sentinel_ios) | iOS (Swift) |
| [`device_sentinel_macos`](https://pub.dev/packages/device_sentinel_macos) | macOS (Swift) |
| [`device_sentinel_windows`](https://pub.dev/packages/device_sentinel_windows) | Windows (C++) |
| [`device_sentinel_linux`](https://pub.dev/packages/device_sentinel_linux) | Linux stub |
| [`device_sentinel_web`](https://pub.dev/packages/device_sentinel_web) | Web stub |

## Requirements

| | Minimum |
|---|---|
| Flutter | 3.10.0 |
| Dart | 3.0.0 |
| Android | API 19 |
| iOS | 13.0 |
| macOS | 10.14 |
| Windows | 10 |

## Known Limitations

- **Power button** cannot be consumed on any platform (observe-only)
- **iOS volume events** -- only `ButtonPressed` is emitted (no release)
- **Screen capture on Android** -- requires API 34+ (Android 14)
- **Unclean shutdown** -- heuristic based on heartbeat; not 100% reliable
- **Linux / Web** -- stub implementations; `start()` / `stop()` throw `PlatformUnsupportedException`

## Credits

Created and maintained by [DEVotion](https://github.com/Crdzbird) ([@Crdzbird](https://github.com/Crdzbird)).

## License

MIT License -- see [LICENSE](https://github.com/Crdzbird/device_sentinel/blob/main/LICENSE).
