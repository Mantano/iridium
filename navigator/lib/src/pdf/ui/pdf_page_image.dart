// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';
import 'dart:math';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/pdf.dart';
import 'package:mno_zoom_widget/zoom_widget.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:navigator/src/pdf/model/page_tile.dart';
import 'package:navigator/src/pdf/ui/full_image_render.dart';
import 'package:navigator/src/pdf/ui/partial_image_render.dart';

class PdfPageImage extends StatefulWidget {
  final PdfDocument pdfDocument;
  final ServerStarted state;
  final Link link;
  final int pageIndex;
  final bool partialModeEnabled;

  const PdfPageImage({
    Key key,
    this.pdfDocument,
    this.state,
    this.link,
    this.pageIndex,
    this.partialModeEnabled,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PdfPageImageState();
}

class PdfPageImageState extends State<PdfPageImage> {
  static const int _maxScaleFactor = 3;
  final GlobalKey _zoomKey = GlobalKey();
  PageTile nativePageTile;
  PageTile _scaledPageTile;
  Size _widgetSize;
  Offset currentPosition;
  double currentScale;
  StreamController<_PageTileAndPadding> pageTileController =
      StreamController.broadcast();

  Offset _viewPadding;

  _PageTileAndPadding currentPartialRenderingParams;

  PdfDocument get pdfDocument => widget.pdfDocument;

  ServerStarted get state => widget.state;

  Link get link => widget.link;

  int get pageIndex => widget.pageIndex;

  bool get partialModeEnabled => widget.partialModeEnabled;

  Size get widgetSize => _widgetSize ?? MediaQuery.of(context).size;

  @override
  void dispose() {
    super.dispose();
    pageTileController.close();
  }

  @override
  void initState() {
    super.initState();
    _viewPadding = Offset.zero;
    currentPosition = Offset.zero;
    currentScale = 1.0 / _maxScaleFactor;
    PdfPage pdfPage = pdfDocument.loadPage(pageIndex);
    int imageWidth = pdfPage.getPageWidth().ceil();
    int imageHeight = pdfPage.getPageHeight().ceil();
    nativePageTile = PageTile.size(imageWidth, imageHeight);
    pdfPage.close();
  }

  ThemeBloc get _themeBloc => BlocProvider.of<ThemeBloc>(context);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _postFrameCallback(constraints));
        return Listener(
          onPointerUp: _onPointerUp,
          child: Stack(
            children: [
              _buildZoom(constraints),
              _buildPartialRender(),
            ],
          ),
        );
      });

  Widget _buildZoom(BoxConstraints constraints) => Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          repeat: ImageRepeat.repeat,
          image: _themeBloc.currentTheme.isDark
              ? const AssetImage(
                  'img/background_stripes_dark.gif',
                  package: 'ui_commons',
                )
              : const AssetImage(
                  'img/background_stripes_light.gif',
                  package: 'ui_commons',
                ),
        )),
        child: Zoom(
          key: _zoomKey,
          maxZoomWidth: constraints.maxWidth * _maxScaleFactor,
          maxZoomHeight: constraints.maxHeight * _maxScaleFactor,
          scrollWeight: 4.0,
          initZoom: 0.0,
          zoomSensibility: 2.3,
          canvasColor: Colors.transparent,
          backgroundColor: Colors.transparent,
//          canvasShadow: const BoxShadow(
//            color: Colors.black45,
//            blurRadius: 20.0,
//            // has the effect of softening the shadow
//            spreadRadius: 5.0,
//            // has the effect of extending the shadow
//            offset: Offset(
//              10.0, // horizontal, move right 10
//              10.0, // vertical, move down 10
//            ),
//          ),
          onPositionUpdate: (Offset position) {
            if (currentPosition != position) {
              currentPosition = position;
              updateCurrentPageTile();
            }
          },
          onScaleUpdate: (double scale, double zoom) {
            if (currentScale != scale) {
              currentScale = scale;
              updateCurrentPageTile();
            }
          },
          child: _buildFullRender(),
        ),
      );

  Widget _buildFullRender() {
    if (_scaledPageTile == null) {
      return const SizedBox.shrink();
    }
    return FullImageRender(
      address: state.address,
      link: link,
      pageTile: _scaledPageTile,
    );
  }

  Widget _buildPartialRender() => Visibility(
        visible: partialModeEnabled,
        child: IgnorePointer(
          child: StreamBuilder<_PageTileAndPadding>(
              stream: pageTileController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                return PartialImageRender(
                  size: widgetSize,
                  tilePadding: snapshot.data.padding,
                  address: state.address,
                  link: link,
                  pageTile: snapshot.data.pageTile,
                );
              }),
        ),
      );

  void _postFrameCallback(BoxConstraints constraints) {
    Size newSize = constraints.biggest;
    if (_widgetSize == newSize) {
      return;
    }
    setState(() {
      try {
        _widgetSize = newSize;
        double scale = min(newSize.width / nativePageTile.pageWidth,
            newSize.height / nativePageTile.pageHeight);
        _scaledPageTile = nativePageTile.createScaledTile(scale);
        _viewPadding = Offset(
          max((_widgetSize.width - _scaledPageTile.pageWidth) / 2, 0),
          max((_widgetSize.height - _scaledPageTile.pageHeight) / 2, 0),
        );
      } catch (ex, stacktrace) {
        Fimber.d("ERROR", ex: ex, stacktrace: stacktrace);
      }
    });
  }

  void updateCurrentPageTile() {
    if (_widgetSize == null) {
      return;
    }
    // Fimber.d("currentPosition: $currentPosition, currentScale: $currentScale");
    // Fimber.d("widgetSize: $widgetSize, _viewPadding: $_viewPadding");
    double scaleFactor = currentScale * _maxScaleFactor;
    double scaledWidgetWidth = (widgetSize.width * scaleFactor);
    double scaledWidgetHeight = (widgetSize.height * scaleFactor);

    Offset scaledPadding = _viewPadding * scaleFactor;
    // Fimber.d("scaledPadding: $scaledPadding");

    Rectangle<double> fullImageViewport = Rectangle(
        scaledPadding.dx,
        scaledPadding.dy,
        (scaledWidgetWidth - 2 * scaledPadding.dx),
        (scaledWidgetHeight - 2 * scaledPadding.dy));
    // Fimber.d("fullImageViewport: $fullImageViewport");

    Rectangle<double> screenViewport = Rectangle(currentPosition.dx,
        currentPosition.dy, widgetSize.width, widgetSize.height);
    // Fimber.d("screenViewport: $screenViewport");

    Rectangle<double> intersectionViewport =
        fullImageViewport.intersection(screenViewport);
    // Fimber.d("intersectionViewport: $intersectionViewport");

    Rectangle<double> leftBorderViewport =
        Rectangle(0, 0, scaledPadding.dx, scaledWidgetHeight);
    // Fimber.d("leftBorderViewport: $leftBorderViewport");

    Rectangle<double> topBorderViewport =
        Rectangle(0, 0, scaledWidgetWidth, scaledPadding.dy);
    // Fimber.d("topBorderViewport: $topBorderViewport");

    Rectangle<double> rightBorderViewport = Rectangle(
        (scaledWidgetWidth - scaledPadding.dx),
        0,
        scaledPadding.dx,
        scaledWidgetHeight);
    // Fimber.d("rightBorderViewport: $rightBorderViewport");

    Rectangle<double> bottomBorderViewport = Rectangle(
        0,
        (scaledWidgetHeight - scaledPadding.dy),
        scaledWidgetWidth,
        scaledPadding.dy);
    // Fimber.d("bottomBorderViewport: $bottomBorderViewport");

    double leftPadding =
        _widthRectanglesIntersection(screenViewport, leftBorderViewport);
    double topPadding =
        _heightRectanglesIntersection(screenViewport, topBorderViewport);
    double rightPadding =
        _widthRectanglesIntersection(screenViewport, rightBorderViewport);
    double bottomPadding =
        _heightRectanglesIntersection(screenViewport, bottomBorderViewport);
    EdgeInsets tilePadding = EdgeInsets.only(
        left: leftPadding,
        top: topPadding,
        right: rightPadding,
        bottom: bottomPadding);

    Rectangle<int> viewport = Rectangle(
        max(0, (intersectionViewport.left - scaledPadding.dx).floor()),
        max(0, (intersectionViewport.top - scaledPadding.dy).floor()),
        intersectionViewport.width.floor(),
        intersectionViewport.height.floor());
    PageTile currentPageTile = PageTile.viewport(
        fullImageViewport.width.floor(),
        fullImageViewport.height.floor(),
        viewport);
    currentPartialRenderingParams =
        _PageTileAndPadding(currentPageTile, tilePadding);

    pageTileController.add(null);
  }

  double _widthRectanglesIntersection(Rectangle rect1, Rectangle rect2) {
    Rectangle intersection = rect1.intersection(rect2);
    return (intersection != null) ? intersection.width.floorToDouble() : 0;
  }

  double _heightRectanglesIntersection(Rectangle rect1, Rectangle rect2) {
    Rectangle intersection = rect1.intersection(rect2);
    return (intersection != null) ? intersection.height.floorToDouble() : 0;
  }

  void _onPointerUp(PointerUpEvent event) =>
      pageTileController.add(currentPartialRenderingParams);
}

class _PageTileAndPadding {
  final PageTile pageTile;
  final EdgeInsetsGeometry padding;

  _PageTileAndPadding(this.pageTile, this.padding);

  @override
  String toString() =>
      'PageTileAndPadding{pageTile: $pageTile, padding: $padding}';
}
