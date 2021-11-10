// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/epub.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_framework/styles/common_radius.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_thumbnail_config.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/pdf/ui/full_image_render.dart';

typedef OnItemTap = void Function(int index);

class ReaderThumbnailImage extends StatefulWidget {
  final bool visible;
  final int index;
  final OnItemTap onTap;
  final ReaderThumbnailConfig readerThumbnailConfig;
  final ReaderContext readerContext;
  final ServerBloc serverBloc;

  const ReaderThumbnailImage({
    Key key,
    this.visible,
    this.index,
    this.onTap,
    this.readerThumbnailConfig,
    this.readerContext,
    this.serverBloc,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReaderThumbnailImageState();
}

class ReaderThumbnailImageState extends State<ReaderThumbnailImage> {
  bool get visible => widget.visible;

  int get index => widget.index;

  OnItemTap get onTap => widget.onTap ?? (index) {};

  double get itemWidth => widget.readerThumbnailConfig.itemWidth;

  double get itemHeight => widget.readerThumbnailConfig.itemHeight;

  double get itemPadding => widget.readerThumbnailConfig.itemPadding;

  ReaderContext get readerContext => widget.readerContext;

  ServerBloc get serverBloc => widget.serverBloc;

  ThemeBloc get _themeBloc => BlocProvider.of<ThemeBloc>(context);

  @override
  Widget build(BuildContext context) => Visibility(
        visible: visible,
        replacement: SizedBox(
          width: itemWidth,
          height: itemHeight,
        ),
        child: GestureDetector(
          onTap: () => onTap(index),
          child: Padding(
            padding: EdgeInsets.only(right: itemPadding),
            child: StreamBuilder<PaginationInfo>(
                stream: readerContext.currentLocationStream,
                initialData: readerContext.paginationInfo,
                builder: (BuildContext context,
                    AsyncSnapshot<PaginationInfo> snapshot) {
                  bool isSelected = _isSelected(snapshot.data);
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      _buildFullImageRender(isSelected),
                      _buildPageNumber(context, _themeBloc, isSelected),
                      _buildCurrentPageHighlight(isSelected),
                    ],
                  );
                }),
          ),
        ),
      );

  bool _isSelected(PaginationInfo paginationInfo) {
    int thumbnailIndex = readerContext.thumbnailsPageMapping
        .paginationInfoToThumbnailIndex(paginationInfo);
    if (readerContext.epub) {
      return index == thumbnailIndex;
    }
    return index + 1 == thumbnailIndex;
  }

  Widget _buildFullImageRender(bool isSelected) => Material(
        elevation: (isSelected)
            ? CommonSizes.standardElevation
            : CommonSizes.smallElevation,
        borderRadius: BorderRadius.circular(CommonRadius.cardSmallRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CommonRadius.cardSmallRadius),
          child: FullImageRender(
            link: link,
            address: serverBloc.address,
            fit: BoxFit.cover,
            width: itemWidth,
            height: (isSelected) ? itemHeight * 1.1 : itemHeight,
          ),
        ),
      );

  Link get link {
    List<Link> pages = readerContext.publication.pageList;
    if (pages.isNotEmpty) {
      return pages[index];
    }
    pages = readerContext.publication.readingOrder;
    int versionId = readerContext.thumbnailsPageMapping.versionId;
    return Link(
      id: "thumbnail.png?page=$index",
      href: "xpub/thumbnail.png?page=$index&versionId=$versionId",
      type: MediaType.png.toString(),
      title: "page $index",
    );
  }

  Widget _buildPageNumber(
          BuildContext context, ThemeBloc themeBloc, bool isSelected) =>
      Container(
        color: (isSelected)
            ? themeBloc.currentTheme.secondaryColor.colorDark
            : themeBloc.currentTheme.primaryColor.colorDark,
        padding: CommonSizes.smallPadding,
        child: Text(
          (index + 1).toString(),
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
      );

// TODO : vérifier s'il faut supprimer ce code
  Widget _buildCurrentPageHighlight(bool isSelected) => AnimatedOpacity(
        opacity: (isSelected) ? 0.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: itemWidth,
          height: itemHeight,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: CommonSizes.borderWidth2,
            ),
          ),
        ),
      );
}
