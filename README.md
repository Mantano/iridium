# Iridium [Ir], the multi-platform reader toolkit

Iridium is a multiplatform e-reader Software Development Kit. It leverages Flutter's multiplatform capabilities and
minimizes the platform-specific code as much as possible. Hence, it does provide a really unified codebase.

## Supported platforms

Iridium is currently developed and tested on Android and iOS first, large parts of the code should be reusable for
desktop and web apps. Such desktop and web versions are not currently on the roadmap, but will be considered if we can
collect external funding or aggregate external contributors.

## Components

This SDK provides:

- Open-source unofficial Dart/Flutter ports of Readium 2 (R2) components<sup>[1](#readium_foundation)</sup>, following
  the [Readium 2 architecture](https://github.com/readium/architecture).
- Private components and demo app, accessible through [sponsored contributions](https://github.com/sponsors/Mantano).

## Why this name?

Iridium is named after the chemical element, which is known for being extremely corrosion-resistant: this reader will
stand the test of time 😎

# Iridium vs Readium

Developed in the continuity of Readium 2, Iridium could pave the way to a "unified reference implementation" for
Readium, with a unique codebase working across all platforms. However, Iridium is purely a Mantano initiative, and does
not reflect any official Readium move towards Dart/Flutter development.

The Readium SDK is funded by public grants and membership fees. Iridium is completely funded and developed by Mantano,
which is a private company. As a consequence:

- You can also simply become a sponsor without paying the price of the access to the Navigator component: many
  sponsorship tiers are available, starting at very low prices. Please look at [sponsored contributions](https://github.com/sponsors/Mantano) for more details;
- Iridium's highly optimized "navigator" component source code is made only available
  through the a specific sponsorship tier. However, please note that the Iridium SDK can easily be used
  without this paid component. In this case, you have to develop a Navigator by yourself.

## Migrating an existing R2-based platform-specific app

Since the purpose is to allow full multiplatform development, these modules aim at being integrated into Dart/Flutter
apps. Some of them could probably be [integrated into existing apps](https://flutter.dev/docs/development/add-to-app).

However, *packing multiple Flutter libraries into an application isn’t supported by Flutter for now*. Integrating
multiple modules could be achieved by developing some kind of "super-module", but this has not been tested.

## Public Modules

* [mno_shared_dart](https://github.com/Mantano/mno_shared_dart) – Shared Publication models and utilities
* [mno_streamer_dart](https://github.com/Mantano/mno_streamer_dart) – Publication parsers
* [mno_server_dart](https://github.com/Mantano/mno_server_dart) – Local HTTP server
* [mno_opds_dart](https://github.com/Mantano/mno_opds_dart) – Parsers for OPDS catalog feeds
* [mno_commons_dart](https://github.com/Mantano/mno_commons_dart) – Other misc. utilities (specific to this Flutter
  port, not found in Readium)
* [mno_lcp_dart](https://github.com/Mantano/mno_lcp_dart) – Service and models for Readium LCP (soon public)
* [mno_iridium_app](https://github.com/Mantano/mno_iridium_app) – Iridium SDK demo app (*requires the private modules*)

## Private Modules

* [mno_navigator_flutter](https://github.com/Mantano/mno_navigator_flutter) – Navigator

-----------
<a name="readium_foundation">1</a>: Readium is a trademark of the [Readium Foundation](https://readium.org/))
