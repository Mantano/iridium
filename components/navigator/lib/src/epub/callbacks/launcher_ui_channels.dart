// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class LauncherUIChannels extends JavascriptChannels {
  final SpineItemContext _spineItemContext;
  final ReaderAnnotationRepository? _bookmarkRepository;
  late JsApi jsApi;

  LauncherUIChannels(this._spineItemContext, this._bookmarkRepository);

  @override
  Map<String, JavaScriptHandlerCallback> get channels => {
        "LauncherUIOnPaginationChanged": _onPaginationChanged,
        "LauncherUIOnToggleBookmark": _onToggleBookmark,
        "LauncherUIContentRefUrlsPageComputed": _contentRefUrlsPageComputed,
        "LauncherUIImageZoomed": _imageZoomed,
        "LauncherUIOpenSpineItemForTts": _openSpineItemForTts,
      };

  void _onPaginationChanged(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
      // Fimber.d("onPaginationChanged: ${arguments.first}");
      try {
        PaginationInfo paginationInfo = PaginationInfo.fromJson(
            arguments.first, _spineItemContext.linkPagination);
        _spineItemContext.notifyPaginationInfo(paginationInfo);
      } on Object catch (e, stacktrace) {
        Fimber.d("onPaginationChanged error: $e, $stacktrace",
            ex: e, stacktrace: stacktrace);
      }
    }
  }

  void _onToggleBookmark(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
      // Fimber.d("onToggleBookmark: ${arguments.first}");
      try {
        PaginationInfo paginationInfo = PaginationInfo.fromJson(
            arguments.first, _spineItemContext.linkPagination);
        if (paginationInfo.pageBookmarks.isNotEmpty) {
          _bookmarkRepository?.delete(paginationInfo.pageBookmarks);
          jsApi.removeBookmark(paginationInfo);
        } else {
          _bookmarkRepository
              ?.createReaderAnnotation(paginationInfo)
              .then((ReaderAnnotation bookmark) => jsApi.addBookmark(bookmark));
        }
      } on Object catch (e, stacktrace) {
        Fimber.d("onToggleBookmark error: $e, $stacktrace",
            ex: e, stacktrace: stacktrace);
      }
    }
  }

  void _contentRefUrlsPageComputed(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
//    Fimber.d("contentRefUrlsPageComputed: ${arguments.first}");
      Map<String, dynamic> jsonMap = const JsonCodec().decode(arguments.first);
      Map<String, int> result = jsonMap
          .map((String key, dynamic value) => MapEntry(key, value as int));
      Fimber.d("contentRefUrlsPageComputed, result: $result");
    }
  }

  void _imageZoomed(List<dynamic> arguments) {
//    Fimber.d("imageZoomed, url: ${arguments.first}");
  }

  void _openSpineItemForTts(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
//    Fimber.d("openSpineItemForTts: ${arguments.first}");
      Map<String, dynamic> result = const JsonCodec().decode(arguments.first);
      String idref = result["idref"];
      bool lastPage = result["lastPage"] == true.toString();
      OpenPageRequest request = OpenPageRequest.fromIdrefAndLastPageWithTts(
          idref,
          lastPage: lastPage);
      Fimber.d("openSpineItemForTts, request: $request");
    }
  }
}
