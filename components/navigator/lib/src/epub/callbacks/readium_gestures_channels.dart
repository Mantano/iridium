// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/callbacks/model/tap_event.dart';
import 'package:mno_navigator/src/epub/callbacks/webview_listener.dart';

class ReadiumChannels extends JavascriptChannels {
  final SpineItemContext _spineItemContext;
  final ViewerSettingsBloc? viewerSettingsBloc;
  final WebViewHorizontalGestureRecognizer? webViewHorizontalGestureRecognizer;
  final WebViewListener listener;
  late JsApi jsApi;

  ReadiumChannels(this._spineItemContext, this.viewerSettingsBloc,
      this.webViewHorizontalGestureRecognizer, this.listener);

  @override
  Map<String, JavaScriptHandlerCallback> get channels => {
        "onTap": _onTap,
        "scrollRight": (args) => _scrollRight(args.first),
        "scrollLeft": (args) => _scrollLeft(args.first),
        "onDecorationActivated": _onDecorationActivated,
        "highlightAnnotationMarkActivated": _highlightAnnotationMarkActivated,
        "highlightActivated": _highlightActivated,
        "logError": _logError,
        "log": _log,
        "getViewportWidth": _getViewportWidth,
      };

  bool _onTap(List<dynamic> arguments) {
    TapEvent? event = TapEvent.fromJSON(arguments.first);
    if (event == null) {
      return false;
    }
    Fimber.d("event: $event");

    // The script prevented the default behavior.
    if (event.defaultPrevented) {
      return false;
    }

    // FIXME: Let the app handle edge taps and footnotes.

    // We ignore taps on interactive element, unless it's an element we handle ourselves such as
    // pop-up footnotes.
    if (event.interactiveElement != null) {
      return handleFootnote(event.targetElement);
    }

    // Skips to previous/next pages if the tap is on the content edges.
    double clientWidth = computeHorizontalScrollExtent();
    double thresholdRange = 0.2 * clientWidth;

    // FIXME: Call listener.onTap if scrollLeft|Right fails
    if (event.point.dx < thresholdRange) {
      _scrollLeft(false);
      return true;
    }
    if (clientWidth - event.point.dx < thresholdRange) {
      _scrollRight(false);
      return true;
    }
    return listener.onTap(event.point);
  }

  double get devicePixelRatio =>
      WidgetsBinding.instance!.window.devicePixelRatio;

  /// TODO implement find real horizontal scroll extent
  double computeHorizontalScrollExtent() =>
      _spineItemContext.readerContext.viewportWidth.toDouble();

  /// TODO implement display footnote
  bool handleFootnote(String targetElement) => true;

  void _scrollRight(bool animated) {
    Fimber.d("animated: $animated");

    jsApi.scrollRight().then((success) {
      Fimber.d("success: $success");
      if (success is bool && !success) {
        listener.goRight(animated: animated);
      }
    });
  }

  void _scrollLeft(bool animated) {
    Fimber.d("animated: $animated");

    jsApi.scrollLeft().then((success) {
      Fimber.d("success: $success");
      if (success is bool && !success) {
        listener.goLeft(animated: animated);
      }
    });
  }

  void _onDecorationActivated(List<dynamic> arguments) {
    Fimber.d("arguments: $arguments");
  }

  void _highlightAnnotationMarkActivated(List<dynamic> arguments) {
    String highlightId = arguments.first;
    Fimber.d("highlightId: $highlightId");
  }

  void _highlightActivated(List<dynamic> arguments) {
    String highlightId = arguments.first;
    Fimber.d("highlightId: $highlightId");
  }

  void _logError(List<dynamic> arguments) {
    Fimber.e(
        "JavaScript error: ${arguments[1]}:${arguments[2]} ${arguments[0]}");
  }

  void _log(List<dynamic> arguments) {
    Fimber.d("JavaScript: ${arguments.first}");
  }

  int _getViewportWidth(List<dynamic> arguments) =>
      _spineItemContext.readerContext.viewportWidth;
}
