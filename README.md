# mp-readium, the "Multi-platform Readium"

Unofficial Dart/Flutter port of some of the Readium 2 components, following the Readium architecture as described [here](https://github.com/readium/architecture)). These modules are extracted from the new Mantano app, written in pure Flutter/Dart (still not publicly released).

The aim of this effort is to share with the community Mantano's experience in developing "full-Flutter" reading apps. It leverage Flutter's multiplatform capabilities to the limits in order to reach a unified codebase and minimize the platform-specific code. 

Developed and tested on Android and iOS first, large parts of the code should be reusable for desktop and web apps.

## Modules

* [mno-shared-dart]() – Shared Publication models and utilities
* [mno-streamer-dart]() – Publication parsers
* [mno-server-dart]() – Local HTTP server
* [mno-opds-dart]() – Parsers for OPDS catalog feeds
* [mno-commons-dart]() – Other misc. utilities (specific to this Flutter port, not found in Readium)

## Modules soon available

These modules require some cleanup and more testing before being made public:

* mno-lcp-dart]() – Service and models for Readium LCP
* mno-navigator-kotlin – Rendering publications
