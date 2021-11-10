// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mno_server/mno_server.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/utils/state.dart';
import 'package:ui_framework/widgets/animations/collapsible_panel.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/book/ui/reader_core_toolbar.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_thumbnails.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/widget/theme/theme_selector.dart';

class ReaderToolbar extends StatefulWidget {
  final ReaderContext readerContext;
  final ServerBloc serverBloc;
  final void Function() onPrevious;
  final void Function() onNext;
  final double maxHeight;

  const ReaderToolbar({
    Key key,
    this.readerContext,
    this.serverBloc,
    this.onPrevious,
    this.onNext,
    this.maxHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReaderToolbarState();
}

class ReaderToolbarState extends State<ReaderToolbar> {
  int _lastPage;
  final StreamController<int> _pageNumberController =
      StreamController.broadcast();
  final StreamController<int> _pageNumberSliderController =
      StreamController.broadcast();
  final StreamController<bool> _thumbnailsVisibilityController =
      StreamController.broadcast();
  StreamSubscription<int> _pageNumberSubscription;
  StreamSubscription<int> _pageNumberSliderSubscription;
  ReaderThumbnailsController _readerThumbnailsController;
  CollapsiblePanelController _collapsiblePanelController;
  CollapsiblePanelController _collapsibleCustomizePanelController;
  CollapsiblePanelController _collapsibleThumbnailsPanelController;
  CollapsiblePanelController _coreToolbarCollapsiblePanelController;
  StreamSubscription<bool> _toolbarSubscription;
  StreamSubscription<bool> _collapsibleCustomizePanelSubscription;
  StreamSubscription<PaginationInfo> _currentLocationSubscription;

  ReaderContext get readerContext => widget.readerContext;

  ServerBloc get serverBloc => widget.serverBloc;

  set lastPage(int lastPage) =>
      _lastPage = lastPage.clamp(1, readerContext.book.nbPages);

  @override
  void initState() {
    super.initState();
    _pageNumberSubscription =
        _pageNumberController.stream.listen(_onPageNumberChanged);
    _pageNumberSliderSubscription =
        _pageNumberSliderController.stream.listen(_onPageNumberChanged);
    _readerThumbnailsController = ReaderThumbnailsController();
    _collapsiblePanelController = CollapsiblePanelController();
    _collapsibleCustomizePanelController = CollapsiblePanelController();
    _collapsibleThumbnailsPanelController = CollapsiblePanelController();
    _coreToolbarCollapsiblePanelController = CollapsiblePanelController();
    _collapsibleCustomizePanelSubscription =
        _collapsibleCustomizePanelController.stream
            .listen(_onCustomizePanelChanged);
    _currentLocationSubscription =
        readerContext.currentLocationStream.listen(_onPageChanged);
    _toolbarSubscription =
        readerContext.toolbarStream.listen(_onToolbarVisibilityChanged);
    lastPage = readerContext.book.lastPage;
  }

  void _onCustomizePanelChanged(bool visible) =>
      _collapsibleThumbnailsPanelController.update(visible: !visible);

  void _onToolbarVisibilityChanged(bool visible) {
    if (visible || !readerContext.hasThumbnail) {
      _thumbnailsVisibilityController.add(visible);
      _coreToolbarCollapsiblePanelController.update(visible: visible);
      _collapsiblePanelController.update(visible: visible).then((value) =>
          _collapsibleThumbnailsPanelController.update(visible: visible));
    } else {
      _readerThumbnailsController
          .close()
          .then((value) =>
              _collapsibleThumbnailsPanelController.update(visible: visible))
          .then((value) {
        _thumbnailsVisibilityController.add(visible);
        _collapsiblePanelController.update(visible: visible);
      });
    }
    _onPageChanged(readerContext.paginationInfo);
    if (!visible) {
      _collapsibleCustomizePanelController.update(visible: visible);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageNumberController?.close();
    _pageNumberSliderController?.close();
    _thumbnailsVisibilityController?.close();
    _pageNumberSubscription?.cancel();
    _pageNumberSliderSubscription?.cancel();
    _toolbarSubscription?.cancel();
    _currentLocationSubscription?.cancel();
    _collapsibleCustomizePanelSubscription?.cancel();
    _collapsiblePanelController?.dispose();
    _collapsibleCustomizePanelController?.dispose();
    _collapsibleThumbnailsPanelController?.dispose();
    _coreToolbarCollapsiblePanelController?.dispose();
  }

  @override
  Widget build(BuildContext context) => CollapsiblePanel(
        controller: _collapsiblePanelController,
        height: ReaderCoreToolbarState.defaultToolbarHeight + viewPaddingBottom,
        child: _buildToolbar(context),
      );

  Widget _buildToolbar(BuildContext context) => Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          // _buildThemeSelectorCollapsiblePanel(),
          _buildReaderThumbnails(),
          _buildCoreToolbar(),
        ],
      );

  Widget _buildThemeSelectorCollapsiblePanel() => (!readerContext.hasCustomize)
      ? const SizedBox.shrink()
      : CollapsiblePanel(
          controller: _collapsibleCustomizePanelController,
          height: ThemeSelector.height + CommonSizes.large6Margin,
          child: ThemeSelector(
            stream: _collapsibleCustomizePanelController.stream,
          ),
        );

  Widget _buildReaderThumbnails() => StreamBuilder(
      stream: readerContext.thumbnailsPageMapping.displayThumbnailsStream,
      initialData: readerContext.hasThumbnail,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) => (snapshot
              .data)
          ? CollapsiblePanel(
              controller: _collapsibleThumbnailsPanelController,
              height: ReaderCoreToolbarState.defaultToolbarHeight +
                  CommonSizes.large2Margin +
                  viewPaddingBottom,
              animationCurve: const ElasticInCurve(0.6),
              expandDuration: const Duration(milliseconds: 500),
              child: ReaderThumbnails(
                readerThumbnailsController: _readerThumbnailsController,
                thumbnailsVisibilityController: _thumbnailsVisibilityController,
                collapsiblePanelController:
                    _coreToolbarCollapsiblePanelController,
                pageNumberController: _pageNumberController,
                pageNumberSliderController: _pageNumberSliderController,
                readerContext: readerContext,
                serverBloc: serverBloc,
                maxHeight: widget.maxHeight,
                padding: EdgeInsets.only(
                    bottom: ReaderCoreToolbarState.secondRowHeight -
                        2 * CommonSizes.small2Margin +
                        viewPaddingBottom),
              ),
            )
          : const SizedBox.shrink());

  Widget _buildCoreToolbar() => CollapsiblePanel(
        controller: _coreToolbarCollapsiblePanelController,
        height: ReaderCoreToolbarState.secondRowHeight,
        child: ReaderCoreToolbar(
          readerContext: readerContext,
          pageNumberController: _pageNumberController,
          collapsibleCustomizePanelController:
              _collapsibleCustomizePanelController,
          onPrevious: widget.onPrevious,
          onNext: widget.onNext,
          lastPage: _lastPage,
        ),
      );

  void _onPageChanged(PaginationInfo paginationInfo) =>
      _pageNumberController.add(paginationInfo.page);

  void _onPageNumberChanged(int pageNumber) {
    if (_lastPage != pageNumber) {
      setState(() => lastPage = pageNumber);
    }
  }
}
