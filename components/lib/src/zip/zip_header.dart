// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:r2_commons_dart/utils/jsonable.dart';

import 'file_buffer.dart';

abstract class ZipHeader {
  /// Compression method for uncompressed entries.
  static const int stored = 0;

  /// Compression method for compressed (deflated) entries.
  static const int deflated = 8;
  ZipHeader(this.signature);
  final int signature; // 2 bytes

  bool get isLocalFile => signature == 0x0403;
  bool get isCentralDirectory => signature == 0x0201;
  bool get isCentralDirectoryEnd => signature == 0x0605;

  Future<void> _read(FileBuffer src);

  int offsetStart, offsetEnd;

  @override
  String toString() => jsonEncode(this);

  static Future<ZipHeader> readNext(FileBuffer src, int signature) async {
    if (src.isEnd) return null;

    ZipHeader r;
    if (signature == 0x0403) {
      // local file
      r = ZipLocalFile(signature);
    } else if (signature == 0x0201) {
      // central directory
      r = ZipCentralDirectory(signature);
    } else if (signature == 0x0605) {
      // end of central directory
      r = ZipEndCentralDirectory(signature);
    } else {
      return null;
    }

    r.offsetStart = src.position - 4;
    await r._read(src);
    r.offsetEnd = src.position;

    return r;
  }
}

class ZipLocalFile extends ZipHeader implements JSONable {
  ZipLocalFile(int signature) : super(signature);

  int versionToExtract; // 2 bytes
  int generalFlag; // 2 bytes
  int compressionMethod; // 2 bytes
  int lastModTime; // 2 bytes
  int lastModDate; // 2 bytes
  int crc32; // 4 bytes
  int compressedSize; // 4 bytes
  int uncompressedSize; // 4 bytes
  int filenameSize; // 2 bytes
  int extraFieldSize; // 2 bytes

  String filename;
  List<int> extraField;

  Future<void> _readLocalFileBase(FileBuffer src) async {
    versionToExtract = await src.readUint16();
    generalFlag = await src.readUint16();
    compressionMethod = await src.readUint16();
    lastModTime = await src.readUint16();
    lastModDate = await src.readUint16();
    crc32 = await src.readUint32();
    compressedSize = await src.readUint32();
    uncompressedSize = await src.readUint32();
    filenameSize = await src.readUint16();
    extraFieldSize = await src.readUint16();
  }

  Future<void> _readLocalFileDynamic(FileBuffer src) async {
    filename = await src.readUtf8(filenameSize);
    extraField = await src.read(extraFieldSize);
  }

  @override
  Future<void> _read(FileBuffer src) async {
    await _readLocalFileBase(src);
    await _readLocalFileDynamic(src);
  }

  @override
  Map<String, dynamic> toJson() => {
        'signature': signature.toRadixString(16).padLeft(4, '0'),
        'versionToExtract': versionToExtract,
        'generalFlag': generalFlag.toRadixString(16).padLeft(4, '0'),
        'compressionMethod':
            compressionMethod.toRadixString(16).padLeft(4, '0'),
        'lastModTime': lastModTime.toRadixString(16).padLeft(4, '0'),
        'lastModDate': lastModDate.toRadixString(16).padLeft(4, '0'),
        'crc32': crc32.toRadixString(16).padLeft(8, '0'),
        'compressedSize': compressedSize,
        'uncompressedSize': uncompressedSize,
        'filenameSize': filenameSize,
        'extraFieldSize': extraFieldSize,
        'filename': filename,
        'extraField': extraField,
        'offset': '$offsetStart - $offsetEnd',
      };
}

class ZipCentralDirectory extends ZipLocalFile {
  ZipCentralDirectory(int signature) : super(signature);
  int versionMade; // 2 bytes

  int commentLength; // 2 bytes
  int diskNumberStart; // 2 bytes
  int internalAttributes; // 2 bytes
  int externalAttributes; // 4 bytes
  int relativeOffset; // 4 bytes

  String comment;

  @override
  Future<void> _read(FileBuffer src) async {
    versionMade = await src.readUint16();
    await _readLocalFileBase(src);
    commentLength = await src.readUint16();
    diskNumberStart = await src.readUint16();
    internalAttributes = await src.readUint16();
    externalAttributes = await src.readUint32();
    relativeOffset = await src.readUint32();

    await _readLocalFileDynamic(src);
    comment = await src.readUtf8(commentLength);
  }

  @override
  Map<String, dynamic> toJson() => {
        'signature': signature.toRadixString(16).padLeft(4, '0'),
        'versionMade': versionMade,
        'versionToExtract': versionToExtract,
        'generalFlag': generalFlag.toRadixString(16).padLeft(4, '0'),
        'compressionMethod':
            compressionMethod.toRadixString(16).padLeft(4, '0'),
        'lastModTime': lastModTime.toRadixString(16).padLeft(4, '0'),
        'lastModDate': lastModDate.toRadixString(16).padLeft(4, '0'),
        'crc32': crc32.toRadixString(16).padLeft(8, '0'),
        'compressedSize': compressedSize,
        'uncompressedSize': uncompressedSize,
        'filenameSize': filenameSize,
        'extraFieldSize': extraFieldSize,
        'commentLength': commentLength,
        'diskNumberStart': diskNumberStart,
        'internalAttributes':
            internalAttributes.toRadixString(16).padLeft(4, '0'),
        'externalAttributes':
            externalAttributes.toRadixString(16).padLeft(8, '0'),
        'relativeOffset': relativeOffset,
        'filename': filename,
        'extraField': extraField,
        'comment': comment,
        'offset': '$offsetStart - $offsetEnd',
      };
}

class ZipEndCentralDirectory extends ZipHeader implements JSONable {
  ZipEndCentralDirectory(int signature) : super(signature);

  int numberOfDisk; // 2 bytes
  int numberOfDiskWithCentralDirectory; // 2 bytes
  int totalEntriesOfDisk; // 2 bytes
  int totalEntriesInCentralDirectory; // 2 bytes
  int centralDirectorySize; // 4 bytes
  int startOffset; // 4 bytes
  int commentLength; // 2 bytes

  String comment;

  @override
  Future<void> _read(FileBuffer src) async {
    numberOfDisk = await src.readUint16();
    numberOfDiskWithCentralDirectory = await src.readUint16();
    totalEntriesOfDisk = await src.readUint16();
    totalEntriesInCentralDirectory = await src.readUint16();
    centralDirectorySize = await src.readUint32();
    startOffset = await src.readUint32();
    commentLength = await src.readUint16();

    comment = await src.readUtf8(commentLength);
  }

  @override
  Map<String, dynamic> toJson() => {
        'numberOfDisk': numberOfDisk,
        'numberOfDiskWithCentralDirectory': numberOfDiskWithCentralDirectory,
        'totalEntriesOfDisk': totalEntriesOfDisk,
        'totalEntriesInCentralDirectory': totalEntriesInCentralDirectory,
        'centralDirectorySize': centralDirectorySize,
        'startOffset': startOffset,
        'commentLength': commentLength,
        'comment': comment,
      };
}
