// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:ui_commons/document_opener/document_opener.dart';
import 'package:ui_framework/widgets/tap_gesture.dart';
import 'package:navigator/src/book/ui/book_screen_state.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/model/readium_location.dart';

class CbzBookScreen extends BookScreen {
  const CbzBookScreen({
    Key key,
    @required Book book,
    @required bool simplifiedMode,
    @required OnCloseDocument onCloseDocument,
  }) : super(
            key: key,
            book: book,
            simplifiedMode: simplifiedMode,
            onCloseDocument: onCloseDocument);

  @override
  State<StatefulWidget> createState() => CbzBookScreenState();
}

class CbzBookScreenState extends BookScreenState<CbzBookScreen> {
  static const double minScaleFactor = 0.999;
  static const double maxScaleFactor = 3.0;
  PageController _pageController;

  @override
  void jumpToPage(int page) => _pageController.jumpToPage(page);

  @override
  bool get pageControllerAttached => _pageController.hasClients;

  @override
  void initPageController(int initialPage) => _pageController =
      PageController(keepPage: true, initialPage: initialPage);

  @override
  void onPrevious() => _pageController.previousPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

  @override
  void onNext() => _pageController.nextPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

  @override
  List<RequestHandler> get handlers =>
      [FetcherRequestHandler(readerContext.publication)];

  @override
  void onPageChanged(int position) {
    super.onPageChanged(position);
    List<Link> spine = readerContext.publication.readingOrder;
    Link spineItem = spine[position];
    LinkPagination linkPagination =
        readerContext.publication.paginationInfo[spineItem];
    Map data = {
      "spineItem": {
        "idref": spineItem.href,
        "href": spineItem.href,
      },
      "location": {
        "version": ReadiumLocation.currentVersion,
        "idref": spineItem.href,
      },
      "openPages": [
        {
          "spineItemPageIndex": 0,
          "spineItemPageCount": 1,
          "idref": spineItem.href,
          "spineItemIndex": position,
        },
      ],
    };
    String json = const JsonCodec().encode(data);
    try {
      PaginationInfo paginationInfo =
          PaginationInfo.fromJson(json, linkPagination);
      readerContext.notifyCurrentLocation(paginationInfo, spineItem);
    } catch (e, stacktrace) {
      Fimber.d("error: $e", ex: e, stacktrace: stacktrace);
    }
  }

  @override
  Widget buildReaderView(List<Link> spine, ServerStarted serverState) =>
      TapGesture(
        onTap: onTap,
        child: PhotoViewGallery.builder(
          pageController: _pageController,
          builder: (BuildContext context, int index) =>
              _buildItem(spine[index], serverState),
          itemCount: spine.length,
          loadingBuilder: (context, event) => buildProgressIndicator(context),
          backgroundDecoration: const BoxDecoration(
            image: DecorationImage(
              repeat: ImageRepeat.repeat,
              scale: 0.5,
              image: AssetImage(
                'img/blank_tile.png',
                package: 'ui_commons',
              ),
            ),
          ),
          onPageChanged: onPageChanged,
        ),
      );

  PhotoViewGalleryPageOptions _buildItem(Link link, ServerStarted state) =>
      PhotoViewGalleryPageOptions(
        gestureDetectorBehavior: HitTestBehavior.translucent,
        imageProvider: NetworkImage('${state.address}/${link.href}'),
        initialScale: PhotoViewComputedScale.contained * minScaleFactor,
        heroAttributes: PhotoViewHeroAttributes(tag: link.href),
        minScale: PhotoViewComputedScale.contained * minScaleFactor,
        maxScale: PhotoViewComputedScale.contained * maxScaleFactor,
      );

  void onTap() => readerContext.onTap();
}
