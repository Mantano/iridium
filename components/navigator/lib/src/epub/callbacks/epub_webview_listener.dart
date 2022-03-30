import 'dart:ui';

import 'package:fimber/fimber.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/callbacks/webview_listener.dart';
import 'package:mno_shared/publication.dart';

class EpubWebViewListener extends WebViewListener {
  final SpineItemContext _spineItemContext;
  final ViewerSettingsBloc? viewerSettingsBloc;
  final PublicationController publicationController;

  EpubWebViewListener(this._spineItemContext, this.viewerSettingsBloc,
      this.publicationController);

  @override
  ReadingProgression get readingProgression => ReadingProgression.ltr;

  @override
  void onResourceLoaded(Link? link, InAppWebView webView, String? url) {}

  @override
  void onPageLoaded() {}

  @override
  void onPageChanged(int pageIndex, int totalPages, String url) {}

  @override
  void onPageEnded(bool end) {}

  @override
  void onScroll() {}

  @override
  bool onTap(Offset point) {
    _spineItemContext.onTap();
    bool scrollSnapShouldStop =
        !_spineItemContext.readerContext.toolbarVisibility;
    Fimber.d(
        "================ Setting scroll-snap-stop to: ${scrollSnapShouldStop ? "always" : "normal"}");
    viewerSettingsBloc?.add(ScrollSnapShouldStopEvent(scrollSnapShouldStop));
    return true;
  }

  @override
  bool onDecorationActivated(
          String id, String group, Rect rect, Offset point) =>
      false;

  @override
  void onProgressionChanged() {}

  @override
  void onHighlightActivated(String id) {}

  @override
  void onHighlightAnnotationMarkActivated(String id) {}

  @override
  bool goRight(
      {bool animated = false,
      Function completion = WebViewListener.emptyFunc}) {
    publicationController.onSkipRight(animated: animated);
    completion();
    return true;
  }

  @override
  bool goLeft(
      {bool animated = false,
      Function completion = WebViewListener.emptyFunc}) {
    publicationController.onSkipLeft(animated: animated);
    completion();
    return true;
  }

  /// Returns the custom [ActionMode.Callback] to be used with the text selection menu.
//   ActionMode.Callback? get selectionActionModeCallback  => null;

  /// Offers an opportunity to override a request loaded by the given web view.
  @override
  bool shouldOverrideUrlLoading(
          InAppWebView webView, WebResourceRequest request) =>
      false;
}
