export default {
  onDecorationActivated: function (value) {
    return window.flutter_inappwebview.callHandler(
      "onDecorationActivated",
      value
    );
  },
  onTap: function (event) {
    return window.flutter_inappwebview.callHandler("onTap", event);
  },
  highlightAnnotationMarkActivated: function (highlightId) {
    window.flutter_inappwebview.callHandler(
      "highlightAnnotationMarkActivated",
      highlightId
    );
  },
  highlightActivated: function (highlightId) {
    window.flutter_inappwebview.callHandler("highlightActivated", highlightId);
  },
  logError: function (message, filename, lineno) {
    window.flutter_inappwebview.callHandler(
      "logError",
      message,
      filename,
      lineno
    );
  },
  log: function (message) {
    window.flutter_inappwebview.callHandler("log", message);
  },
  getViewportWidth: function (message) {
    return window.flutter_inappwebview.callHandler("getViewportWidth", message);
  },
  onLeftOverlayVisibilityChanged: function (value) {
    window.flutter_inappwebview.callHandler(
      "onLeftOverlayVisibilityChanged",
      value
    );
  },
  onRightOverlayVisibilityChanged: function (value) {
    window.flutter_inappwebview.callHandler(
      "onRightOverlayVisibilityChanged",
      value
    );
  },
  onSwipeDown: function (value) {
    window.flutter_inappwebview.callHandler("onSwipeDown", value);
  },
  onSwipeUp: function (value) {
    window.flutter_inappwebview.callHandler("onSwipeUp", value);
  },
};
