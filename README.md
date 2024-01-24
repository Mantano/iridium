Iridium is an open-source multiplatform e-reader Software Development Kit developed with [Dart](https://dart.dev/)
and [Flutter](https://flutter.dev/) by [Mantano](https://www.mantano.com).

Iridium keeps the platform-specific code to the bare minimum (zero for now, in fact...). Hence, it does provide a really
unified codebase. Until now, only the precompiled LCP DRM native library is specific to each platform, and is provided
in binary form by [Edrlab](https://edrlab.org) that simply must be dropped into the source tree.


## Features

- [x] EPUB 2.x and 3.x support
- [x] WebPub support (thanks to [Morten Sjøgren](https://github.com/m-abs), [Nota](https://github.com/Notalib)
- [ ] Audiobook support
- [ ] PDF support
- [x] Readium LCP support (not in demo app yet)
- [x] CBZ support (not in demo app yet)
- [x] Custom styles
- [x] Night & sepia modes
- [x] Pagination
- [ ] Scrolling
- [x] Table of contents
- [x] OPDS 1.x and 2.0 support
- [ ] FXL support
- [x] RTL support
- [ ] Search in EPUB
- [ ] Highlights/annotations
- [ ] TTS
- [ ] EPUB 3 Media Overlays
- [ ] Divina support

# Test it right now!

## Pre-built versions
Pre-built versions of the [Iridium Demo App](https://github.com/Mantano/iridium/tree/main/demo-app) are available:
- For Android: [Beta on Play Store](https://play.google.com/store/apps/details?id=com.mantano.iridium.IridiumApp)
- For iOS: [IPA here](https://api.codemagic.io/artifacts/cafe9a91-b4d5-48f0-b716-ca948d8e11ac/3c8b8914-96c5-4597-8c60-3a3ead8eda1f/Iridium.ipa)

Note: The Iridium Demo App is based on the excellent [Jideguru's Flutter Ebook App](https://github.com/JideGuru/FlutterEbookApp).

## Build it yourself

### From the command-line
```
git clone https://github.com/Mantano/iridium.git
cd iridium/demo-app
flutter devices <-- Pick a device id in the list (in the 2nd column)
flutter run -d <device_id>
```

If you see the following error message:
```
Error: Could not find or load main class org.gradle.wrapper.GradleWrapperMain
```
apply [the fix mentioned in this post](https://github.com/flutter/flutter/issues/14422#issuecomment-389192340).

### From Android Studio or Intellij IDEA:

- File / New / From Version Control (https://github.com/Mantano/iridium.git)
- Run the project in the `demo-app` subdirectory

# Supported platforms

Iridium is currently developed and tested on Android and iOS first, but large parts of the code should be reusable for
desktop and web apps. Such desktop and web versions are not currently on the roadmap, but will be considered if we can
collect external funding or aggregate external contributors.

# Components

This SDK provides open-source unofficial Dart/Flutter ports of Readium 2 (R2)
components<sup>[1](#readium_foundation)</sup>, following
the [Readium 2 architecture](https://github.com/readium/architecture):

| Name                                                                               | Usage                                                                                           |
|------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| [**shared**](https://github.com/Mantano/iridium/tree/main/components/shared) | Shared Publication models and utilities                                                         |
| [**streamer**](https://github.com/Mantano/iridium/tree/main/components/streamer)              | Publication parsers                                                                             |
| [**server**](https://github.com/Mantano/iridium/tree/main/components/mno_server)                          | Local HTTP server                                                                               |
| [**navigator_flutter**](https://github.com/Mantano/iridium/tree/main/components/navigator)              | Navigator                                                                                       |
| [**opds**](https://github.com/Mantano/iridium/tree/main/components/opds)                              | Parsers for OPDS catalog feeds                                                                  |
| [**commons**](https://github.com/Mantano/iridium/tree/main/components/commons)                        | Other misc. utilities (specific to this Flutter port, not found in Readium)                     |
| [**lcp**](https://github.com/Mantano/iridium/tree/main/components/lcp)                                | Service and models for Readium LCP                                                              |

Beyond these Readium 2 inspired modules, Iridium provides 2 conveniences:

| Name                                                                          | Usage                                                                                           |
|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| [**iridium_reader_widget**](https://github.com/Mantano/iridium/tree/main/reader_widget) | Plug and play reader widget                                                                     |
| [**iridium_demo**](https://github.com/Mantano/iridium/tree/main/demo-app)               | A demo app based on [JideGuru's Flutter Ebook App](https://github.com/JideGuru/FlutterEbookApp) |

# Integrating into your app

There are 3 main options, from simplest to most advanced

- Option 1: Fork and tailor the Iridium Demo App
- Option 2: Integrate the [**iridium_reader_widget**](https://github.com/Mantano/iridium/tree/main/reader_widget) into your app
- Option 3: Integrate the Iridium modules the way you want. The [**iridium_reader_widget**](https://github.com/Mantano/iridium/tree/main/reader_widget) source code
provides a lot of clues bout the relationships between the Iridium modules, and the workflows required to open and display a book.

# Iridium vs Readium

Developed in the continuity of Readium 2, Iridium could pave the way to a "unified reference implementation" for
Readium, with a unique codebase working across all platforms. However, Iridium is purely a Mantano initiative, and does
not reflect any official Readium move towards Dart/Flutter development.

The Readium SDK is funded by public grants and membership fees. Iridium is completely funded and developed by Mantano,
which is a private company. As a consequence:

- You can support this work by [becoming a sponsor](https://github.com/sponsors/Mantano);
- One of the sponsorship tiers gives full access to Iridium's optimized "navigator" component.

## Migrating an existing R2-based platform-specific app

Since the purpose is to allow full multiplatform development, these modules aim at being integrated into Dart/Flutter
apps. Some of them could probably be [integrated into existing apps](https://flutter.dev/docs/development/add-to-app).

However, *packing multiple Flutter libraries into an application isn’t supported by Flutter for now*. Integrating
multiple modules could be achieved by developing some kind of "super-module", but this has not been tested.

# Applications based on Iridium

OK... Let's face it, Iridium is brand new. So this list is currently reduced to Mantano's own forthcoming app, but good
surprises are on the way ;-)

# Why this name?

Iridium is named after the chemical element, which is known for being extremely corrosion-resistant: this reader will
stand the test of time 😎

# Support

You use this project for professional projects or just like it? Please consider [making a donation](https://www.paypal.com/donate/?hosted_button_id=4G7YYLF8624DQ) to help improve it!

-----------
<a name="readium_foundation">1</a>: Readium is a trademark of the [Readium Foundation](https://readium.org/))
