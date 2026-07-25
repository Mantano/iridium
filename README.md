Iridium is an open-source multiplatform e-reader Software Development Kit developed with [Dart](https://dart.dev/)
and [Flutter](https://flutter.dev/) by [Mantano](https://www.mantano.com).

> **Note — trimmed tree (July 2026).** This repository now only contains the components actually used by the
> **Assimil** application. The demo app (`demo-app`), the plug-and-play reader widget (`reader_widget`) and the
> unused `opds` (OPDS catalog parsers) and `lcp` (Readium LCP DRM) components were removed during a cleanup.
> To recover any of them, use the safeguard tag:
>
> ```
> git checkout avant-degraissage-assimil-2026-07-25 -- <path>
> ```
>
> The full upstream version remains available at [github.com/Mantano/iridium](https://github.com/Mantano/iridium).

## Features

- [x] EPUB 2.x and 3.x support
- [x] Custom styles
- [x] Night & sepia modes
- [x] Pagination
- [x] Table of contents
- [x] RTL support

# Components

This SDK provides open-source unofficial Dart/Flutter ports of Readium 2 (R2)
components<sup>[1](#readium_foundation)</sup>, following
the [Readium 2 architecture](https://github.com/readium/architecture):

| Name          | Usage                                                                       |
|---------------|-----------------------------------------------------------------------------|
| **shared**    | Shared Publication models and utilities                                     |
| **streamer**  | Publication parsers                                                         |
| **server**    | Local HTTP server                                                           |
| **navigator** | Navigator                                                                   |
| **commons**   | Other misc. utilities (specific to this Flutter port, not found in Readium) |
| **webview**   | Flutter WebView fork used by the navigator                                  |

Each component lives in `components/<name>` and is consumed as a path dependency by the
`flutter_commons` and `assimil_commons` modules of the Assimil app.

# Supported platforms

Iridium is currently developed and tested on Android and iOS first, but large parts of the code should be reusable for
desktop and web apps.

# Iridium vs Readium

Developed in the continuity of Readium 2, Iridium could pave the way to a "unified reference implementation" for
Readium, with a unique codebase working across all platforms. However, Iridium is purely a Mantano initiative, and does
not reflect any official Readium move towards Dart/Flutter development.

# Why this name?

Iridium is named after the chemical element, which is known for being extremely corrosion-resistant: this reader will
stand the test of time 😎


-----------
<a name="readium_foundation">1</a>: Readium is a trademark of the [Readium Foundation](https://readium.org/))
