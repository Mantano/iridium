// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mno_shared/publication.dart';
import 'package:navigator/src/epub/bloc/spine_item_pagination.dart';

class ThumbnailContext {
  static const int nbPageFinishedToFullyLoaded = 2;
  final int spineItemIndex;
  final Link link;
  final String address;
  final Set<SpineItemPagination> spineItemPaginations;
  final Completer<SpineItemPagination> completer;
  int nbCallToPageFinished;

  ThumbnailContext(
      this.spineItemIndex, this.link, this.address, this.spineItemPaginations)
      : completer = Completer(),
        nbCallToPageFinished = nbPageFinishedToFullyLoaded;

  void onPageFinished() => nbCallToPageFinished--;

  bool get isFullyLoaded => nbCallToPageFinished <= 0;

  URLRequest get urlRequest => URLRequest(url: Uri.parse(url));

  String get url => '$address/${link.href}';

  int get sectionFirstPage => spineItemPaginations
      .where((sip) => sip.spineItemId < spineItemIndex)
      .fold(0, (previousValue, element) => previousValue + element.nbPages);

  void complete(SpineItemPagination spineItemPagination) =>
      completer.complete(spineItemPagination);

  Future<SpineItemPagination> get future => completer.future;

  @override
  String toString() =>
      'ThumbnailContext{spineItemIndex: $spineItemIndex, link: $link}';
}
