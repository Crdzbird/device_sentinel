# device_sentinel_ios

[![pub package](https://img.shields.io/pub/v/device_sentinel_ios.svg)](https://pub.dev/packages/device_sentinel_ios)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

The iOS implementation of [`device_sentinel`](https://pub.dev/packages/device_sentinel).

## Features

- Detect Volume Up, Volume Down, and Power button presses via `AVAudioSession` KVO
- Per-button interception via `MPVolumeView` volume reset
- Security event monitoring: connectivity (NWPathMonitor), screen lock (Darwin notifications), battery, screen capture (iOS 17+)

## Installation

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin), which means you can simply use `device_sentinel` normally. This package will be automatically included in your app when you do.

## Usage

See the [`device_sentinel`](https://pub.dev/packages/device_sentinel) package for usage instructions.

## License

MIT License -- see [LICENSE](LICENSE) for details.

Created by [DEVotion](https://github.com/Crdzbird) ([@Crdzbird](https://github.com/Crdzbird)).
