// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/model.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/js/xpub_js_api.dart';

class SpineItemContextWidget extends InheritedWidget {
  final SpineItemContext spineItemContext;

  const SpineItemContextWidget(
      {Key key, Widget child, @required this.spineItemContext})
      : assert(spineItemContext != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(SpineItemContextWidget oldWidget) =>
      spineItemContext != oldWidget.spineItemContext;
}

class SpineItemContext {
  final ReaderContext readerContext;
  final LinkPagination linkPagination;
  final StreamController<PaginationInfo> _paginationInfoStreamController =
      StreamController.broadcast();
  PaginationInfo currentPaginationInfo;
  JsApi jsApi;

  SpineItemContext(
      {@required this.readerContext, @required this.linkPagination})
      : assert(readerContext != null),
        assert(linkPagination != null);

  Book get book => readerContext.book;

  Publication get publication => readerContext.publication;

  Stream<PaginationInfo> get paginationInfoStream =>
      _paginationInfoStreamController.stream;

  static SpineItemContext of(BuildContext context) {
    SpineItemContextWidget readerContextWidget =
        context.dependOnInheritedWidgetOfExactType();
    return readerContextWidget?.spineItemContext;
  }

  void notifyPaginationInfo(PaginationInfo paginationInfo) {
    currentPaginationInfo = paginationInfo;
    if (!_paginationInfoStreamController.isClosed) {
      _paginationInfoStreamController.add(paginationInfo);
    }
  }

  void onTap() => readerContext.onTap();

  void dispose() => _paginationInfoStreamController.close();
}
