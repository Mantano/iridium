// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/css/reader_theme.dart';
import 'package:model/model.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/epub/bloc/current_spine_item_bloc.dart';
import 'package:navigator/src/epub/bloc/reader_theme_bloc.dart';
import 'package:navigator/src/epub/bloc/viewer_settings_bloc.dart';
import 'package:navigator/src/epub/callbacks/epub_callbacks.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/js/xpub_js_api.dart';
import 'package:navigator/src/epub/model/annotation_kind_and_book_and_idref_predicate.dart';
import 'package:navigator/src/epub/model/commands.dart';
import 'package:navigator/src/epub/model/open_page_request.dart';
import 'package:navigator/src/epub/settings/viewer_settings.dart';
import 'package:navigator/src/epub/ui/listeners/web_view_horizontal_gesture_recognizer.dart';
import 'package:navigator/src/epub/ui/listeners/widget_keep_alive_listener.dart';
import 'package:navigator/src/epub/widget/spine_item_context.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final WidgetKeepAliveListener _widgetKeepAliveListener;
  final Book _book;
  final Publication _publication;
  final Link _link;
  final int _position;
  final String _address;

  WebViewScreen(
      {@required WidgetKeepAliveListener widgetKeepAliveListener,
      @required Book book,
      @required Publication publication,
      @required Link link,
      @required int position,
      @required String address})
      : assert(widgetKeepAliveListener != null &&
            book != null &&
            publication != null &&
            link != null &&
            position != null),
        _widgetKeepAliveListener = widgetKeepAliveListener,
        _book = book,
        _publication = publication,
        _link = link,
        _position = position,
        _address = address,
        super(key: PageStorageKey(link.id ?? link.href));

  @override
  State<StatefulWidget> createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  WebViewController _controller;
  JsApi _jsApi;
  AnnotationsBloc _annotationsBloc;
  ReaderThemeBloc _readerThemeBloc;
  ViewerSettingsBloc _viewerSettingsBloc;
  CurrentSpineItemBloc _currentSpineItemBloc;
  ReaderContext _readerContext;
  SpineItemContext _spineItemContext;
  StreamSubscription<DocumentsState> _annotationsSubscription;
  StreamSubscription<ReaderThemeState> _readerThemeSubscription;
  StreamSubscription<ViewerSettingsState> _viewerSettingsSubscription;
  StreamSubscription<CurrentSpineItemState> _currentSpineItemSubscription;
  StreamSubscription<ReaderCommand> _readerCommandSubscription;
  StreamSubscription<PaginationInfo> _paginationInfoSubscription;
  EpubCallbacks epubCallbacks;
  bool currentSelectedSpineItem;

  int get position => widget._position;

  Link get spineItem => widget._link;

  @override
  void initState() {
    super.initState();
    // See: https://medium.com/flutter-community/whats-new-in-inappwebview-5-null-safety-new-features-bug-fixes-11c9e2cadab2
    // "Use the new WebView Android-specific option useHybridComposition: true to enable Hybrid Composition.
    // This will improve a lot the performance of the WebView on Android, and, also,
    // will resolve all the problems related to the keyboard!
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
    widget._widgetKeepAliveListener.unregister(position);
    _spineItemContext?.dispose();
    _annotationsSubscription?.cancel();
    _readerThemeSubscription?.cancel();
    _viewerSettingsSubscription?.cancel();
    _currentSpineItemSubscription?.cancel();
    _readerCommandSubscription?.cancel();
    _paginationInfoSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    widget._widgetKeepAliveListener.register(position, this);
    currentSelectedSpineItem = false;
    _readerContext = ReaderContext.of(context);
    LinkPagination linkPagination =
        widget._publication.paginationInfo[spineItem];
    _spineItemContext = SpineItemContext(
      readerContext: _readerContext,
      linkPagination: linkPagination,
    );
    _annotationsBloc = BlocProvider.of<AnnotationsBloc>(context);
    _readerThemeBloc = BlocProvider.of<ReaderThemeBloc>(context);
    _viewerSettingsBloc = BlocProvider.of<ViewerSettingsBloc>(context);
    _currentSpineItemBloc = BlocProvider.of<CurrentSpineItemBloc>(context);
    epubCallbacks =
        EpubCallbacks(_spineItemContext, _viewerSettingsBloc, _annotationsBloc);
    return buildWebView(spineItem);
  }

  Widget buildWebView(Link link) {
    WebViewHorizontalGestureRecognizer webViewHorizontalGestureRecognizer =
        WebViewHorizontalGestureRecognizer(
      chapNumber: position,
      webView: widget,
    );
    epubCallbacks.webViewHorizontalGestureRecognizer =
        webViewHorizontalGestureRecognizer;
    return SpineItemContextWidget(
      spineItemContext: _spineItemContext,
      child: Stack(
        children: <Widget>[
          WebView(
            debuggingEnabled: !kReleaseMode,
            // debuggingEnabled: true,
            initialUrl: '${widget._address}/${link.href.removePrefix("/")}',
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: epubCallbacks.channels,
            navigationDelegate: _navigationDelegate,
            onPageFinished: _onPageFinished,
            gestureRecognizers: {
              Factory(() => webViewHorizontalGestureRecognizer),
            },
            onWebViewCreated: _onWebViewCreated,
          ),
//          Align(
//            child: BookmarkIcon(),
//            alignment: Alignment.topRight,
//          ),
        ],
      ),
    );
  }

//  @override
//  bool get wantKeepAlive {
//    int position = position;
//    WidgetKeepAliveListener widgetKeepAliveListener = widget._widgetKeepAliveListener;
//    if (widgetKeepAliveListener != null) {
//      bool keepAlive = (position - widgetKeepAliveListener.position).abs() < 2;
//      if (!keepAlive) {
//        widgetKeepAliveListener.unregister(position);
//      }
//      return keepAlive;
//    }
//    return true;
//  }

  void refreshPage() {
//    Fimber.d("refreshPage[${position}]: ${spineItem.href}");
  }

  NavigationDecision _navigationDelegate(NavigationRequest navigation) =>
      NavigationDecision.navigate;

  void _onPageFinished(String url) {
    Fimber.d("_onPageFinished[$position]: $url");
    ReaderTheme theme = _readerThemeBloc.currentTheme;
    try {
      OpenPageRequest openPageRequestData =
          _getOpenPageRequestFromCommand(_readerContext.readerCommand);
      List<String> elementIds =
          _readerContext.getElementIdsFromSpineItem(position);
      ViewerSettings settings = _viewerSettingsBloc.viewerSettings;
      _jsApi.initSpineItem(
        widget._publication,
        spineItem,
        settings,
        openPageRequestData,
        elementIds,
      );
      refreshPage();
      _jsApi.setStyles(theme, settings);
      _updateSpineItemPosition(_currentSpineItemBloc.state);
      StreamSubscription<List<Annotation>> loadAnnotationsSubscription;
      // loadAnnotationsSubscription = _annotationsBloc.documentRepository
      //     .allWhere(
      //         predicate: AnnotationKindAndBookAndIdrefPredicate(
      //             spineItem.id, widget._book.id, AnnotationKind.bookmark))
      //     .listen((annotations) {
      //   _jsApi.computeAnnotationsInfo(annotations);
      //   loadAnnotationsSubscription.cancel();
      // });
      _annotationsSubscription =
          _annotationsBloc.stream.listen((DocumentsState state) {
        if (state is DocumentsLoaded && state.deletedIds.isNotEmpty) {
          _jsApi.removeBookmarks(state.deletedIds);
        }
      });
    } catch (e, stacktrace) {
      Fimber.d("_onPageFinished ERROR", ex: e, stacktrace: stacktrace);
    }
  }

  void _onWebViewCreated(WebViewController webViewController) {
    _controller = webViewController;
    _jsApi = JsApi(position, _controller.evaluateJavascript);
    _spineItemContext.jsApi = _jsApi;
    epubCallbacks.jsApi = _jsApi;
    _readerThemeSubscription =
        _readerThemeBloc.stream.listen(_onReaderThemeChanged);
    _viewerSettingsSubscription =
        _viewerSettingsBloc.stream.listen(_onViewerSettingsChanged);
    _currentSpineItemSubscription =
        _currentSpineItemBloc.stream.listen(_updateSpineItemPosition);
    _readerCommandSubscription =
        _readerContext.commandsStream.listen(_onReaderCommand);
    _paginationInfoSubscription =
        _spineItemContext.paginationInfoStream.listen(_onPaginationInfo);
  }

  void _onReaderThemeChanged(ReaderThemeState state) {
    ViewerSettings settings = _viewerSettingsBloc.state.viewerSettings;
    _jsApi.setStyles(state.readerTheme, settings);
  }

  void _onViewerSettingsChanged(ViewerSettingsState state) =>
      _jsApi.updateFontSize(state.viewerSettings);

  void _updateSpineItemPosition(CurrentSpineItemState state) {
    this.currentSelectedSpineItem = state.spineItemIdx == position;
    if (state.spineItemIdx > position) {
      _jsApi.navigateToEnd();
    } else if (state.spineItemIdx < position) {
      _jsApi.navigateToStart();
    } else {
      _onPaginationInfo(_spineItemContext.currentPaginationInfo);
    }
  }

  void _onReaderCommand(ReaderCommand command) {
    OpenPageRequest openPageRequestData =
        _getOpenPageRequestFromCommand(command);
    if (openPageRequestData != null) {
      _jsApi.openPage(openPageRequestData);
    }
  }

  OpenPageRequest _getOpenPageRequestFromCommand(ReaderCommand command) {
    if (command != null && command.spineItemIndex == position) {
      _readerContext.readerCommand = null;
      return command.openPageRequest;
    }
    return null;
  }

  void _onPaginationInfo(PaginationInfo paginationInfo) {
    if (currentSelectedSpineItem && paginationInfo != null) {
      _readerContext.notifyCurrentLocation(paginationInfo, spineItem);
    }
  }
}
