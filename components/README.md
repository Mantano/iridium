# r2-streamer-dart

Streamer API and multiple file parsers (PDF, CBZ, Epub) for Dart.

## Epub parser

Epub parser for Dart inspired by [Readium 2](https://readium.org/technical/r2-toc/) Streamer ([Kotlin](https://github.com/readium/r2-streamer-kotlin), [Swift](https://github.com/readium/r2-streamer-kotlin), [Swift](https://github.com/readium/r2-streamer-swift) and [NodeJS/TypeScript](https://github.com/readium/r2-streamer-js).

## PDF parser

This package defines API for PDF support. However it does not provide an implementation. If the ```Streamer``` is not created with an implementation of ```PdfDocumentFactory```, an exception is raised when attempting to parse a PDF file.

This project aims at following the official [Readium 2 implementation](https://readium.org/technical/r2-toc/) as closely as possible.
