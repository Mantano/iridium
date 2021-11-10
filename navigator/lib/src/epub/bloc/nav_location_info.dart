// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:collection/collection.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';

class NavLocationInfo {
  final PaginationInfo paginationInfo;

  NavLocationInfo(this.paginationInfo);

  int get positionSpineItemPageIndex =>
      (paginationInfo != null && paginationInfo.openPages.isNotEmpty)
          ? paginationInfo.openPages[0].spineItemPageIndex
          : 0;

  int get positionSpineItemIndex =>
      (paginationInfo != null && paginationInfo.openPages.isNotEmpty)
          ? paginationInfo.openPages[0].spineItemIndex
          : 0;

  Map<String, int> get elementIdsWithPageIndex =>
      (paginationInfo != null) ? paginationInfo.elementIdsWithPageIndex : {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavLocationInfo &&
          runtimeType == other.runtimeType &&
          positionSpineItemPageIndex == other.positionSpineItemPageIndex &&
          positionSpineItemIndex == other.positionSpineItemIndex &&
          const MapEquality()
              .equals(elementIdsWithPageIndex, other.elementIdsWithPageIndex);

  @override
  int get hashCode =>
      positionSpineItemPageIndex.hashCode ^
      positionSpineItemIndex.hashCode ^
      elementIdsWithPageIndex.hashCode;

  @override
  String toString() =>
      'NavLocationInfo{ positionSpineItemPageIndex: $positionSpineItemPageIndex, '
      'positionSpineItemIndex: $positionSpineItemIndex, '
      'elementIdsWithPageIndex: $elementIdsWithPageIndex }';
}
