// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/foundation.dart';
import 'package:model/model.dart';
import 'package:navigator/src/document/ui/drawer/reader_panel.dart';

abstract class AnnotationsPanel extends ReaderPanel {
  final AnnotationsBloc annotationsBloc;
  final AnnotationKind annotationKind;
  final Document document;

  const AnnotationsPanel(
      this.annotationsBloc, this.annotationKind, this.document,
      {Key key})
      : super(key: key);

  @override
  Future<bool> get display =>
      annotationsStream().first.then((list) => list.isNotEmpty);

  Stream<List<Annotation>> annotationsStream() =>
      annotationsBloc.documentRepository.allWhere(
          predicate:
              AnnotationKindAndDocumentPredicate(document.id, annotationKind));
}
