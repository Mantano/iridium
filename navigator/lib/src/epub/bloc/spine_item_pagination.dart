// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:mno_commons/utils/jsonable.dart';

class SpineItemPagination implements JSONable {
  final int spineItemId;
  final int nbPages;
  final int firstPage;

  SpineItemPagination(this.spineItemId, this.nbPages, this.firstPage);

  int get lastPage => firstPage + nbPages - 1;

  @override
  Map<String, dynamic> toJson() => {
        "spineItemId": spineItemId,
        "nbPages": nbPages,
        "firstPage": firstPage,
      };

  factory SpineItemPagination.fromJson(Map<String, Object> data) =>
      SpineItemPagination(
        data["spineItemId"] as int,
        data["nbPages"] as int,
        data["firstPage"] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpineItemPagination &&
          runtimeType == other.runtimeType &&
          spineItemId == other.spineItemId;

  @override
  int get hashCode => spineItemId.hashCode;

  @override
  String toString() =>
      'SpineItemPagination{spineItemId: $spineItemId, nbPages: $nbPages, '
      'firstPage: $firstPage, lastPage: $lastPage}';
}
