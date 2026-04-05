# Device Sentinel

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin for monitoring **physical button presses** and **device security events** on Android and iOS.

Detects Volume Up, Volume Down, and Power button events with configurable interception, plus ~25 types of security events including network changes, screen lock, battery levels, USB debugging, screen capture, and more.

Built with the [Very Good Ventures](https://verygood.ventures/) federated plugin architecture.

> **Formerly `vol_spotter`** - renamed to `device_sentinel` in v1.0.0.

---

## Features

### Button Detection
- Detect **Volume Up**, **Volume Down**, and **Power** button events
- **Configurable interception** -- consume volume events so the system volume stays unchanged, or simply observe them
- Broadcast stream with multiple listeners

### Security Event Monitoring
- **~25 event types** organized in 5 categories (Shutdown, Connectivity, Screen/Lock, Power/USB, Security Posture)
- **String wire protocol** with forward compatibility -- unknown events return `null`
- **Granular control** via `SecurityConfig` to enable/disable categories
- Type-safe API using Dart 3 sealed classes and exhaustive pattern matching

## Platform Support

### Button Events

| Platform | Volume Up/Down | Power Button | Interception |
|----------|:--------------:|:------------:|:------------:|
| Android  |       ✅       |      ✅      | ✅ (volume)  |
| iOS      |       ✅       |      ✅      | ✅ (volume)  |
| macOS    |       ✅       |      ✅      |      --      |
| Windows  |       ✅       |      ✅      | ✅ (volume)  |
| Linux    |       --       |      --      |      --      |
| Web      |       --       |      --      |      --      |

### Security Events

| Event | Android | iOS |
|-------|:-------:|:---:|
| Shutdown / Reboot detected | ✅ | -- |
| Unclean shutdown | ✅ | ✅ |
| Airplane mode | ✅ | -- |
| Network connected/disconnected | ✅ | ✅ |
| Network capabilities (WiFi/Mobile) | ✅ | ✅ |
| VPN established/disconnected | ✅ | ✅ |
| Screen on/off | ✅ | ✅ |
| Device locked/unlocked | ✅ | ✅ |
| User present (after unlock) | ✅ | -- |
| Power connected/disconnected | ✅ | ✅ |
| Battery low (<=20%) / critical (<=5%) | ✅ | ✅ |
| USB debugging enabled/disabled | ✅ | -- |
| Screen capture started/stopped | ✅ (API 34+) | ✅ |
| Developer mode enabled/disabled | ✅ | -- |

## Getting Started

### Installation

```yaml
dependencies:
  device_sentinel: ^1.0.0
```

### Button Detection

```dart
import 'package:device_sentinel/device_sentinel.dart';

final sentinel = const DeviceSentinel();

await sentinel.startListening(
  config: const DeviceSentinelConfig(interceptVolumeEvents: true),
);

sentinel.buttonEvents.listen((event) {
  if (event.action is! ButtonPressed) return;

  switch (event.button) {
    case VolumeUpButton():
      print('Volume Up pressed');
    case VolumeDownButton():
      print('Volume Down pressed');
    case PowerButton():
      print('Power button pressed');
  }
});

await sentinel.stopListening();
```

### Security Event Monitoring

```dart
await sentinel.startSecurityMonitoring(
  config: const SecurityConfig(
    monitorShutdown: true,
    monitorConnectivity: true,
    monitorScreenLock: true,
    monitorPowerUsb: true,
    monitorSecurityPosture: true,
  ),
);

sentinel.securityEvents.listen((event) {
  switch (event) {
    case ScreenOff():
      print('Screen turned off');
    case DeviceLocked():
      print('Device locked');
    case NetworkDisconnected():
      print('Network lost');
    case BatteryLow(:final level):
      print('Battery low: $level%');
    case ScreenCaptureStarted():
      print('Screen recording detected!');
    case UncleanShutdownDetected(:final lastSeenTimestamp):
      print('Crash detected! Last seen: $lastSeenTimestamp');
    default:
      print('Security event: $event');
  }
});

await sentinel.stopSecurityMonitoring();
```

## API Reference

### `DeviceSentinel`

| Member | Type | Description |
|--------|------|-------------|
| `buttonEvents` | `Stream<ButtonEvent>` | Broadcast stream of physical button events |
| `startListening({config})` | `Future<void>` | Begin detecting button presses |
| `stopListening()` | `Future<void>` | Stop button detection |
| `securityEvents` | `Stream<DeviceSecurityEvent>` | Broadcast stream of security events |
| `startSecurityMonitoring({config})` | `Future<void>` | Begin monitoring security events |
| `stopSecurityMonitoring()` | `Future<void>` | Stop security monitoring |

### `SecurityConfig`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `monitorShutdown` | `bool` | `true` | Shutdown, reboot, unclean shutdown events |
| `monitorConnectivity` | `bool` | `true` | Network, airplane mode, VPN events |
| `monitorScreenLock` | `bool` | `true` | Screen on/off, lock/unlock events |
| `monitorPowerUsb` | `bool` | `true` | Charger, battery, USB debugging events |
| `monitorSecurityPosture` | `bool` | `true` | Screen capture, developer mode events |

### `DeviceSecurityEvent` (sealed class hierarchy)

| Category | Events |
|----------|--------|
| Shutdown | `ShutdownDetected`, `RebootDetected`, `UncleanShutdownDetected(lastSeenTimestamp)` |
| Connectivity | `AirplaneModeOn/Off`, `NetworkConnected/Disconnected`, `NetworkCapsChanged(hasWifi, hasMobile)`, `VpnEstablished/Disconnected` |
| Screen/Lock | `ScreenOff/On`, `DeviceLocked/Unlocked`, `UserPresent` |
| Power/USB | `PowerConnected/Disconnected`, `BatteryLow(level)`, `BatteryCritical(level)`, `UsbDebuggingEnabled/Disabled` |
| Security | `ScreenCaptureStarted/Stopped`, `DevModeEnabled/Disabled` |

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

### Native Implementation

| Platform | Button Detection | Security Events |
|----------|-----------------|-----------------|
| Android | `Window.Callback` proxy for volume keys; `BroadcastReceiver` for power | `BroadcastReceiver`, `ConnectivityManager.NetworkCallback`, `ContentObserver`, `Activity.ScreenCaptureCallback` (API 34+) |
| iOS | KVO on `AVAudioSession.outputVolume` + `MPVolumeView`; `protectedDataWillBecomeUnavailableNotification` | `NWPathMonitor`, Darwin notification center, `UIDevice` battery, `UIScreen.capturedDidChangeNotification` |

## Running Tests

```bash
for pkg in device_sentinel_platform_interface device_sentinel_android device_sentinel_ios \
           device_sentinel device_sentinel_linux device_sentinel_macos device_sentinel_windows \
           device_sentinel_web; do
  (cd "$pkg" && flutter test)
done
```

## Known Limitations

- **iOS volume events** -- Only `ButtonPressed` is emitted (no release detection)
- **Power button** -- Cannot be consumed/intercepted on either platform; detection only
- **Screen capture on Android** -- Requires API 34+ (Android 14)
- **iOS lock detection** -- Uses Darwin notifications which may have slight delays
- **Unclean shutdown** -- Uses heartbeat + SharedPreferences/UserDefaults heuristic; not 100% reliable

## Credits

Created and maintained by **[@Crdzbird](https://github.com/Crdzbird)**.

Built with the [Very Good CLI][very_good_cli_link] federated plugin template by [Very Good Ventures][very_good_ventures_link].

## License

This project is licensed under the MIT License -- see the [LICENSE](LICENSE) file for details.

[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
[very_good_ventures_link]: https://verygood.ventures/?utm_source=github&utm_medium=banner&utm_campaign=device_sentinel
