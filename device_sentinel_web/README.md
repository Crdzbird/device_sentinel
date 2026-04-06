# device_sentinel_web

[![pub package](https://img.shields.io/pub/v/device_sentinel_web.svg)](https://pub.dev/packages/device_sentinel_web)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

The Web stub implementation of [`device_sentinel`](https://pub.dev/packages/device_sentinel).

## Features

- **Stub only** -- neither button detection nor security monitoring is supported on Web
- `events` returns an empty stream
- `start()` / `stop()` throw `PlatformUnsupportedException`

## Installation

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin), which means you can simply use `device_sentinel` normally. This package will be automatically included in your app when you do.

## Usage

See the [`device_sentinel`](https://pub.dev/packages/device_sentinel) package for usage instructions.

## License

MIT License -- see [LICENSE](LICENSE) for details.

Created by [DEVotion](https://github.com/Crdzbird) ([@Crdzbird](https://github.com/Crdzbird)).
