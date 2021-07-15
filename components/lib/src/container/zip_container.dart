// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:r2_shared_dart/src/streams/stream.dart';
import 'package:r2_shared_dart/zip.dart';
import 'package:universal_io/io.dart';

import '../streams/zip_stream.dart';
import 'container.dart';

/// [Container] providing access to ZIP archives.
class ZipContainer extends Container {
  ZipContainer(this.path) : assert(path != null && path.isNotEmpty);

  /// Absolute path to the ZIP archive.
  final String path;

  @override
  String get identifier => path;

  /// ZIP archive holder.
  Future<ZipPackage> get archive async {
    if (_archive == null) {
      File file = File(path);
      if (!await file.exists()) {
        throw ContainerException.fileNotFound(path);
      }
      _archive = await ZipPackage.fromArchive(file);
      if (_archive == null) {
        throw ContainerException("Can't read ZIP archive at `$path`");
      }
    }
    return _archive;
  }

  ZipPackage _archive;

  @override
  Future<bool> existsAt(String path) async {
    assert(path != null);
    return (await archive).entries[path] != null;
  }

  @override
  Future<DataStream> streamAt(String path) async {
    assert(path != null);
    var package = await archive;
    var entry = package.entries[path];
    if (entry == null) {
      throw ContainerException.resourceNotFound(path);
    }
    return ZipStream(package, entry);
  }

  @override
  Future<int> resourceLength(String path) async {
    assert(path != null);
    var package = await archive;
    var entry = package.entries[path];
    if (entry == null) {
      throw ContainerException.resourceNotFound(path);
    }
    return entry.uncompressedSize;
  }
}
