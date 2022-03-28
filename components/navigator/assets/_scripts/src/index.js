//
//  Copyright 2021 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

// Base script used by both reflowable and fixed layout resources.

import "./gestures";
import {
  removeProperty,
  scrollLeft,
  scrollRight,
  scrollToEnd,
  scrollToId,
  scrollToPosition,
  scrollToStart,
  scrollToText,
  setProperty,
} from "./utils";
import {
  createAnnotation,
  createHighlight,
  destroyHighlight,
  getCurrentSelectionInfo,
  getSelectionRect,
  rectangleForHighlightWithID,
  setScrollMode,
} from "./highlight";
import { getCurrentSelection } from "./selection";
import { getDecorations, registerTemplates } from "./decorator";

// Public API used by the navigator.
window.readium = {
  // utils
  scrollToId: scrollToId,
  scrollToPosition: scrollToPosition,
  scrollToText: scrollToText,
  scrollLeft: scrollLeft,
  scrollRight: scrollRight,
  scrollToStart: scrollToStart,
  scrollToEnd: scrollToEnd,
  setProperty: setProperty,
  removeProperty: removeProperty,

  // selection
  getCurrentSelection: getCurrentSelection,

  // decoration
  registerDecorationTemplates: registerTemplates,
  getDecorations: getDecorations,
};

window.Flutter = {};
window.Flutter.onDecorationActivated = function(value) {
    return window.flutter_inappwebview.callHandler('onDecorationActivated', value);
};;
window.Flutter.onTap = function(event) {
    return window.flutter_inappwebview.callHandler('onTap', event);
};
window.Flutter.highlightAnnotationMarkActivated = function(highlightId) {
    window.flutter_inappwebview.callHandler('highlightAnnotationMarkActivated', highlightId);
};
window.Flutter.highlightActivated = function(highlightId) {
    window.flutter_inappwebview.callHandler('highlightActivated', highlightId);
};
window.Flutter.logError = function(message, filename, lineno) {
    window.flutter_inappwebview.callHandler('logError', message, filename, lineno);
};
window.Flutter.log = function(message) {
    window.flutter_inappwebview.callHandler('log', message);
};
window.Flutter.getViewportWidth = function(message) {
    return window.flutter_inappwebview.callHandler('getViewportWidth', message);
};

// Legacy highlights API.
window.createAnnotation = createAnnotation;
window.createHighlight = createHighlight;
window.destroyHighlight = destroyHighlight;
window.getCurrentSelectionInfo = getCurrentSelectionInfo;
window.getSelectionRect = getSelectionRect;
window.rectangleForHighlightWithID = rectangleForHighlightWithID;
window.setScrollMode = setScrollMode;
