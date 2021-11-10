// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:ui_framework/styles/common_sizes.dart';

class ReaderThumbnailConfig {
  final double itemWidth;
  final double itemHeight;
  final double itemPadding;

  ReaderThumbnailConfig({
    this.itemWidth = 100.0,
    this.itemHeight = 150.0,
    this.itemPadding = CommonSizes.small1Margin,
  });

  double get itemWidthWithPadding => itemWidth + itemPadding;

  double get thumbnailListHeight => itemHeight + 3 * itemPadding;
}
