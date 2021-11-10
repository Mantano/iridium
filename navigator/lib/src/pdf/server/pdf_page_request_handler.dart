// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:typed_data';

import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/pdf.dart';
import 'package:universal_io/io.dart';

/// Serves the resources of a [Publication] [Fetcher] from a [ServerBloc].
class PdfPageRequestHandler extends RequestHandler {
  final PdfDocument _pdfDocument;

  double get devicePixelRatio =>
      WidgetsBinding.instance.window.devicePixelRatio;

  PdfPageRequestHandler(this._pdfDocument) : assert(_pdfDocument != null);

  @override
  Future<bool> handle(int requestId, HttpRequest request, String href) async {
    // Fimber.d("query params: ${request.uri.queryParameters}");
    Uint8List data = createPageBitmap(request);
    await sendData(
      request,
      data: data,
      mediaType: MediaType.bmp,
    );
    return true;
  }

  int _getParamAsIntWithRatio(HttpRequest request, String name,
      {int defaultValue = 0}) {
    int value = getParamAsInt(request, name, defaultValue: defaultValue);
    return (value * devicePixelRatio).ceil();
  }

  Uint8List createPageBitmap(HttpRequest request) {
    int pageIndex = getParamAsInt(request, "page");
    // Fimber.d(">>> createPageBitmap, pageIndex: $pageIndex");
    PdfPage page = _pdfDocument.loadPage(pageIndex);

    ImageSize nativeSize = computeNativeSize(page);
    ImageSize constraintSize = computeConstraintSize(request, nativeSize);

    int width = _getParamAsIntWithRatio(request, "width",
        defaultValue: constraintSize.width.floor());
    int height = _getParamAsIntWithRatio(request, "height",
        defaultValue: constraintSize.height.floor());

    int tileWidth = _getParamAsIntWithRatio(request, "tileWidth",
        defaultValue: constraintSize.width.floor());
    int tileHeight = _getParamAsIntWithRatio(request, "tileHeight",
        defaultValue: constraintSize.height.floor());

    int startX = _getParamAsIntWithRatio(request, "startX");
    int startY = _getParamAsIntWithRatio(request, "startY");

    // Fimber.d("page size[$pageIndex]: $width x $height");
    Uint8List data = page.renderPageBitmap(
        tileWidth, tileHeight, startX, startY, width, height);
    page.close();
    return data;
  }

  ImageSize computeNativeSize(PdfPage page) =>
      ImageSize(page.getPageWidth(), page.getPageHeight());

  ImageSize computeConstraintSize(HttpRequest request, ImageSize nativeSize) {
    int rawConstraintWidth = getParamAsInt(request, "constraintWidth");
    int rawConstraintHeight = getParamAsInt(request, "constraintHeight");
    double constraintWidth = (rawConstraintWidth > 0)
        ? rawConstraintWidth.toDouble()
        : nativeSize.width;
    double constraintHeight = (rawConstraintHeight > 0)
        ? rawConstraintHeight.toDouble()
        : nativeSize.height;
    ImageSize constraintSize = ImageSize(constraintWidth, constraintHeight);
    if (constraintSize == nativeSize) {
      return nativeSize;
    }
    double nativeAspectRatio = nativeSize.aspectRatio;
    double constraintAspectRatio = constraintSize.aspectRatio;
    if (nativeAspectRatio > constraintAspectRatio) {
      return ImageSize(
          nativeAspectRatio * constraintSize.height, constraintSize.height);
    }
    return ImageSize(
        constraintSize.width, constraintSize.width / nativeAspectRatio);
  }
}
