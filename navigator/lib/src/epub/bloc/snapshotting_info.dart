// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:equatable/equatable.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:model/css/reader_theme.dart';
import 'package:navigator/src/epub/bloc/spine_item_pagination.dart';

class SnapshottingInfo with EquatableMixin implements JSONable {
  final int width;
  final int height;
  final int fontSize;
  final ReaderTheme readerTheme;
  final List<SpineItemPagination> spineItemPaginations;

  SnapshottingInfo(this.width, this.height, this.fontSize, this.readerTheme,
      this.spineItemPaginations)
      : assert(width != null),
        assert(height != null),
        assert(fontSize != null),
        assert(readerTheme != null),
        assert(spineItemPaginations != null);

  int get nbThumbnails =>
      spineItemPaginations.fold(0, (prev, element) => prev + element.nbPages);

  bool matchConditions(
          int width, int height, int fontSize, ReaderTheme readerTheme) =>
      this.width == width &&
      this.height == height &&
      this.fontSize == fontSize &&
      this.readerTheme.backgroundColor == readerTheme.backgroundColor &&
      this.readerTheme.textColor == readerTheme.textColor &&
      this.readerTheme.textAlign?.name == readerTheme.textAlign?.name &&
      this.readerTheme.lineHeight?.value == readerTheme.lineHeight?.value &&
      this.readerTheme.textMargin?.value == readerTheme.textMargin?.value;

  @override
  Map<String, dynamic> toJson() => {
        "width": width,
        "height": height,
        "fontSize": fontSize,
        "readerTheme": readerTheme.toJson(),
        "spineItemPaginations": spineItemPaginations.toJson(),
      };

  @override
  List<Object> get props => [
        width,
        height,
        fontSize,
        readerTheme,
      ];

  factory SnapshottingInfo.fromJson(Map<String, Object> data) {
    Map<String, Object> readerThemeJson = data['readerTheme'];
    List<dynamic> spineItemPaginationsJson = data['spineItemPaginations'];
    List<SpineItemPagination> spineItemPaginations = spineItemPaginationsJson
        .map((json) => SpineItemPagination.fromJson(json))
        .toList();
    return SnapshottingInfo(
      data['width'] as int,
      data['height'] as int,
      data['fontSize'] as int,
      ReaderTheme.readFromJson(readerThemeJson),
      spineItemPaginations,
    );
  }

  SpineItemPagination findSpineItemPagination(int thumbnailIndex) =>
      spineItemPaginations.firstWhere(
          (e) => e.firstPage <= thumbnailIndex && e.lastPage >= thumbnailIndex,
          orElse: () => null);

  @override
  String toString() =>
      'SnapshottingInfo{width: $width, height: $height, fontSize: $fontSize, '
      'readerTheme: $readerTheme, spineItemPaginations: $spineItemPaginations}';
}
