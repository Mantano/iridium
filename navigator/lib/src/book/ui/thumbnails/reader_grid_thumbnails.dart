// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mno_server/mno_server.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_layout_thumbnails.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_thumbnail_config.dart';

class ReaderGridThumbnails extends ReaderLayoutThumbnails {
  final Stream<bool> visibilityGridStream;
  final double gridItemPadding;

  const ReaderGridThumbnails({
    Key key,
    this.visibilityGridStream,
    this.gridItemPadding = CommonSizes.small1Margin,
    ScrollController scrollController,
    ReaderThumbnailConfig readerThumbnailConfig,
    ReaderContext readerContext,
    ServerBloc serverBloc,
  }) : super(
          key: key,
          scrollController: scrollController,
          readerThumbnailConfig: readerThumbnailConfig,
          readerContext: readerContext,
          serverBloc: serverBloc,
        );

  @override
  State<StatefulWidget> createState() => ReaderGridThumbnailsState();
}

class ReaderGridThumbnailsState
    extends ReaderLayoutThumbnailsState<ReaderGridThumbnails> {
  Stream<bool> get visibilityGridStream => widget.visibilityGridStream;

  double get gridItemPadding => widget.gridItemPadding;

  int get columns =>
      (MediaQuery.of(context).size.width / readerThumbnailConfig.itemWidth)
          .floor();

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
      stream: visibilityGridStream,
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) =>
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: gridItemPadding,
              mainAxisSpacing: gridItemPadding,
            ),
            padding: EdgeInsets.all(gridItemPadding * 1.6),
            itemBuilder: (BuildContext context, int index) =>
                buildItem(context, index, snapshot.data),
            itemCount: nbPages,
            controller: scrollController,
          ));
}
