// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image/image.dart' as img;
import 'package:mno_shared/publication.dart';
import 'package:model/model.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/epub/bloc/thumbnails/snapshotting_thumbnails_generator.dart';
import 'package:navigator/src/epub/bloc/thumbnails/thumbnail_context.dart';
import 'package:navigator/src/epub/bloc/thumbnails/thumbnail_saving_info.dart';
import 'package:navigator/src/epub/callbacks/epub_callbacks.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/js/xpub_js_api.dart';
import 'package:navigator/src/epub/model/commands.dart';
import 'package:navigator/src/epub/model/open_page_request.dart';
import 'package:navigator/src/epub/settings/screenshot_config.dart';
import 'package:navigator/src/epub/settings/viewer_settings.dart';
import 'package:navigator/src/epub/widget/spine_item_context.dart';
import 'package:universal_io/io.dart';
import 'package:utils/io/folder_settings.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../spine_item_pagination.dart';

class HeadlessWebViewThumbnailsGenerator {
  static const int nbThumbnails = 8;
  final ThumbnailsGeneratorConfig config;
  HeadlessInAppWebView _webView;
  InAppWebViewController _controller;
  JsApi _jsApi;
  SpineItemContext _spineItemContext;
  StreamSubscription<PaginationInfo> _paginationInfoSubscription;
  ThumbnailContext thumbnailContext;

  HeadlessWebViewThumbnailsGenerator(this.config);

  ReaderContext get readerContext => config.readerContext;

  Book get book => config.book;

  Publication get publication => config.publication;

  bool get isCurrentGenerationNeeded => config.isCurrentGenerationNeeded;

  String get thumbnailsPath =>
      "${FolderSettings.instance.cachePath}/${book.id}";

  Size get initialSize =>
      Size(config.width.toDouble(), config.height.toDouble());

  void dispose() {
    _webView?.dispose();
    _spineItemContext?.dispose();
    _paginationInfoSubscription?.cancel();
    thumbnailContext = null;
  }

  Future<SpineItemPagination> generateSpineItem(
      ThumbnailContext thumbnailContext) {
    this.thumbnailContext = thumbnailContext;
    if (_webView == null) {
      _webView = createWebView();
      _webView.run();
    } else {
      _controller.loadUrl(urlRequest: thumbnailContext.urlRequest);
    }
    return this.thumbnailContext.future;
  }

  HeadlessInAppWebView createWebView() {
    LinkPagination linkPagination =
        publication.paginationInfo[thumbnailContext.link];
    _spineItemContext = SpineItemContext(
      readerContext: config.readerContext,
      linkPagination: linkPagination,
    );
    return buildWebView();
  }

  HeadlessInAppWebView buildWebView() => HeadlessInAppWebView(
        initialSize: initialSize,
        initialUrlRequest: thumbnailContext.urlRequest,
        onLoadStop: _onPageFinished,
        onWebViewCreated: _onWebViewCreated,
      );

  void _onPageFinished(InAppWebViewController controller, Uri uri) {
    // Fimber.d("_onPageFinished[${thumbnailContext.link.href}]: $uri");
    thumbnailContext.onPageFinished();
    if (!thumbnailContext.isFullyLoaded || !isCurrentGenerationNeeded) {
      return;
    }
    try {
      OpenPageRequest openPageRequestData =
          _getOpenPageRequestFromCommand(readerContext.readerCommand);
      // Fimber.d("openPageRequestData: $openPageRequestData");
      ViewerSettings settings = config.viewerSettings;
      // Fimber.d("settings: $settings");
      _jsApi.initSpineItem(
        publication,
        thumbnailContext.link,
        settings,
        openPageRequestData,
        <String>[],
        screenshotConfig: ScreenshotConfig(nbThumbnails),
      );
      _jsApi.setStyles(config.readerTheme, settings);
    } catch (e, stacktrace) {
      Fimber.d("_onPageFinished ERROR", ex: e, stacktrace: stacktrace);
    }
  }

  void _onWebViewCreated(InAppWebViewController webViewController) {
    // Fimber.d("_onWebViewCreated: $webViewController");
    _controller = webViewController;
    EpubCallbacks epubCallbacks = EpubCallbacks(_spineItemContext, null, null);
    // Fimber.d("epubCallbacks: $epubCallbacks");
    for (JavascriptChannel channel in epubCallbacks.channels) {
      _controller.addJavaScriptHandler(
          handlerName: channel.name,
          callback: (List<dynamic> arguments) => channel
              .onMessageReceived(JavascriptMessage(arguments[0].toString())));
    }
    _jsApi = JsApi(thumbnailContext.spineItemIndex,
        (javascript) => _controller.evaluateJavascript(source: javascript));
    _spineItemContext.jsApi = _jsApi;
    epubCallbacks.jsApi = _jsApi;
    _paginationInfoSubscription =
        _spineItemContext.paginationInfoStream.listen(_onPaginationInfo);
  }

  OpenPageRequest _getOpenPageRequestFromCommand(ReaderCommand command) {
    if (command != null &&
        command.spineItemIndex == thumbnailContext.spineItemIndex) {
      readerContext.readerCommand = null;
      return command.openPageRequest;
    }
    return null;
  }

  void _onPaginationInfo(PaginationInfo paginationInfo) {
    // Fimber.d("paginationInfo: $paginationInfo");
    Page page = paginationInfo.openPages.first;
    if (!thumbnailContext.isFullyLoaded || !isCurrentGenerationNeeded) {
      return;
    }
    int sectionFirstPage = thumbnailContext.sectionFirstPage;
    _controller.takeScreenshot().then((data) async {
      if (isCurrentGenerationNeeded) {
        return compute(
            saveThumbnails,
            ThumbnailSavingInfo(data, page, sectionFirstPage,
                thumbnailContext.spineItemIndex, thumbnailsPath));
      }
    }).whenComplete(() => _whenScreenshotComplete(page, sectionFirstPage));
  }

  static Future<void> saveThumbnails(
      ThumbnailSavingInfo thumbnailSavingInfo) async {
    img.Image image = img.decodePng(thumbnailSavingInfo.data);
    Size thumbnailSize =
        Size(image.width / nbThumbnails, image.height / nbThumbnails);
    for (int i = 0; i < nbThumbnails; i++) {
      bool shouldContinue = await _writeScreenshotInFile(
          thumbnailSavingInfo, image, i, thumbnailSize);
      if (!shouldContinue) {
        break;
      }
    }
  }

  static Future<bool> _writeScreenshotInFile(
      ThumbnailSavingInfo thumbnailSavingInfo,
      img.Image image,
      int i,
      Size thumbnailSize) async {
    int currentSectionPage =
        thumbnailSavingInfo.page.spineItemPageIndex * nbThumbnails + i;
    if (currentSectionPage >=
        thumbnailSavingInfo.page.spineItemPageThumbnailsCount) {
      return false;
    }
    img.Image thumbnail = img.copyCrop(image, (i * thumbnailSize.width).ceil(),
        0, thumbnailSize.width.ceil(), thumbnailSize.height.ceil());
    int pageId = thumbnailSavingInfo.sectionFirstPage + currentSectionPage;
    String path = '${thumbnailSavingInfo.thumbnailsPath}/page$pageId.png';
    File file = File(path);
    await file.writeAsBytes(img.encodePng(thumbnail, level: 9));
    // Fimber.d(
    //     "SCREEN[${thumbnailSavingInfo.spineItemIndex} / ${thumbnailSavingInfo.page.spineItemPageIndex}], generated $pageId");
    return true;
  }

  void _whenScreenshotComplete(Page page, int sectionFirstPage) {
    if (page.spineItemPageIndex == page.spineItemPageCount - 1) {
      thumbnailContext?.complete(SpineItemPagination(
          thumbnailContext.spineItemIndex,
          page.spineItemPageThumbnailsCount,
          sectionFirstPage));
    } else if (isCurrentGenerationNeeded) {
      _jsApi.gotoNextPage();
    }
  }
}
