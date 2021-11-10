// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/widgets.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_thumbnail_config.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';

class IndexedScrollController extends ScrollController {
  final ReaderContext readerContext;
  final ReaderThumbnailConfig readerThumbnailConfig;
  final int maxIndex;

  IndexedScrollController({
    this.readerThumbnailConfig,
    this.readerContext,
    this.maxIndex,
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String debugLabel,
  }) : super(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        );

  double get listWidth => position.viewportDimension;

  double get minPosition => position.minScrollExtent;

  double get maxPosition => position.maxScrollExtent;

  int get currentIndex =>
      (1 + position.pixels / (maxPosition / (maxIndex - 1))).round();

  void jumpToIndex(int index) {
    if (hasClients) {
      int thumbnailIndex =
          readerContext.thumbnailsPageMapping.pageToThumbnailIndex(index);
      jumpTo(_computeScrollPosition(thumbnailIndex));
    }
  }

  void jumpToPaginationInfo(PaginationInfo paginationInfo) {
    if (hasClients) {
      int thumbnailIndex = readerContext.thumbnailsPageMapping
          .paginationInfoToThumbnailIndex(paginationInfo);
      jumpTo(_computeScrollPosition(thumbnailIndex));
    }
  }

  int findIndex(Offset localPosition) {
    double extent =
        localPosition.dx + position.pixels - readerThumbnailConfig.itemPadding;
    return (extent / readerThumbnailConfig.itemWidthWithPadding).floor();
  }

  double _computeScrollPosition(int page) {
    if (!hasClients) {
      return 0.0;
    }
    double itemPosition =
        (page - 1) * readerThumbnailConfig.itemWidthWithPadding;
    double position = itemPosition -
        (listWidth - readerThumbnailConfig.itemWidthWithPadding) / 2;
    return position.clamp(minPosition, maxPosition);
  }
}
