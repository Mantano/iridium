// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/foundation.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/css/reader_theme.dart';
import 'package:model/model.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/epub/bloc/snapshotting_bloc.dart';
import 'package:navigator/src/epub/settings/viewer_settings.dart';

class ThumbnailsGeneratorConfig {
  final SnapshottingBloc snapshottingBloc;
  final ReaderContext readerContext;
  final String address;
  final int requestId;
  final int width;
  final int height;
  final ReaderTheme readerTheme;
  final ViewerSettings viewerSettings;

  const ThumbnailsGeneratorConfig({
    @required this.snapshottingBloc,
    @required this.readerContext,
    @required this.address,
    @required this.requestId,
    @required this.width,
    @required this.height,
    @required this.readerTheme,
    @required this.viewerSettings,
  })  : assert(snapshottingBloc != null),
        assert(readerContext != null),
        assert(address != null),
        assert(requestId != null),
        assert(width != null),
        assert(height != null),
        assert(readerTheme != null),
        assert(viewerSettings != null);

  Book get book => readerContext.book;

  Publication get publication => readerContext.publication;

  bool get isCurrentGenerationNeeded => snapshottingBloc.requestId == requestId;

  @override
  String toString() =>
      'SnapshottingThumbnailsGenerator{snapshottingBloc: $snapshottingBloc, '
      'readerContext: $readerContext, '
      'address: $address, '
      'requestId: $requestId, '
      'width: $width, '
      'height: $height, '
      'readerTheme: $readerTheme, '
      'viewerSettings: $viewerSettings}';
}
