# device_sentinel_platform_interface

[![pub package](https://img.shields.io/pub/v/device_sentinel_platform_interface.svg)](https://pub.dev/packages/device_sentinel_platform_interface)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A common platform interface for the [`device_sentinel`](https://pub.dev/packages/device_sentinel) plugin.

## Features

- Abstract `DeviceSentinelPlatform` class with unified `events`, `start`, and `stop` API
- Sealed event hierarchy: `DeviceEvent` > `ButtonEvent` / `DeviceSecurityEvent`
- `SentinelConfig` for per-button interception and security category toggles
- Typed `DeviceSentinelException` hierarchy for structured error handling
- `EventChannelMixin` and `ButtonOnlyEventChannelMixin` for platform implementations

## Usage

To implement a new platform-specific implementation of `device_sentinel`, extend `DeviceSentinelPlatform` with an implementation that performs the platform-specific behavior.

See the [`device_sentinel`](https://pub.dev/packages/device_sentinel) package for end-user documentation.

## License

MIT License -- see [LICENSE](LICENSE) for details.

Created by [DEVotion](https://github.com/Crdzbird) ([@Crdzbird](https://github.com/Crdzbird)).
