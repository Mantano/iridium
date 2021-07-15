// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:r2_shared_dart/src/zip/zip_header.dart';

import '../zip/zip_header.dart';
import '../zip/zip_package.dart';
import 'stream.dart';

/// Random access stream to a file compressed in a ZIP archive.
class ZipStream extends DataStream {
  ZipStream(this._package, this._entry)
      : assert(_package != null),
        assert(_entry != null);

  final ZipPackage _package;
  final ZipLocalFile _entry;

  @override
  int get length => _entry.uncompressedSize;

  @override
  Future<Stream<List<int>>> read({int start, int length}) async {
    List<int> validatedRange = validateRange(start, length);
    start = validatedRange[0];
    length = validatedRange[1];
    IntRange range = IntRange(start, start + length);

    var stream = await _package.extractStream(_entry.filename, range: range);
    if (stream == null) {
      throw DataStreamException.readError(
          "Can't read file at ${_entry.filename}");
    }
    return stream;
  }
}
