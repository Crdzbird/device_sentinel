# Vol Spotter

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin for detecting physical button presses — **Volume Up**, **Volume Down**, and **Power** — on Android and iOS.

Built with the [Very Good Ventures](https://verygood.ventures/) federated plugin architecture for clean separation of platform code and maximum testability.

---

## Features

- Detect **Volume Up**, **Volume Down**, and **Power** button events
- **Configurable interception** — consume volume events so the system volume stays unchanged, or simply observe them
- **Type-safe API** using Dart 3 sealed classes and exhaustive pattern matching
- Broadcast stream — attach multiple listeners to the same event source
- Federated architecture — only the platforms you target are compiled

## Platform Support

| Platform | Volume Up/Down | Power Button | Interception |
|----------|:--------------:|:------------:|:------------:|
| Android  | ✅             | ✅           | ✅ (volume)  |
| iOS      | ✅             | ✅           | ✅ (volume)  |
| Web      | —              | —            | —            |
| Desktop  | —              | —            | —            |

> **Note:** Power button events cannot be truly intercepted on either platform — `interceptPowerEvents` is observe-only.

## Getting Started

### Installation

Add `vol_spotter` to your `pubspec.yaml`:

```yaml
dependencies:
  vol_spotter: ^0.1.0
```

### Quick Start

```dart
import 'package:vol_spotter/vol_spotter.dart';

final volSpotter = const VolSpotter();

// Start listening (optionally intercept volume so system volume doesn't change)
await volSpotter.startListening(
  config: const VolSpotterConfig(interceptVolumeEvents: true),
);

// React to button presses
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

// When done
await volSpotter.stopListening();
```

## API Reference

### `VolSpotter`

| Member | Type | Description |
|--------|------|-------------|
| `buttonEvents` | `Stream<ButtonEvent>` | Broadcast stream of physical button events |
| `startListening({config})` | `Future<void>` | Begin detecting button presses |
| `stopListening()` | `Future<void>` | Stop detection and release native resources |

### `VolSpotterConfig`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `interceptVolumeEvents` | `bool` | `false` | When `true`, volume key presses are consumed — the system volume does not change |
| `interceptPowerEvents` | `bool` | `false` | Informational only — power button cannot be truly intercepted |

### `ButtonEvent`

Combines a `PhysicalButton` and a `ButtonAction`:

```dart
sealed class PhysicalButton  →  VolumeUpButton | VolumeDownButton | PowerButton
sealed class ButtonAction    →  ButtonPressed  | ButtonReleased
```

> **iOS limitation:** Volume buttons only emit `ButtonPressed` (no `ButtonReleased`). Power button detection uses `protectedDataWillBecomeUnavailableNotification`.

## Example App

The included example app is a counter driven entirely by hardware buttons:

- **Volume Up** → increment
- **Volume Down** → decrement
- **Power** → reset to 0

Run it with:

```bash
cd vol_spotter/example
flutter run
```

## Architecture

This plugin follows the **federated plugin** pattern:

```
vol_spotter/                        # App-facing package (public API)
vol_spotter_platform_interface/     # Abstract interface + domain models
vol_spotter_android/                # Android implementation (Kotlin)
vol_spotter_ios/                    # iOS implementation (Swift)
vol_spotter_linux/                  # Stub (UnsupportedError)
vol_spotter_macos/                  # Stub (UnsupportedError)
vol_spotter_web/                    # Stub (UnsupportedError)
vol_spotter_windows/                # Stub (UnsupportedError)
```

**Native approach:**

| Platform | Volume Detection | Power Detection |
|----------|-----------------|-----------------|
| Android  | `Window.Callback` proxy intercepting `KEYCODE_VOLUME_UP/DOWN` | `BroadcastReceiver` for `ACTION_SCREEN_OFF` |
| iOS      | KVO on `AVAudioSession.outputVolume` + hidden `MPVolumeView` | `protectedDataWillBecomeUnavailableNotification` |

## Running Tests

```bash
# Run tests for all packages
for pkg in vol_spotter_platform_interface vol_spotter_android vol_spotter_ios \
           vol_spotter vol_spotter_linux vol_spotter_macos vol_spotter_windows \
           vol_spotter_web; do
  (cd "$pkg" && flutter test)
done
```

## Known Limitations

- **iOS volume events** — Only `ButtonPressed` is emitted (KVO fires once per press, no release detection)
- **iOS volume interception** — Brief visual flicker is possible when resetting volume via `MPVolumeView` slider
- **Power button** — Cannot be consumed/intercepted on either platform; detection only
- **iOS Simulator** — Volume buttons can be simulated via **Hardware → Volume Up/Down**; power button detection requires a physical device

## Credits

Created and maintained by **[@Crdzbird](https://github.com/Crdzbird)**.

Built with the [Very Good CLI][very_good_cli_link] federated plugin template by [Very Good Ventures][very_good_ventures_link].

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
[very_good_ventures_link]: https://verygood.ventures/?utm_source=github&utm_medium=banner&utm_campaign=core
