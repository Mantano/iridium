// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class GesturesChannels extends JavascriptChannels {
  final SpineItemContext _spineItemContext;
  final ViewerSettingsBloc? viewerSettingsBloc;
  final WebViewHorizontalGestureRecognizer? webViewHorizontalGestureRecognizer;
  late JsApi jsApi;

  GesturesChannels(this._spineItemContext, this.viewerSettingsBloc,
      this.webViewHorizontalGestureRecognizer);

  @override
  Map<String, JavaScriptHandlerCallback> get channels => {
        "GestureCallbacksOnTap": _onTap,
        "GestureCallbacksOnSwipeUp": _onSwipeUp,
        "GestureCallbacksOnSwipeDown": _onSwipeDown,
        "GestureCallbacksOnLeftOverlayVisibilityChanged":
            _onLeftOverlayVisibilityChanged,
        "GestureCallbacksOnRightOverlayVisibilityChanged":
            _onRightOverlayVisibilityChanged,
      };

  void _onTap(List<dynamic> arguments) {
    Fimber.d("onTap: $arguments");
    if (arguments.isNotEmpty) {
      try {
        Coord coord = Coord.fromJson(arguments.first);
        Fimber.d("onTap, coord: $coord");
        _spineItemContext.onTap();
        bool scrollSnapShouldStop =
            !_spineItemContext.readerContext.toolbarVisibility;
        Fimber.d(
            "================ Setting scroll-snap-stop to: ${scrollSnapShouldStop ? "always" : "normal"}");
        viewerSettingsBloc
            ?.add(ScrollSnapShouldStopEvent(scrollSnapShouldStop));
      } on Exception catch (e, stacktrace) {
        Fimber.d("onTap: $e, $stacktrace");
      }
    }
  }

  void _onSwipeUp(List<dynamic> arguments) {
    viewerSettingsBloc?.add(IncrFontSizeEvent());
  }

  void _onSwipeDown(List<dynamic> arguments) {
    viewerSettingsBloc?.add(DecrFontSizeEvent());
  }

  void _onLeftOverlayVisibilityChanged(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
      Fimber.d("================== _onLeftOverlayVisibilityChanged, message: " +
          arguments.first +
          ", recognizer: $webViewHorizontalGestureRecognizer");
      bool visibility = arguments.first.toLowerCase() == 'true' ||
          arguments.first.toLowerCase() == '1';
      webViewHorizontalGestureRecognizer?.setLeftOverlayVisible(visibility);
    }
  }

  void _onRightOverlayVisibilityChanged(List<dynamic> arguments) {
    if (arguments.isNotEmpty) {
      Fimber.d(
          "================== _onRightOverlayVisibilityChanged, message: " +
              arguments.first +
              ", recognizer: $webViewHorizontalGestureRecognizer");
      bool visibility = arguments.first.toLowerCase() == 'true' ||
          arguments.first.toLowerCase() == '1';
      webViewHorizontalGestureRecognizer?.setRightOverlayVisible(visibility);
    }
  }
}
