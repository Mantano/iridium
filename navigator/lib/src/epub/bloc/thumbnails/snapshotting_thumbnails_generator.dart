// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:fimber/fimber.dart';
import 'package:navigator/src/epub/bloc/thumbnails/thumbnails_generator_config.dart';
import 'package:navigator/src/epub/bloc/snapshotting_bloc.dart';
import 'package:navigator/src/epub/bloc/snapshotting_info.dart';
import 'package:navigator/src/epub/bloc/spine_item_pagination.dart';
import 'package:navigator/src/epub/bloc/thumbnails/headless_web_view_thumbnails_generator.dart';
import 'package:navigator/src/epub/bloc/thumbnails/thumbnail_context.dart';
import 'package:navigator/src/epub/bloc/thumbnails/thumbnails_generator_config.dart';

import 'headless_web_view_thumbnails_generator.dart';

export 'thumbnails_generator_config.dart';

class SnapshottingThumbnailsGenerator {
  final ThumbnailsGeneratorConfig config;

  const SnapshottingThumbnailsGenerator(this.config);

  void generateThumbnails() async {
    HeadlessWebViewThumbnailsGenerator generator =
        HeadlessWebViewThumbnailsGenerator(config);
    Set<SpineItemPagination> spineItemPaginations = <SpineItemPagination>{};
    DateTime start = DateTime.now();
    for (int spineItemIndex = 0;
        spineItemIndex < config.publication.readingOrder.length;
        spineItemIndex++) {
      SpineItemPagination spineItemPagination =
          await generator.generateSpineItem(ThumbnailContext(
              spineItemIndex,
              config.publication.readingOrder[spineItemIndex],
              config.address,
              spineItemPaginations));
      if (spineItemPagination != null) {
        spineItemPaginations.add(spineItemPagination);
      }
      if (!config.isCurrentGenerationNeeded) {
        break;
      }
    }
    generator.dispose();
    DateTime end = DateTime.now();
    Duration duration = end.difference(start);
    Fimber.d("duration: $duration");
    if (config.isCurrentGenerationNeeded) {
      _notifySnapshottingEnded(spineItemPaginations);
    }
  }

  void _notifySnapshottingEnded(
          Set<SpineItemPagination> spineItemPaginations) =>
      config.snapshottingBloc.add(SnapshottingEndedEvent(SnapshottingInfo(
          config.width,
          config.height,
          config.viewerSettings.fontSize,
          config.readerTheme,
          spineItemPaginations.toList())));
}
