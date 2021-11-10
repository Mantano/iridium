// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:model/model.dart';
import 'package:navigator/src/epub/model/readium_location.dart';

class AnnotationKindAndBookAndIdrefPredicate
    extends AnnotationKindAndDocumentPredicate {
  final String idref;

  AnnotationKindAndBookAndIdrefPredicate(
      this.idref, String documentId, AnnotationKind annotationKind)
      : assert(idref != null),
        super(documentId, annotationKind);

  @override
  bool test(Annotation element) {
    if (super.test(element)) {
      ReadiumLocation location =
          ReadiumLocation.createLocation(element.location);
      return location.idref == idref;
    }
    return false;
  }
}
