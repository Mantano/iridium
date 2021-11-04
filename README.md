# Iridium [Ir], the multi-platform reader toolkit

This project provides unofficial Dart/Flutter ports of the Readium 2 (R2) components<sup>[1](#readium_foundation)</sup>,
following the [Readium 2 architecture](https://github.com/readium/architecture).

It leverages Flutter's multiplatform capabilities to the limits by minimizing the platform-specific code as much as
possible, in order to reach a really unified codebase. Developed and tested on Android and iOS first, large parts of the
code should be reusable for desktop and web apps.

This project could pave the way to a "unified reference implementation" for Readium, with a codebase working across all
platforms. However, Iridium is purely a Mantano initiative, and does not reflect any official Readium move towards
Dart/Flutter development.

Iridium is named after the chemical element, which is known for being extremely corrosion-resistant: this reader will
stand the test of time :sunglasses:

## Migrating an existing R2-based platform-specific app

Since the purpose is to allow full multiplatform development, these modules aim at being integrated into Dart/Flutter
apps. Some of them could probably be [integrated into existing apps](https://flutter.dev/docs/development/add-to-app).

However, *packing multiple Flutter libraries into an application isn’t supported by Flutter for now*. Integrating
multiple modules could be achieved by developing some kind of "super-module", but this has not been tested.

## Modules

* [mno_shared_dart](https://github.com/Mantano/mno_shared_dart) – Shared Publication models and utilities
* [mno_streamer_dart](https://github.com/Mantano/mno_streamer_dart) – Publication parsers
* [mno_server_dart](https://github.com/Mantano/mno_server_dart) – Local HTTP server
* [mno_opds_dart](https://github.com/Mantano/mno_opds_dart) – Parsers for OPDS catalog feeds
* [mno_commons_dart](https://github.com/Mantano/mno_commons_dart) – Other misc. utilities (specific to this Flutter
  port, not found in Readium)
* [mno_lcp_dart](https://github.com/Mantano/mno_lcp_dart) – Service and models for Readium LCP (soon public)

-----------
<a name="readium_foundation">1</a>: Readium is a trademark of the [Readium Foundation](https://readium.org/))
