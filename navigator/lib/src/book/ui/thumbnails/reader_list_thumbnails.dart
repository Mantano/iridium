// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/widgets.dart';
import 'package:mno_server/mno_server.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_layout_thumbnails.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_thumbnail_config.dart';

class ReaderListThumbnails extends ReaderLayoutThumbnails {
  final bool visible;

  const ReaderListThumbnails({
    Key key,
    this.visible,
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
  State<StatefulWidget> createState() => ReaderListThumbnailsState();
}

class ReaderListThumbnailsState
    extends ReaderLayoutThumbnailsState<ReaderListThumbnails> {
  bool get visible => widget.visible;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: readerThumbnailConfig.thumbnailListHeight,
        child: ListView.builder(
          itemExtent: itemWidthWithPadding,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
              left: itemPadding, bottom: itemPadding, top: itemPadding),
          itemBuilder: (BuildContext context, int index) =>
              buildItem(context, index, visible),
          itemCount: nbPages,
          controller: scrollController,
        ),
      );
}
