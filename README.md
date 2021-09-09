# mp-readium, the unofficial "Multi-platform Readium"

*(Readium is a trademark of the [Readium Foundation](https://readium.org/))*

These repositories provide Mantano's unofficial Dart/Flutter ports of some of the Readium 2 components, following the Readium architecture as described [here](https://github.com/readium/architecture)). These modules are extracted from a new app, written in pure Flutter/Dart (still not publicly released).

The aim of this effort is to share with the community Mantano's experience in developing "full-Flutter" reading apps. It leverage Flutter's multiplatform capabilities to the limits in order to reach a unified codebase and minimize the platform-specific code. 

Developed and tested on Android and iOS first, large parts of the code should be reusable for desktop and web apps.

## Modules

* [mno-shared-dart](https://github.com/Mantano/mno_shared_dart) – Shared Publication models and utilities
* [mno-streamer-dart](https://github.com/Mantano/mno_streamer_dart) – Publication parsers
* [mno-server-dart](https://github.com/Mantano/mno_server_dart) – Local HTTP server
* [mno-opds-dart](https://github.com/Mantano/mno_opds_dart) – Parsers for OPDS catalog feeds
* [mno-commons-dart](https://github.com/Mantano/mno_commons_dart) – Other misc. utilities (specific to this Flutter port, not found in Readium)

## Modules soon available

* mno-lcp-dart – Service and models for Readium LCP
