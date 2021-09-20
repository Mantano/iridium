// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/publication.dart';

/// Container of a publication
///
/// @var rootFile : a RootFile class containing the path the publication, the version
///                 and the mime type of it
///
/// @var drm : contain the brand, scheme, profile and license of DRM if it exist
///
/// @func data : return the ByteArray content of a file from the publication
///
/// @func dataLength : return the length of content
///
/// @func dataInputStream : return the InputStream of content
abstract class Container {
  RootFile get rootFile;
  Drm? get drm;
}

class ContainerError implements Exception {
  ContainerError._();
  ContainerError.streamInitFailed();
  ContainerError.fileNotFound();
  ContainerError.fileError();
  static MissingFile missingFile(String path) => MissingFile._(path);
  static XmlParse xmlParse(Error underlyingError) =>
      XmlParse._(underlyingError);
  static MissingLink missingLink(String title) => MissingLink._(title);
}

class MissingFile extends ContainerError {
  final String path;

  MissingFile._(this.path) : super._();
}

class XmlParse extends ContainerError {
  final Error underlyingError;

  XmlParse._(this.underlyingError) : super._();
}

class MissingLink extends ContainerError {
  final String title;

  MissingLink._(this.title) : super._();
}
