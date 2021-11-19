// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

abstract class ReaderAnnotationRepository {
  final StreamController<List<String>> _deletedIdsController;

  ReaderAnnotationRepository()
      : this._deletedIdsController = StreamController.broadcast();

  Future<ReaderAnnotation> createReaderAnnotation(
      PaginationInfo paginationInfo);

  Future<void> delete(List<String> deletedIds);

  Future<List<ReaderAnnotation>> allWhere({
    Predicate predicate = Predicate.acceptAll,
  });

  void notifyDeletedIds(List<String> deletedIds) =>
      _deletedIdsController.add(deletedIds);

  Stream<List<String>> get deletedIdsStream => _deletedIdsController.stream;
}
