// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:flutter/services.dart';
import 'package:r2_commons_dart/extensions/data.dart';
import 'package:r2_commons_dart/extensions/strings.dart';
import 'package:r2_commons_dart/utils/exceptions.dart';
import 'package:r2_shared_dart/archive.dart';
import 'package:r2_shared_dart/publication.dart';
import 'package:r2_shared_dart/streams.dart';
import 'package:xml/xml.dart';

import 'mediatype.dart';
import 'sniffer_content.dart';

/// A companion type of [Format.Sniffer] holding the type hints (file extensions, media types) and
/// providing an access to the file content.
///
/// @param mediaTypes Media type hints.
/// @param fileExtensions File extension hints.
class SnifferContext {
  static const String charsetUtf8 = "utf-8";
  final SnifferContent content;
  final List<String> fileExtensions;
  final List<MediaType> mediaTypes;

  SnifferContext({
    this.content,
    List<String> mediaTypes = const [],
    List<String> fileExtensions = const [],
  })  : mediaTypes =
            mediaTypes.mapNotNull((it) => MediaType.parse(it)).toList(),
        fileExtensions = fileExtensions.map((it) => it.toLowerCase()).toList();

  // Metadata

  /// Finds the first [Charset] declared in the media types' `charset` parameter.
  String get charset => mediaTypes.mapNotNull((it) => it.charset).firstOrNull;

  /// Returns whether this context has any of the given file extensions, ignoring case. */
  bool hasFileExtension(List<String> fileExtensions) =>
      fileExtensions.any((fileExtension) =>
          this.fileExtensions.contains(fileExtension.toLowerCase()));

  /// Returns whether this context has the given media type, ignoring case and extra
  /// parameters.
  ///
  /// Implementation note: Use [MediaType] to handle the comparison to avoid edge cases.
  bool hasMediaType(String mediaType) => hasAnyOfMediaTypes([mediaType]);

  /// Returns whether this context has any of the given media type, ignoring case and extra
  /// parameters.
  ///
  /// Implementation note: Use [MediaType] to handle the comparison to avoid edge cases.
  bool hasAnyOfMediaTypes(List<String> mediaTypesList) {
    Iterable<MediaType> mediaTypes = mediaTypesList.map(MediaType.parse);
    return mediaTypes
        .any((mediaType) => this.mediaTypes.any(mediaType.contains));
  }

  // Content

  bool _loadedContentAsString = false;
  String _contentAsString;

  /// Content as plain text.
  ///
  /// It will extract the charset parameter from the media type hints to figure out an encoding.
  /// Otherwise, fallback on UTF-8.
  Future<String> contentAsString() async {
    if (!_loadedContentAsString) {
      _loadedContentAsString = true;
      Encoding encoding = Encoding.getByName(charset ?? charsetUtf8) ?? utf8;
      Stream<List<int>> _stream = await stream();
      _contentAsString =
          await _stream?.let((it) async => await encoding.decodeStream(it));
    }
    return _contentAsString;
  }

  bool loadedContentAsXml = false;
  XmlElement _contentAsXml;

  /// Content as an XML document.
  Future<XmlElement> contentAsXml() async {
    if (!loadedContentAsXml) {
      loadedContentAsXml = true;
      try {
        _contentAsXml = await contentAsString()
            ?.then((it) => it?.let((string) => XmlDocument.parse(string)))
            ?.then((document) => document?.firstElementChild);
      } on Exception {
        _contentAsXml = null;
      }
    }

    return _contentAsXml;
  }

  /// Content as an Archive instance.
  /// Warning: Archive is only supported for a local file, for now.
  Future<Archive> contentAsArchive() async {
    if (!loadedContentAsArchive) {
      loadedContentAsArchive = true;
      _contentAsArchive = await (content as SnifferFileContent)
          ?.let((it) => DefaultArchiveFactory().open(it.file, null));
    }
    return _contentAsArchive;
  }

  bool loadedContentAsArchive = false;
  Archive _contentAsArchive;

  /// Content parsed from JSON.
  Future<Map<String, dynamic>> contentAsJson() async {
    try {
      return (await contentAsString())?.let((it) => it.toJsonOrNull());
    } on Exception {
      return null;
    }
  }

  /// Readium Web Publication Manifest parsed from the content. */
  Future<Manifest> contentAsRwpm() async =>
      Manifest.fromJSON(await contentAsJson());

  /// Returns whether the content is a JSON object containing all of the given root keys.
  Future<bool> containsJsonKeys(List<String> keys) async {
    Map<String, dynamic> json = await contentAsJson();
    if (json == null) {
      return false;
    }
    return json.keys.toSet().containsAll(keys);
  }

  /// Returns whether an Archive entry exists in this file.
  Future<bool> containsArchiveEntryAt(String path) async =>
      await waitTryOrNull(
          () async => (await contentAsArchive())?.entry(path)) !=
      null;

  /// Returns the Archive entry data at the given [path] in this file.
  Future<ByteData> readArchiveEntryAt(String path) async {
    Archive archive = await contentAsArchive();
    if (archive == null) {
      return null;
    }

    return waitTryOrNull(() async {
      ArchiveEntry entry = await archive.entry(path);
      ByteData bytes = await entry.read();
      await entry.close();
      return bytes;
    });
  }

  /// Raw bytes stream of the content.
  ///
  /// A byte stream can be useful when sniffers only need to read a few bytes at the beginning of
  /// the file.
  Future<Stream<List<int>>> stream() => content?.stream();

  /// Reads all the bytes or the given [range].
  ///
  /// It can be used to check a file signature, aka magic number.
  /// See https://en.wikipedia.org/wiki/List_of_file_signatures
  Future<ByteData> read({IntRange range}) => waitTryOrNull(() async => stream()
      ?.letAsync((stream) async => RawDataStream(await stream.first)
          .readData(start: range?.start, length: range?.length)
          .then((data) => data.toByteData())));

  /// Returns whether all the Archive entry paths satisfy the given `predicate`.
  Future<bool> archiveEntriesAllSatisfy(
          bool Function(ArchiveEntry) predicate) =>
      waitTryOr(
          false,
          () async => (await contentAsArchive())
              ?.entries()
              ?.then((entries) => entries.all(predicate) == true));
}
