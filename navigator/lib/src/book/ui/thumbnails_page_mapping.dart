// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:model/book/book.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/model/commands.dart';
import 'package:navigator/src/epub/model/open_page_request.dart';

class ThumbnailsPageMapping {
  final StreamController<bool> displayThumbnailsController =
      StreamController.broadcast();
  final Book book;

  ThumbnailsPageMapping(this.book, {bool displayThumbnails}) {
    displayThumbnailsController.add(displayThumbnails);
  }

  Stream<bool> get displayThumbnailsStream =>
      displayThumbnailsController.stream;

  int get versionId => 0;

  void dispose() => displayThumbnailsController.close();

  int get nbThumbnails => book.nbPages;

  int thumbnailIndexToPage(int thumbnailIndex) => thumbnailIndex;

  int pageToThumbnailIndex(int page) => page;

  int paginationInfoToThumbnailIndex(PaginationInfo paginationInfo) =>
      paginationInfo.page;

  OpenPageRequest commandToOpenPageRequest(GoToThumbnailCommand command) =>
      null;
}
