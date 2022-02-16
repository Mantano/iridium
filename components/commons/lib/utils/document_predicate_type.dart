// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class DocumentPredicateType {
  static const DocumentPredicateType customId =
          DocumentPredicateType._(0, "customId"),
      entityId = DocumentPredicateType._(1, "id"),
      documentId = DocumentPredicateType._(2, "documentId"),
      attachmentsId = DocumentPredicateType._(3, "attachments.documentId");

  static const List<DocumentPredicateType> _values = [
    customId,
    entityId,
    documentId,
    attachmentsId,
  ];

  final int id;
  final String name;

  // FOLLOWING Firestore Documentation https://firebase.google.com/docs/firestore/query-data/queries

  const DocumentPredicateType._(this.id, this.name);

  static DocumentPredicateType from(int id) =>
      _values.firstWhere((type) => type.id == id);

  @override
  String toString() => 'DocumentPredicateType.$name';
}
