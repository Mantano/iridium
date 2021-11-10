// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_server/mno_server.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/utils/state.dart';
import 'package:ui_framework/widgets/animations/collapsible_panel.dart';
import 'package:ui_framework/widgets/sliding_up_panel/sliding_up_panel.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/book/ui/reader_core_toolbar.dart';
import 'package:navigator/src/book/ui/thumbnails/indexed_scroll_controller.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_grid_thumbnails.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_list_thumbnails.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_thumbnail_config.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_thumbnails_gesture_detector.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';

class ReaderThumbnailsController {
  PanelController _panelController;

  Future<void> close() async => _panelController?.close();

  Future<void> show() async => _panelController?.show();

  Future<void> update({bool visible = false}) => (visible) ? show() : close();
}

class ReaderThumbnails extends StatefulWidget {
  final ReaderThumbnailsController readerThumbnailsController;
  final CollapsiblePanelController collapsiblePanelController;
  final StreamController<int> pageNumberController;
  final StreamController<int> pageNumberSliderController;
  final StreamController<bool> thumbnailsVisibilityController;
  final ReaderContext readerContext;
  final ServerBloc serverBloc;
  final double maxHeight;
  final EdgeInsets padding;

  const ReaderThumbnails({
    Key key,
    this.readerThumbnailsController,
    this.collapsiblePanelController,
    this.thumbnailsVisibilityController,
    this.pageNumberController,
    this.pageNumberSliderController,
    this.readerContext,
    this.serverBloc,
    this.maxHeight,
    this.padding,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReaderThumbnailsState();
}

class ReaderThumbnailsState extends State<ReaderThumbnails>
    with TickerProviderStateMixin {
  static const Duration closeThumbnailsPanelDuration =
      Duration(milliseconds: 300);
  StreamSubscription<int> _pageNumberSubscription;
  StreamSubscription<bool> _toolbarSubscription;
  StreamController<SlidingPanelNotification>
      _slidingPanelNotificationController;
  IndexedScrollController _thumbnailController;
  SlidingPanelTransitionController slidingPanelTransitionController;
  ReaderThumbnailConfig readerThumbnailConfig;
  PanelController _panelController;
  int _lastPage;

  StreamSubscription<PaginationInfo> _currentLocationSubscription;

  ReaderThumbnailsController get readerThumbnailsController =>
      widget.readerThumbnailsController;

  CollapsiblePanelController get collapsiblePanelController =>
      widget.collapsiblePanelController;

  StreamController<int> get pageNumberController => widget.pageNumberController;

  StreamController<int> get pageNumberSliderController =>
      widget.pageNumberSliderController;

  StreamController<bool> get thumbnailsVisibilityController =>
      widget.thumbnailsVisibilityController;

  ReaderContext get readerContext => widget.readerContext;

  ServerBloc get serverBloc => widget.serverBloc;

  int get nbPages => readerContext.book.nbPages;

  double get thumbnailContainerHeight => widget.maxHeight;

  EdgeInsets get padding => widget.padding;

  set lastPage(int lastPage) => _lastPage = lastPage.clamp(1, nbPages);

  ThemeBloc get _themeBloc => BlocProvider.of<ThemeBloc>(context);

  @override
  void initState() {
    super.initState();
    slidingPanelTransitionController = SlidingPanelTransitionController();
    _panelController = PanelController();
    readerThumbnailsController._panelController = _panelController;
    readerThumbnailConfig = ReaderThumbnailConfig();
    _thumbnailController = IndexedScrollController(
      readerThumbnailConfig: readerThumbnailConfig,
      readerContext: readerContext,
      maxIndex: nbPages,
    );
    _slidingPanelNotificationController = StreamController.broadcast();
    _pageNumberSubscription =
        pageNumberController.stream.listen(_onPageNumberChanged);
    _toolbarSubscription = readerContext.toolbarStream
        .listen((event) => _onPageChanged(readerContext.paginationInfo));
    _currentLocationSubscription =
        readerContext.currentLocationStream.listen(_onPageChanged);
    lastPage = readerContext.book.lastPage;
  }

  @override
  void dispose() {
    super.dispose();
    readerThumbnailsController._panelController = null;
    _slidingPanelNotificationController?.close();
    _pageNumberSubscription?.cancel();
    _toolbarSubscription?.cancel();
    _currentLocationSubscription?.cancel();
  }

  void _onPageChanged(PaginationInfo paginationInfo) {
    _onPaginationInfoChanged(paginationInfo);
    if (_lastPage != paginationInfo.page) {
      setState(() => lastPage = paginationInfo.page);
    }
  }

  void _onPageNumberChanged(int pageNumber) =>
      _thumbnailController.jumpToIndex(pageNumber);

  void _onPaginationInfoChanged(PaginationInfo paginationInfo) =>
      _thumbnailController.jumpToPaginationInfo(paginationInfo);

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
      stream: thumbnailsVisibilityController.stream,
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) => SizedBox(
            height: thumbnailContainerHeight,
            child: SlidingPanelTransitionNotification(
              collapsiblePanelController: collapsiblePanelController,
              slidingPanelNotificationController:
                  _slidingPanelNotificationController,
              controller: slidingPanelTransitionController,
              child: _buildSlidingUpPanel(snapshot, _themeBloc),
            ),
          ));

  Widget _buildSlidingUpPanel(
          AsyncSnapshot<bool> snapshot, ThemeBloc themeBloc) =>
      SlidingUpPanel(
        minHeight: readerThumbnailConfig.thumbnailListHeight +
            ReaderCoreToolbarState.defaultToolbarHeight +
            viewPaddingBottom,
        maxHeight: widget.maxHeight,
        controller: _panelController,
        onPanelSlide: slidingPanelTransitionController.onPanelSlide,
        panelBuilder: (scrollController) =>
            _buildPanel(scrollController, snapshot.data, themeBloc),
      );

  Widget _buildPanel(ScrollController scrollController, bool visible,
          ThemeBloc themeBloc) =>
      Padding(
        padding: padding,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _panelController.animatePanelToPosition(0.0,
                duration: closeThumbnailsPanelDuration),
            child: SvgAssets.arrowDown.widget(),
          ),
          backgroundColor:
              themeBloc.currentTheme.primaryColor.colorDark.withAlpha(150),
          body: Container(
            decoration: const BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: DefaultColors.defaultBoxShadow,
                  offset: Offset.zero,
                  blurRadius: CommonSizes.popupElevation,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
            child: Stack(
              children: [
                _buildListThumbnails(visible),
                _buildGridThumbnails(scrollController),
              ],
            ),
          ),
        ),
      );

  Widget _buildListThumbnails(bool visible) =>
      StreamBuilder<SlidingPanelNotification>(
          stream: _slidingPanelNotificationController.stream,
          initialData: const SlidingPanelNotification(),
          builder: (BuildContext context,
                  AsyncSnapshot<SlidingPanelNotification> snapshot) =>
              Opacity(
                opacity: snapshot.data.openedAboveTransitionFraction,
                child: ReaderListThumbnails(
                  visible: visible,
                  scrollController: _thumbnailController,
                  readerThumbnailConfig: readerThumbnailConfig,
                  readerContext: readerContext,
                  serverBloc: serverBloc,
                ),
              ));

  Widget _buildGridThumbnails(ScrollController scrollController) =>
      ReaderThumbnailsGestureDetector(
        scrollController: _thumbnailController,
        readerContext: readerContext,
        pageNumberSliderController: pageNumberSliderController,
        readerThumbnailConfig: readerThumbnailConfig,
        panelController: _panelController,
        child: StreamBuilder<SlidingPanelNotification>(
            stream: _slidingPanelNotificationController.stream,
            initialData: const SlidingPanelNotification(),
            builder: (BuildContext context,
                    AsyncSnapshot<SlidingPanelNotification> snapshot) =>
                SafeArea(
                  child: Opacity(
                    opacity: 1.0 - snapshot.data.openedAboveTransitionFraction,
                    child: ReaderGridThumbnails(
                      visibilityGridStream: _slidingPanelNotificationController
                          .stream
                          .map((event) => event.newFullPanelVisibility),
                      scrollController: scrollController,
                      readerThumbnailConfig: ReaderThumbnailConfig(
                        itemPadding: 0.0,
                      ),
                      readerContext: readerContext,
                      serverBloc: serverBloc,
                    ),
                  ),
                )),
      );
}
