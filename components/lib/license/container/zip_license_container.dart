// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mno_commons_dart/extensions/data.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_lcp_dart/lcp.dart';
import 'package:mno_lcp_dart/license/model/license_document.dart';
import 'package:mno_lcp_dart/utils/zip_utils.dart';
import 'package:mno_shared_dart/container.dart';
import 'package:mno_shared_dart/streams.dart';
import 'package:mno_shared_dart/zip.dart';
import 'package:universal_io/io.dart';

import 'license_container.dart';

class ZipLicenseContainer implements LicenseContainer {
  final String zip;
  final String pathInZIP;

  ZipLicenseContainer({this.zip, this.pathInZIP});

  @override
  Future<ByteData> read() async {
    ZipPackage archive;
    try {
      archive = await ZipContainer(zip).archive;
    } on Exception catch (e, stacktrace) {
      Fimber.e("ZipLicenseContainer.read ERROR", ex: e, stacktrace: stacktrace);
      throw LcpException.container.openFailed;
    }
    ZipLocalFile entry = archive.entries[pathInZIP];
    if (entry != null) {
      return ZipStream(archive, entry)
          .readData(start: 0, length: entry.uncompressedSize)
          .then((data) => data.toByteData())
          .onError((error, stackTrace) =>
              throw LcpException.container.readFailed(pathInZIP));
    } else {
      throw LcpException.container.fileNotFound(pathInZIP);
    }
  }

  @override
  Future<void> write(LicenseDocument license) async {
    try {
      ZipPackage zipPackage = await ZipPackage.fromArchive(File(zip));
      if (zipPackage.entries["META-INF/license.lcpl"] == null) {
        await ZipUtils.injectEntry(
            File(zip), ByteEntry(pathInZIP, license.data));
      }
    } on Exception {
      throw LcpException.container.writeFailed(pathInZIP);
    }
  }
}
