// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:mno_commons/utils/jsonable.dart';

class ScreenshotConfig implements JSONable {
  final int nbThumbnails;

  ScreenshotConfig(this.nbThumbnails);

  @override
  Map<String, dynamic> toJson() => {
        "nbThumbnails": nbThumbnails,
      };

  @override
  String toString() => 'ScreenshotConfig{nbThumbnails: $nbThumbnails}';
}
