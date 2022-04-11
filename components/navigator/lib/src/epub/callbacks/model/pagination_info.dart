// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:mno_shared/publication.dart';

class PaginationInfo {
  final Map<String, dynamic> json;
  final int spineItemIndex;
  final Locator locator;
  final Location location;
  final List<String> pageBookmarks = [];
  final Page openPage;
  final LinkPagination linkPagination;

  PaginationInfo(this.json, this.spineItemIndex, this.locator, this.location,
      this.openPage, this.linkPagination);

  static PaginationInfo fromJson(String jsonString, int spineItemIndex,
      Locator locator, LinkPagination linkPagination) {
    // debugPrint('\npaginating: \n$jsonString');
    Map<String, dynamic> json = const JsonCodec().decode(jsonString);
    Location location = _locationFromJson(json);
    Page openPage = _openPageFromJson(json);
    PaginationInfo paginationInfo = PaginationInfo(
        json,
        spineItemIndex,
        locator.copyWithLocations(progression: location.progression),
        location,
        openPage,
        linkPagination);
    List<dynamic> pageBookmarks = json["pageBookmarks"] ?? [];
    paginationInfo.pageBookmarks.addAll(pageBookmarks.map((s) => s.toString()));
    return paginationInfo;
  }

  int get percent {
    if (openPage.spineItemPageCount <= 1) {
      return 0;
    }
    return (100 * openPage.spineItemPageIndex) ~/
        (openPage.spineItemPageCount - 1);
  }

  int get page =>
      linkPagination.firstPageNumber +
      percent * (linkPagination.pagesCount - 1) ~/ 100;

  static Location _locationFromJson(Map<String, dynamic> json) {
    Map<String, dynamic> locationJson = json["location"];
    return Location(
        const JsonCodec().encode(locationJson),
        locationJson["version"] as int,
        locationJson["cfi"],
        locationJson["elementCfi"],
        (locationJson["progression"] as num?)?.toDouble());
  }

  static Page _openPageFromJson(Map<String, dynamic> json) {
    Map<String, dynamic> openPage = json["openPage"];
    return Page(openPage["spineItemPageIndex"], openPage["spineItemPageCount"],
        openPage["spineItemPageThumbnailsCount"] ?? 1);
  }

  String? getString(String name) =>
      json.containsKey(name) ? json[name].toString() : null;

  @override
  String toString() => 'PaginationInfo{json: $json, '
      'pageBookmarks: $pageBookmarks,'
      'page: $page, '
      'openPage: $openPage, '
      'linkPagination: $linkPagination}';
}

class Page {
  final int spineItemPageIndex;
  final int spineItemPageCount;
  final int spineItemPageThumbnailsCount;

  Page(this.spineItemPageIndex, this.spineItemPageCount,
      this.spineItemPageThumbnailsCount);

  @override
  String toString() => 'Page{spineItemPageIndex: $spineItemPageIndex, '
      'spineItemPageCount: $spineItemPageCount, '
      'spineItemPageThumbnailsCount: $spineItemPageThumbnailsCount}';
}

class Location {
  final int version;
  final String json;
  final String? cfi;
  final String? elementCfi;
  final double? progression;

  Location(
      this.json, this.version, this.cfi, this.elementCfi, this.progression);

  @override
  String toString() => 'Location{version: $version, '
      'cfi: $cfi, '
      'elementCfi: $elementCfi, '
      'progression: $progression}';
}
