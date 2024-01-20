// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/jsonable.dart';

class EpubReaderState implements JSONable {
  final String? themeName;
  final int fontSize;
  final bool isTextInteractionEnabled;

  EpubReaderState(this.themeName, this.fontSize, this.isTextInteractionEnabled);

  factory EpubReaderState.fromJson(Map<String, dynamic> json) =>
      EpubReaderState(
          json["themeName"] as String?,
          json["fontSize"] as int? ?? 100,
          json["isTextInteractionEnabled"] as bool? ?? true);

  @override
  Map<String, dynamic> toJson() => {
        if (themeName != null) 'themeName': themeName!,
        'fontSize': fontSize,
        'isTextInteractionEnabled': isTextInteractionEnabled
      };

  @override
  String toString() =>
      'EpubReaderState{themeName: $themeName, fontSize: $fontSize, isTextInteractionEnabled: $isTextInteractionEnabled}';
}
