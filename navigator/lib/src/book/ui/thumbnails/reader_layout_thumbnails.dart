// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/widgets.dart';
import 'package:mno_server/mno_server.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_thumbnail_config.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_thumbnail_image.dart';
import 'package:navigator/src/epub/model/commands.dart';

abstract class ReaderLayoutThumbnails extends StatefulWidget {
  final ScrollController scrollController;
  final ReaderThumbnailConfig readerThumbnailConfig;
  final ReaderContext readerContext;
  final ServerBloc serverBloc;

  const ReaderLayoutThumbnails({
    Key key,
    this.scrollController,
    this.readerThumbnailConfig,
    this.readerContext,
    this.serverBloc,
  }) : super(key: key);
}

abstract class ReaderLayoutThumbnailsState<T extends ReaderLayoutThumbnails>
    extends State<T> {
  ScrollController get scrollController => widget.scrollController;

  ReaderContext get readerContext => widget.readerContext;

  ServerBloc get serverBloc => widget.serverBloc;

  int get nbPages => readerContext.thumbnailsPageMapping.nbThumbnails;

  ReaderThumbnailConfig get readerThumbnailConfig =>
      widget.readerThumbnailConfig;

  double get itemPadding => readerThumbnailConfig.itemPadding;

  double get itemWidthWithPadding => readerThumbnailConfig.itemWidthWithPadding;

  Widget buildItem(BuildContext context, int index, bool visible) =>
      ReaderThumbnailImage(
        visible: visible,
        index: index,
        onTap: _onTap,
        readerThumbnailConfig: readerThumbnailConfig,
        readerContext: readerContext,
        serverBloc: serverBloc,
      );

  void _onTap(int index) =>
      readerContext.execute(GoToThumbnailCommand(index + 1));
}
