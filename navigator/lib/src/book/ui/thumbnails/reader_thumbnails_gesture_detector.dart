// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/book/ui/thumbnails/indexed_scroll_controller.dart';
import 'package:navigator/src/book/ui/thumbnails/reader_thumbnail_config.dart';
import 'package:navigator/src/epub/model/commands.dart';

class ReaderThumbnailsGestureDetector extends StatefulWidget {
  final IndexedScrollController scrollController;
  final ReaderContext readerContext;
  final StreamController<int> pageNumberSliderController;
  final ReaderThumbnailConfig readerThumbnailConfig;
  final PanelController panelController;
  final Widget child;

  const ReaderThumbnailsGestureDetector({
    Key key,
    this.scrollController,
    this.readerContext,
    this.pageNumberSliderController,
    this.readerThumbnailConfig,
    this.panelController,
    this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReaderThumbnailsGestureDetectorState();
}

class ReaderThumbnailsGestureDetectorState
    extends State<ReaderThumbnailsGestureDetector>
    with TickerProviderStateMixin {
  IndexedScrollController get scrollController => widget.scrollController;

  StreamController<int> get pageNumberSliderController =>
      widget.pageNumberSliderController;

  Widget get child => widget.child;

  ReaderContext get readerContext => widget.readerContext;

  PanelController get panelController => widget.panelController;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onTapUp: _onTapUp,
        child: child,
      );

  void updatePageNumberSlider() =>
      pageNumberSliderController.add(scrollController.currentIndex);

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (panelController.panelPosition == 0.0) {
      scrollController
          .jumpTo(scrollController.position.pixels - details.delta.dx);
      updatePageNumberSlider();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!scrollController.hasClients) {
      return;
    }
    double velocity = details.velocity.pixelsPerSecond.dx;
    Simulation simulation = ClampingScrollSimulation(
      position: scrollController.position.pixels,
      velocity: -velocity,
    );
    AnimationController ballisticController = AnimationController(
      lowerBound: scrollController.position.minScrollExtent,
      upperBound: scrollController.position.maxScrollExtent,
      vsync: this,
    );
    ballisticController
      ..addListener(() {
        scrollController.jumpTo(ballisticController.value);
        updatePageNumberSlider();
      })
      ..animateWith(simulation).whenCompleteOrCancel(() {
        ballisticController.dispose();
        updatePageNumberSlider();
      });
  }

  void _onTapUp(TapUpDetails details) {
    int index = scrollController.findIndex(details.localPosition);
    readerContext.execute(GoToThumbnailCommand(index + 1));
  }
}
