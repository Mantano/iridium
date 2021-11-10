// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/css/reader_theme.dart';
import 'package:model/css/reader_theme_repository.dart';
import 'package:model/model.dart';
import 'package:navigator/src/epub/utils/simple_asset_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:ui_commons/document_opener/document_opener.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:utils/extensions/hex_color.dart';
import 'package:navigator/src/book/ui/book_screen_state.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/book/ui/thumbnails_page_mapping.dart';
import 'package:navigator/src/epub/bloc/reader_theme_bloc.dart';
import 'package:navigator/src/epub/bloc/snapshotting_bloc.dart';
import 'package:navigator/src/epub/bloc/viewer_settings_bloc.dart';
import 'package:navigator/src/epub/model/epub_reader_state.dart';
import 'package:navigator/src/epub/server/thumbnail_request_handler.dart';
import 'package:navigator/src/epub/settings/readium_theme_values.dart';
import 'package:navigator/src/epub/settings/viewer_settings.dart';
import 'package:navigator/src/epub/ui/epub_thumbnails_page_mapping.dart';
import 'package:navigator/src/epub/ui/listeners/widget_keep_alive_listener.dart';
import 'package:navigator/src/epub/ui/webview_screen.dart';
import 'package:navigator/src/epub/widget/theme/bloc/reader_theme_list_bloc.dart';
import 'package:fimber/fimber.dart';

class EpubBookScreen extends BookScreen {
  final ReaderThemeRepository readerThemeRepository;

  const EpubBookScreen(
    this.readerThemeRepository, {
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
  State<StatefulWidget> createState() => EpubBookScreenState();
}

class EpubBookScreenState extends BookScreenState<EpubBookScreen> {
  EpubThumbnailsPageMapping epubThumbnailsPageMapping;
  EpubReaderState _readerState;
  SnapshottingBloc _snapshottingBloc;
  ReaderThemeBloc _readerThemeBloc;
  ViewerSettingsBloc _viewerSettingsBloc;
  ReaderThemeListBloc _readerThemeListBloc;
  StreamSubscription<ServerState> serverSubscription;
  StreamSubscription<ReaderThemeState> readerThemeSubscription;
  StreamSubscription<ViewerSettingsState> viewerSettingsSubscription;
  WidgetKeepAliveListener _widgetKeepAliveListener;
  PreloadPageController _pageController;
  BoxConstraints snapshottingConstraints;

  Future<ReaderTheme> loadingReaderThemeFuture;

  ReaderThemeRepository get readerThemeRepository =>
      widget.readerThemeRepository;

  EpubBookScreenState();

  Future<ReaderTheme> getDefaultReaderTheme() =>
      Future.value(ReaderTheme.defaultTheme);

  @override
  void initState() {
    super.initState();
    _readerState = EpubReaderState.fromJson(book.readerState);
    _viewerSettingsBloc = ViewerSettingsBloc(_readerState);
    loadingReaderThemeFuture = getDefaultReaderTheme();
    loadingReaderThemeFuture =
        readerThemeRepository.get(_readerState.themeId).then((readerTheme) {
      readerTheme = readerTheme ?? ReaderTheme.defaultTheme;
      _readerThemeBloc = ReaderThemeBloc(readerTheme);
      readerThemeSubscription =
          _readerThemeBloc.stream.listen((ReaderThemeState state) {
        _notifyReaderSettingsChanged(readerTheme: state.readerTheme);
      });
      return readerTheme;
    });

    _readerThemeListBloc =
        ReaderThemeListBloc(readerThemeRepository: readerThemeRepository);
    _readerThemeListBloc.add(ReaderThemeLoadEvent());
    _widgetKeepAliveListener = WidgetKeepAliveListener();
    serverSubscription = serverBloc.stream.listen((ServerState state) {
      if (state is ServerStarted && snapshottingConstraints != null) {
        WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) => _notifyReaderSettingsChanged());
      }
    });
    viewerSettingsSubscription =
        _viewerSettingsBloc.stream.listen((ViewerSettingsState state) {
      _notifyReaderSettingsChanged(viewerSettings: state.viewerSettings);
    });
  }

  @override
  Future<ReaderContext> readerContextFuture(BuildContext context) async =>
      super.readerContextFuture(context).then((readerContext) {
        _snapshottingBloc = SnapshottingBloc(readerContext);
        epubThumbnailsPageMapping.init(_snapshottingBloc.stream);
        _snapshottingBloc.epubThumbnailsPageMapping = epubThumbnailsPageMapping;
        return readerContext;
      });

  @override
  void saveBookPosition() {
    book.readerState = _readerState.toJson();
    super.saveBookPosition();
  }

  @override
  void onServerClosed() {
    _snapshottingBloc?.add(SnapshottingStopEvent());
    super.onServerClosed();
  }

  @override
  void dispose() {
    _snapshottingBloc?.close();
    epubThumbnailsPageMapping?.dispose();
    serverSubscription?.cancel();
    readerThemeSubscription?.cancel();
    viewerSettingsSubscription?.cancel();
    super.dispose();
  }

  @override
  ThumbnailsPageMapping initThumbnailsPageMapping(Publication publication) {
    epubThumbnailsPageMapping = EpubThumbnailsPageMapping(book, publication);
    return epubThumbnailsPageMapping;
  }

  @override
  void jumpToPage(int page) => _pageController.jumpToPage(page);

  @override
  bool get pageControllerAttached => _pageController.hasClients;

  @override
  List<RequestHandler> get handlers => [
        AssetsRequestHandler(
//          'assets',
          'assets',
          assetProvider: SimpleAssetProvider(),
          transformData: _transformAssetData,
        ),
        ThumbnailRequestHandler(book),
        FetcherRequestHandler(readerContext.publication)
      ];

  @override
  Widget build(BuildContext context) => FutureBuilder<ReaderTheme>(
      future: loadingReaderThemeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (BuildContext context) => _readerThemeBloc),
              BlocProvider(
                  create: (BuildContext context) => _viewerSettingsBloc),
              BlocProvider(
                  create: (BuildContext context) => _readerThemeListBloc),
            ],
            child: super.build(context),
          );
        }
        return const SizedBox.shrink();
      });

  @override
  Widget buildReaderView(List<Link> spine, ServerStarted serverState) =>
      Opacity(
        opacity: 1.0,
        child: PreloadPageView.builder(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          preloadPagesCount: 1,
          onPageChanged: onPageChanged,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: spine.length,
          itemBuilder: (context, position) => WebViewScreen(
            widgetKeepAliveListener: _widgetKeepAliveListener,
            book: book,
            address: serverState.address,
            publication: readerContext.publication,
            link: spine[position],
            position: position,
          ),
        ),
      );

  @override
  Widget buildReaderSnapshottingView(
          List<Link> spine, ServerStarted serverState) =>
      LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints != snapshottingConstraints &&
            serverBloc.state is ServerStarted) {
          snapshottingConstraints = constraints;
          _notifyReaderSettingsChanged(constraints: constraints);
        }
        return const SizedBox.shrink();
      });

  void _notifyReaderSettingsChanged(
      {BoxConstraints constraints,
      ReaderTheme readerTheme,
      ViewerSettings viewerSettings}) {
    constraints = constraints ?? snapshottingConstraints;
    readerTheme = readerTheme ?? _readerThemeBloc?.currentTheme;
    viewerSettings = viewerSettings ?? _viewerSettingsBloc.viewerSettings;
    if (constraints != null && readerTheme != null && viewerSettings != null) {
      _readerState = EpubReaderState(readerTheme.id, viewerSettings.fontSize);
      _snapshottingBloc.add(InitSnapshotEvent(
          readerContext.publication,
          (serverBloc.state as ServerStarted).address,
          constraints.maxWidth.ceil(),
          constraints.maxHeight.ceil(),
          readerTheme,
          viewerSettings));
    }
  }

  Uint8List _transformAssetData(String href, Uint8List data) {
    if (href == 'xpub-assets/bookmark.svg') {
      String string = String.fromCharCodes(data).replaceAll(
          "{{color}}", DefaultColors.ratingFillColor.toHex(withAlpha: false));
      return Uint8List.fromList(string.codeUnits);
    } else if (href == 'xpub-js/ReadiumCSS-after.css') {
      ReadiumThemeValues values = ReadiumThemeValues(
          _readerThemeBloc.currentTheme, _viewerSettingsBloc.viewerSettings);
      String string = values.replaceValues(String.fromCharCodes(data));
      return Uint8List.fromList(string.codeUnits);
    }
    return data;
  }

  @override
  void initPageController(int initialPage) => _pageController =
      PreloadPageController(keepPage: true, initialPage: initialPage);

  @override
  void onPrevious() => _pageController.previousPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

  @override
  void onNext() => _pageController.nextPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

  @override
  void onPageChanged(int position) {
    super.onPageChanged(position);
    _widgetKeepAliveListener.position = position;
  }
}

class _AssetProvider implements AssetProvider {
  @override
  Future<ByteData> load(String path) => rootBundle.load(path);
  // @override
  // Future<ByteData> load(String path) =>
  //     rootBundle.load(path).catchError((ex, st) {
  //       Fimber.d("ERROR", ex: ex, stacktrace: st);
  //       return null; // ByteData(0);
  //     });
}
