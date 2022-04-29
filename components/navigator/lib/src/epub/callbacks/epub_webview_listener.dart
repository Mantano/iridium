import 'dart:math';
import 'dart:ui';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/callbacks/webview_listener.dart';
import 'package:mno_shared/publication.dart';

class EpubWebViewListener extends WebViewListener {
  final SpineItemContext _spineItemContext;
  final ViewerSettingsBloc? viewerSettingsBloc;
  final NavigationController navigator;
  final SelectionListener? selectionListener;
  final ValueGetter<Offset>? webViewOffset;

  EpubWebViewListener(
      this._spineItemContext, this.viewerSettingsBloc, this.navigator,
      {this.selectionListener, this.webViewOffset});

  ReaderAnnotationRepository get readerAnnotationRepository =>
      _spineItemContext.readerAnnotationRepository;

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
  Future<bool> onDecorationActivated(
      String id, String group, Rectangle<double> rect, Offset point) async {
    String highlightId = id.removeSuffix("-highlight");
    ReaderAnnotation? highlight =
        await readerAnnotationRepository.get(highlightId);
    if (highlight == null) {
      return false;
    }
    Locator? locator = Locator.fromJsonString(highlight.location);
    if (locator == null) {
      return false;
    }
    Selection selection = Selection(locator: locator, rect: rect);
    selection.offset = webViewOffset?.call() ?? Offset.zero;
    selectionListener?.showHighlightPopup(selection, highlight.style!,
        highlightId: highlightId);
    return true;
  }

  @override
  void onProgressionChanged() {}

  @override
  void onHighlightActivated(String id) {}

  @override
  void onHighlightAnnotationMarkActivated(String id) {}

  @override
  bool goRight(
      {bool animated = false,
      Function completion = NavigationController.emptyFunc}) {
    navigator.onSkipRight(animated: animated);
    completion();
    return true;
  }

  @override
  bool goLeft(
      {bool animated = false,
      Function completion = NavigationController.emptyFunc}) {
    navigator.onSkipLeft(animated: animated);
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
