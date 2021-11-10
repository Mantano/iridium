// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:mno_commons/utils/jsonable.dart';

class EpubReaderState implements JSONable {
  final String themeId;
  final int fontSize;

  EpubReaderState(this.themeId, this.fontSize);

  factory EpubReaderState.fromJson(Map<String, dynamic> json) =>
      EpubReaderState(json["themeId"], json["fontSize"] as int ?? 100);

  @override
  Map<String, dynamic> toJson() => {
        'themeId': themeId,
        'fontSize': fontSize,
      };

  @override
  String toString() =>
      'EpubReaderState{themeId: $themeId, fontSize: $fontSize}';
}
