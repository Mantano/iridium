// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/epub.dart';
import 'package:mno_shared/publication.dart';

class JsApi {
  final int index;
  final Future<dynamic> Function(String) _jsLoader;

  JsApi(this.index, this._jsLoader);

  Future<dynamic> loadJS(String jScript) {
    Fimber.d(jScript);
    return _jsLoader(jScript);
  }

  void setElementIds(List<String> elementIds) {
    loadJS("readium.elementIds = ${json.encode(elementIds)};");
  }

  void openPage(OpenPageRequest openPageRequestData) {
    if (openPageRequestData.spineItemPercentage != null) {
      loadJS(
          "readium.scrollToPosition(\"${openPageRequestData.spineItemPercentage}\");");
    } else if (openPageRequestData.elementId != null) {
      loadJS("readium.scrollToId(\"${openPageRequestData.elementId}\");");
    } else if (openPageRequestData.text != null) {
      String data = json.encode(openPageRequestData.text!.toJson());
      loadJS("readium.scrollToText($data);");
    }
  }

  void setStyles(ReaderThemeConfig readerTheme, ViewerSettings viewerSettings) {
    if (!hasNoStyle()) {
      ReadiumThemeValues values =
          ReadiumThemeValues(readerTheme, viewerSettings);
      values.cssVarsAndValues.forEach((key, value) {
        loadJS("readium.setProperty('$key', '$value');");
      });
      initPagination();
    }
  }

  void updateFontSize(ViewerSettings viewerSettings) {
    loadJS(
        "readium.setProperty('$fontSizeName', '${viewerSettings.fontSize}%');");
    initPagination();
  }

  void updateScrollSnapStop(bool shouldStop) {
    loadJS(
        "readium.setProperty('--RS__scroll-snap-stop', '${shouldStop ? "always" : "normal"}');");
    initPagination();
  }

  void initPagination() {
    loadJS("readium.initPagination();");
  }

  void navigateToStart() {
    loadJS("readium.scrollToStart();");
  }

  void navigateToEnd() {
    loadJS("readium.scrollToEnd();");
  }

  bool hasNoStyle() => false;

  Link? getPreviousSpineItem(Publication publication, Link link) {
    List<Link> spine = publication.readingOrder;
    int spineItemIdx = spine.indexOf(link);
    return spineItemIdx > 0 ? spine[spineItemIdx - 1] : null;
  }

  Link? getNextSpineItem(Publication publication, Link link) {
    List<Link> spine = publication.readingOrder;
    int spineItemIdx = spine.indexOf(link);
    return spineItemIdx < spine.length - 1 ? spine[spineItemIdx + 1] : null;
  }

  Future<dynamic> scrollLeft() => loadJS("readium.scrollLeft();");

  Future<dynamic> scrollRight() => loadJS("readium.scrollRight();");

  void computeAnnotationsInfo(List<ReaderAnnotation> bookmarkList) {
    for (ReaderAnnotation bookmark in bookmarkList) {
      computeAnnotationInfo(bookmark);
    }
  }

  void computeAnnotationInfo(ReaderAnnotation bookmark) {
    Locator? locator = Locator.fromJson(bookmark.location.toJsonOrNull());
    if (locator != null && bookmark.isHighlight) {
      loadJS(
          "xpub.highlight.computeBoxesForCfi('${locator.href}', '${bookmark.id}', '${locator.locations.partialCfi}');");
    } else if (bookmark.isBookmark) {
      addBookmark(bookmark);
    }
  }

  void toggleBookmark() {
    loadJS("xpub.navigation.toggleBookmark();");
  }

  void addBookmark(ReaderAnnotation annotation) {
    loadJS(
        "xpub.bookmarks.addBookmark('${annotation.id}', ${annotation.location});");
  }

  void removeBookmark(PaginationInfo paginationInfo) =>
      removeBookmarks(paginationInfo.pageBookmarks);

  void removeBookmarks(Iterable<String> bookmarkIds) {
    if (bookmarkIds.isNotEmpty) {
      loadJS(
          "xpub.bookmarks.removeBookmarks(${const JsonCodec().encode(bookmarkIds)});");
    }
  }

  String? epubLayoutToJson(EpubLayout layout) {
    if (layout == EpubLayout.fixed) {
      return 'pre-paginated';
    } else if (layout == EpubLayout.reflowable) {
      return 'reflowable';
    }
    return null;
  }

  String? renditionOverflowToJson(Presentation presentation) {
    if (presentation.overflow == PresentationOverflow.auto) {
      return 'auto';
    } else if (presentation.overflow == PresentationOverflow.paginated) {
      return 'paginated';
    } else if (presentation.overflow == PresentationOverflow.scrolled) {
      return presentation.continuous == true ? 'continuous' : 'document';
    }
    return null;
  }

  String? renditionOrientationToJson(PresentationOrientation? orientation) =>
      orientation?.value;

  String? renditionSpreadToJson(PresentationSpread? spread) => spread?.value;

  String? pageToJson(PresentationPage? page) =>
      page?.value.let((it) => 'page-spread-$it');

  String readingProgressionToJson(ReadingProgression progression) =>
      progression.value;
}
