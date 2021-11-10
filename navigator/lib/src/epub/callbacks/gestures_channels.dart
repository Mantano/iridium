// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:fimber/fimber.dart';
import 'package:navigator/src/epub/bloc/viewer_settings_bloc.dart';
import 'package:navigator/src/epub/callbacks/javascript_channels.dart';
import 'package:navigator/src/epub/callbacks/model/coord.dart';
import 'package:navigator/src/epub/js/xpub_js_api.dart';
import 'package:navigator/src/epub/ui/listeners/web_view_horizontal_gesture_recognizer.dart';
import 'package:navigator/src/epub/widget/spine_item_context.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GesturesChannels extends JavascriptChannels {
  final SpineItemContext _spineItemContext;
  final ViewerSettingsBloc viewerSettingsBloc;
  JsApi jsApi;
  WebViewHorizontalGestureRecognizer webViewHorizontalGestureRecognizer;

  GesturesChannels(this._spineItemContext, this.viewerSettingsBloc);

  @override
  List<JavascriptChannel> get channels => [
        JavascriptChannel(
          name: "GestureCallbacksOnTap",
          onMessageReceived: _onTap,
        ),
        JavascriptChannel(
          name: "GestureCallbacksOnSwipeUp",
          onMessageReceived: _onSwipeUp,
        ),
        JavascriptChannel(
          name: "GestureCallbacksOnSwipeDown",
          onMessageReceived: _onSwipeDown,
        ),
        JavascriptChannel(
          name: 'GestureCallbacksOnBeginningVisibilityChanged',
          onMessageReceived: _onBeginningVisibilityChanged,
        ),
        JavascriptChannel(
          name: 'GestureCallbacksOnEndVisibilityChanged',
          onMessageReceived: _onEndVisibilityChanged,
        ),
      ];

  void _onTap(JavascriptMessage message) {
    Fimber.d("onTap: ${message.message}");
    try {
      Coord coord = Coord.fromJson(message.message);
      Fimber.d("onTap, coord: $coord");
      _spineItemContext.onTap();
    } on Exception catch (e, stacktrace) {
      Fimber.d("onTap: $e, $stacktrace");
    }
  }

  void _onSwipeUp(JavascriptMessage message) {
    viewerSettingsBloc?.add(IncrFontSizeEvent());
  }

  void _onSwipeDown(JavascriptMessage message) {
    viewerSettingsBloc?.add(DecrFontSizeEvent());
  }

  void _onBeginningVisibilityChanged(JavascriptMessage message) {
    bool visibility = message.message.toLowerCase() == 'true';
    webViewHorizontalGestureRecognizer?.setBeginningVisible(visibility);
  }

  void _onEndVisibilityChanged(JavascriptMessage message) {
    bool visibility = message.message.toLowerCase() == 'true';
    webViewHorizontalGestureRecognizer?.setEndVisible(visibility);
  }
}
