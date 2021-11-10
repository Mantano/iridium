// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/model.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/js/xpub_js_api.dart';
import 'package:navigator/src/epub/widget/spine_item_context.dart';

class BookmarkIcon extends StatefulWidget {
  const BookmarkIcon({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BookmarkIconState();
}

class BookmarkIconState extends State<BookmarkIcon> {
  @override
  Widget build(BuildContext context) {
    SpineItemContext spineItemContext = SpineItemContext.of(context);
    return StreamBuilder(
      stream: spineItemContext.paginationInfoStream,
      initialData: spineItemContext.currentPaginationInfo,
      builder: (BuildContext context, AsyncSnapshot<PaginationInfo> state) {
        bool visible =
            state.hasData ? state.data.pageBookmarks.isNotEmpty : false;
        return MaterialButton(
          padding: EdgeInsets.zero,
          minWidth: CommonSizes.large1IconSize,
          onPressed: () => _onBookmarkPressed(state.data),
          child: Opacity(
            opacity: visible ? 1.0 : 0.0,
            child: SvgAssets.bookmark.widget(
              color: DefaultColors.ratingFillColor,
              height: CommonSizes.large1IconSize,
            ),
          ),
        );
      },
    );
  }

  void _onBookmarkPressed(PaginationInfo paginationInfo) {
    SpineItemContext spineItemContext = SpineItemContext.of(context);
    AnnotationsBloc annotationsBloc = BlocProvider.of<AnnotationsBloc>(context);
    JsApi jsApi = spineItemContext.jsApi;
    if (paginationInfo != null) {
      if (paginationInfo.pageBookmarks.isNotEmpty) {
        annotationsBloc.documentRepository
            .delete(paginationInfo.pageBookmarks)
            .then((_) => jsApi.removeBookmark(paginationInfo));
      } else {
        Book book = spineItemContext.book;
        Annotation annotation = Annotation.bookmark("", book.id,
            paginationInfo.location.json, paginationInfo.page, null);
        annotationsBloc.documentRepository
            .add(annotation, continuation: () => jsApi.addBookmark(annotation));
      }
    }
  }
}
