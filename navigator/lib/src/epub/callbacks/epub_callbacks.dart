// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:model/blocs/documents/documents.dart';
import 'package:navigator/src/epub/bloc/viewer_settings_bloc.dart';
import 'package:navigator/src/epub/callbacks/gestures_channels.dart';
import 'package:navigator/src/epub/callbacks/launcher_ui_channels.dart';
import 'package:navigator/src/epub/js/xpub_js_api.dart';
import 'package:navigator/src/epub/ui/listeners/web_view_horizontal_gesture_recognizer.dart';
import 'package:navigator/src/epub/widget/spine_item_context.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EpubCallbacks {
  final LauncherUIChannels _launcherUIChannels;
  final GesturesChannels _gesturesChannels;

  set webViewHorizontalGestureRecognizer(
          WebViewHorizontalGestureRecognizer
              webViewHorizontalGestureRecognizer) =>
      _gesturesChannels.webViewHorizontalGestureRecognizer =
          webViewHorizontalGestureRecognizer;

  set jsApi(JsApi jsApi) {
    _launcherUIChannels.jsApi = jsApi;
    _gesturesChannels.jsApi = jsApi;
  }

  EpubCallbacks(SpineItemContext spineItemContext,
      ViewerSettingsBloc viewerSettingsBloc, AnnotationsBloc _annotationsBloc)
      : _launcherUIChannels =
            LauncherUIChannels(spineItemContext, _annotationsBloc),
        _gesturesChannels =
            GesturesChannels(spineItemContext, viewerSettingsBloc);

  Set<JavascriptChannel> get channels => [
        _launcherUIChannels,
        _gesturesChannels
      ].expand((c) => c.channels).toSet();
}
