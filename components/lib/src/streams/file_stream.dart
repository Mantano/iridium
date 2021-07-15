// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:universal_io/io.dart';

import 'stream.dart';

/// Random access stream to a file.
class FileStream extends DataStream {
  FileStream._(this._file, this._length)
      : assert(_file != null),
        assert(_length != null);

  static Future<FileStream> fromFile(File file) async {
    var raFile = await file.open();
    var length = await raFile.length();
    return FileStream._(raFile, length);
  }

  final RandomAccessFile _file;
  final int _length;

  @override
  int get length => _length;

  @override
  Future<Stream<List<int>>> read({int start, int length}) async {
    var range = validateRange(start, length);
    start = range[0];
    length = range[1];

    await _file.setPosition(start);
    var bytes = _file.read(length);
    return Stream.fromFuture(bytes);
  }
}
