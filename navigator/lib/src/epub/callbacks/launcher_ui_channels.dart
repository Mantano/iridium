// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:model/model.dart';
import 'package:navigator/src/epub/callbacks/javascript_channels.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/js/xpub_js_api.dart';
import 'package:navigator/src/epub/model/open_page_request.dart';
import 'package:navigator/src/epub/widget/spine_item_context.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LauncherUIChannels extends JavascriptChannels {
  final SpineItemContext _spineItemContext;
  final AnnotationsBloc _annotationsBloc;
  JsApi jsApi;

  LauncherUIChannels(this._spineItemContext, this._annotationsBloc);

  @override
  List<JavascriptChannel> get channels => [
        JavascriptChannel(
          name: "LauncherUIOnPaginationChanged",
          onMessageReceived: _onPaginationChanged,
        ),
        JavascriptChannel(
          name: "LauncherUIOnToggleBookmark",
          onMessageReceived: _onToggleBookmark,
        ),
        JavascriptChannel(
          name: "LauncherUIContentRefUrlsPageComputed",
          onMessageReceived: _contentRefUrlsPageComputed,
        ),
        JavascriptChannel(
          name: "LauncherUIImageZoomed",
          onMessageReceived: _imageZoomed,
        ),
        JavascriptChannel(
          name: "LauncherUIOpenSpineItemForTts",
          onMessageReceived: _openSpineItemForTts,
        ),
      ];

  void _onPaginationChanged(JavascriptMessage message) {
    // Fimber.d("onPaginationChanged: ${message.message}");
    try {
      PaginationInfo paginationInfo = PaginationInfo.fromJson(
          message.message, _spineItemContext.linkPagination);
      _spineItemContext.notifyPaginationInfo(paginationInfo);
    } on dynamic catch (e, stacktrace) {
      Fimber.d("onPaginationChanged error: $e, $stacktrace",
          ex: e, stacktrace: stacktrace);
    }
  }

  void _onToggleBookmark(JavascriptMessage message) {
    // Fimber.d("onToggleBookmark: ${message.message}");
    try {
      PaginationInfo paginationInfo = PaginationInfo.fromJson(
          message.message, _spineItemContext.linkPagination);
      if (paginationInfo.pageBookmarks.isNotEmpty) {
        _annotationsBloc?.documentRepository
            ?.delete(paginationInfo.pageBookmarks)
            ?.then((_) => jsApi.removeBookmark(paginationInfo));
      } else {
        Book book = _spineItemContext.book;
        Annotation annotation = Annotation.bookmark(
            paginationInfo.getString('text'),
            book.id,
            paginationInfo.location.json,
            paginationInfo.page,
            null);
        _annotationsBloc?.documentRepository?.add(annotation,
            continuation: () => jsApi.addBookmark(annotation));
      }
    } on dynamic catch (e, stacktrace) {
      Fimber.d("onToggleBookmark error: $e, $stacktrace",
          ex: e, stacktrace: stacktrace);
    }
  }

  void _contentRefUrlsPageComputed(JavascriptMessage message) {
//    Fimber.d("contentRefUrlsPageComputed: ${message.message}");
    Map<String, dynamic> jsonMap = const JsonCodec().decode(message.message);
    Map<String, int> result =
        jsonMap.map((String key, dynamic value) => MapEntry(key, value as int));
    Fimber.d("contentRefUrlsPageComputed, result: $result");
  }

  void _imageZoomed(JavascriptMessage message) {
//    Fimber.d("imageZoomed, url: ${message.message}");
  }

  void _openSpineItemForTts(JavascriptMessage message) {
//    Fimber.d("openSpineItemForTts: ${message.message}");
    Map<String, dynamic> result = const JsonCodec().decode(message.message);
    String idref = result["idref"];
    bool lastPage = result["lastPage"] == true.toString();
    OpenPageRequest request =
        OpenPageRequest.fromIdrefAndLastPageWithTts(idref, lastPage: lastPage);
    Fimber.d("openSpineItemForTts, request: $request");
  }
}
