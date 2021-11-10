// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';
import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/pdf.dart';
import 'package:model/model.dart';
import 'package:pdfium_ffi/pdfium.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:ui_commons/document_opener/document_opener.dart';
import 'package:ui_framework/widgets/tap_gesture.dart';
import 'package:navigator/src/book/ui/book_screen_state.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/model/readium_location.dart';
import 'package:navigator/src/pdf/server/pdf_page_request_handler.dart';
import 'package:navigator/src/pdf/ui/pdf_page_image.dart';

class PdfBookScreen extends BookScreen {
  const PdfBookScreen({
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
  State<StatefulWidget> createState() => PdfBookScreenState();
}

class PdfBookScreenState extends BookScreenState<PdfBookScreen> {
  static const double minScaleFactor = 0.999;
  static const double maxScaleFactor = 3.0;
  PreloadPageController _pageController;
  PdfDocument _pdfDocument;

  @override
  void jumpToPage(int page) => _pageController.jumpToPage(page);

  @override
  bool get pageControllerAttached => _pageController.hasClients;

  @override
  void initPageController(int initialPage) => _pageController =
      PreloadPageController(keepPage: true, initialPage: initialPage);

  @override
  Future<ReaderContext> readerContextFuture(BuildContext context) async =>
      super.readerContextFuture(context).then((readerContext) async {
        if (readerContext.publication != null) {
          Link pdfLink = readerContext.publication.readingOrder
              .firstWithMediaType(MediaType.pdf);
          if (pdfLink == null) {
            throw Exception("Unable to find PDF file.");
          }

          Resource pdfResource = readerContext.fetcher.get(pdfLink);
          _pdfDocument =
              await PdfiumDocumentFactory().openResource(pdfResource);
          // readerContext.book.nbPages = _pdfDocument.pageCount;
        }
        return readerContext;
      });

  @override
  void onPrevious() => _pageController.previousPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

  @override
  void onNext() => _pageController.nextPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

  @override
  List<RequestHandler> get handlers => [PdfPageRequestHandler(_pdfDocument)];

  @override
  void onPageChanged(int position) {
    super.onPageChanged(position);
    List<Link> spine = readerContext.publication.pageLinks;
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
          "spineItemIndex": position
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
        onTap: _onTap,
        child: PreloadPageView.builder(
          controller: _pageController,
          preloadPagesCount: 1,
          itemBuilder: (BuildContext context, int index) => PdfPageImage(
            pdfDocument: _pdfDocument,
            state: serverState,
            link: spine[index],
            pageIndex: index,
            partialModeEnabled: !readerContext.simplifiedMode,
          ),
          itemCount: _pdfDocument.pageCount,
          onPageChanged: onPageChanged,
        ),
      );

  @override
  void dispose() {
    super.dispose();
    _pdfDocument?.close();
  }

  void _onTap() => readerContext.onTap();
}
