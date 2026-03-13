# vol_spotter

[![pub package](https://img.shields.io/pub/v/vol_spotter.svg)](https://pub.dev/packages/vol_spotter)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A Flutter plugin for detecting physical button presses on Android and iOS.

Detect **Volume Up**, **Volume Down**, and **Power** button events with optional interception (consume the hardware event so the system volume doesn't change).

## Features

| Feature | Android | iOS |
|---|---|---|
| Volume Up detection | Yes | Yes |
| Volume Down detection | Yes | Yes |
| Power button detection | Yes | Yes |
| Volume interception (consume event) | Yes | Yes |
| `pressed` and `released` actions | Yes | `pressed` only |
| Minimum OS version | API 19 | iOS 13.0 |

## Getting Started

```sh
flutter pub add vol_spotter
```

## Usage

### Listen for button events

```dart
import 'package:vol_spotter/vol_spotter.dart';

final volSpotter = const VolSpotter();

// Start listening (call once)
await volSpotter.startListening();

// React to events
volSpotter.buttonEvents.listen((event) {
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

// Stop when done
await volSpotter.stopListening();
```

### Intercept volume events

When `interceptVolumeEvents` is `true`, hardware volume changes are consumed so the system volume stays unchanged and the app receives the raw button press instead.

```dart
await volSpotter.startListening(
  config: const VolSpotterConfig(interceptVolumeEvents: true),
);
```

### Full counter example

The plugin ships with a counter demo where Volume Up increments, Volume Down decrements, and Power resets. See [`example/lib/main.dart`](example/lib/main.dart).

## Models

The plugin uses Dart 3 sealed classes for type-safe pattern matching.

| Class | Variants |
|---|---|
| `PhysicalButton` | `VolumeUpButton`, `VolumeDownButton`, `PowerButton` |
| `ButtonAction` | `ButtonPressed`, `ButtonReleased` |
| `ButtonEvent` | Combines a `PhysicalButton` + `ButtonAction` |
| `VolSpotterConfig` | `interceptVolumeEvents`, `interceptPowerEvents` |

## Architecture

`vol_spotter` follows the [federated plugin](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins) pattern:

| Package | Purpose |
|---|---|
| [`vol_spotter`](https://pub.dev/packages/vol_spotter) | App-facing API |
| [`vol_spotter_platform_interface`](https://pub.dev/packages/vol_spotter_platform_interface) | Shared interface and models |
| [`vol_spotter_android`](https://pub.dev/packages/vol_spotter_android) | Android implementation |
| [`vol_spotter_ios`](https://pub.dev/packages/vol_spotter_ios) | iOS implementation |
| [`vol_spotter_macos`](https://pub.dev/packages/vol_spotter_macos) | macOS implementation |
| [`vol_spotter_windows`](https://pub.dev/packages/vol_spotter_windows) | Windows implementation |
| [`vol_spotter_linux`](https://pub.dev/packages/vol_spotter_linux) | Linux stub |
| [`vol_spotter_web`](https://pub.dev/packages/vol_spotter_web) | Web stub |

## Platform Details

### Android

- **Volume**: intercepts `KEYCODE_VOLUME_UP` / `KEYCODE_VOLUME_DOWN` via a `Window.Callback` proxy. Emits both `pressed` and `released` actions.
- **Power**: listens for `ACTION_SCREEN_OFF` via `BroadcastReceiver`. Emits `pressed` only.
- Requires an active `Activity` (works automatically when the Flutter engine is attached).

### iOS

- **Volume**: observes `AVAudioSession.outputVolume` via KVO. A hidden `MPVolumeView` suppresses the system HUD and resets the slider when interception is enabled.
- **Power**: observes `protectedDataWillBecomeUnavailableNotification` for screen lock detection.
- Only `ButtonPressed` is emitted (iOS KVO fires once per press with no separate release event).
- Volume boundary detection uses a `1/128` offset to keep the volume away from `0.0`/`1.0` so subsequent presses are always detected.

## Known Limitations

- **Power button cannot be consumed** on either platform. `interceptPowerEvents` is observe-only.
- **iOS volume interception** may cause a brief visual flicker as the hidden slider resets.
- **iOS simulator**: volume buttons are available under **Hardware > Volume Up / Volume Down**, but behavior may differ from a physical device.

## Requirements

| | Minimum |
|---|---|
| Flutter | 3.10.0 |
| Dart | 3.0.0 |
| Android | API 19 |
| iOS | 13.0 |

## Credits

Created and maintained by [@Crdzbird](https://github.com/Crdzbird).

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/Crdzbird/vol_spotter/blob/main/LICENSE) file for details.
