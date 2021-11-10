// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:navigator/src/epub/model/open_page_request.dart';
import 'package:navigator/src/epub/model/readium_location.dart';

abstract class ReaderCommand {
  int spineItemIndex;
  OpenPageRequest openPageRequest;
}

class GoToHrefCommand extends ReaderCommand {
  final String href;
  final String fragment;

  GoToHrefCommand(this.href, this.fragment) : assert(href != null);

  @override
  String toString() => '$runtimeType{href: $href, fragment: $fragment, '
      'spineItemIndex: $spineItemIndex, openPageRequest: $openPageRequest}';
}

class GoToLocationCommand extends ReaderCommand {
  final String location;
  final ReadiumLocation readiumLocation;

  GoToLocationCommand(this.location)
      : assert(location != null),
        readiumLocation = ReadiumLocation.createLocation(location);

  @override
  String toString() => '$runtimeType{location: $location, '
      'spineItemIndex: $spineItemIndex, openPageRequest: $openPageRequest}';
}

class GoToPageCommand extends ReaderCommand {
  final int page;
  String href;
  int percent;

  GoToPageCommand(this.page) : assert(page != null);

  /// percent value between 0.0 and 1.0
  double get normalizedPercent => percent / 100;

  @override
  String toString() => '$runtimeType{href: $href, page: $page, '
      'spineItemIndex: $spineItemIndex, openPageRequest: $openPageRequest}';
}

class GoToThumbnailCommand extends ReaderCommand {
  final int thumbnailIndex;
  String href;
  int percent;

  GoToThumbnailCommand(this.thumbnailIndex) : assert(thumbnailIndex != null);

  /// percent value between 0.0 and 1.0
  double get normalizedPercent => percent / 100;

  @override
  String toString() =>
      '$runtimeType{href: $href, thumbnailIndex: $thumbnailIndex, '
      'spineItemIndex: $spineItemIndex, openPageRequest: $openPageRequest}';
}
