// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class ReaderAnnotation {
  final String id;
  String location;
  String? annotation;
  HighlightStyle? style;
  int? tint;
  final AnnotationType annotationType;

  ReaderAnnotation(this.id, this.location, this.annotationType,
      {this.style, this.tint});

  ReaderAnnotation.locator(this.id, Locator locator, this.annotationType,
      {this.style, this.tint})
      : location = locator.json;

  Locator? get locator => Locator.fromJsonString(location);

  set locator(Locator? locator) => location = locator?.json ?? "{}";

  bool get isHighlight => annotationType == AnnotationType.highlight;

  bool get isBookmark => annotationType == AnnotationType.bookmark;

  @override
  String toString() => '$runtimeType{id: $id, '
      'location: $location, '
      'annotation: $annotation, '
      'style: $style, '
      'tint: $tint, '
      'annotationType: $annotationType}';
}
