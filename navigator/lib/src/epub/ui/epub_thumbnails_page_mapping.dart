// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/book/book.dart';
import 'package:navigator/src/book/ui/thumbnails_page_mapping.dart';
import 'package:navigator/src/epub/bloc/snapshotting_bloc.dart';
import 'package:navigator/src/epub/bloc/snapshotting_info.dart';
import 'package:navigator/src/epub/bloc/spine_item_pagination.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/model/commands.dart';
import 'package:navigator/src/epub/model/open_page_request.dart';

class EpubThumbnailsPageMapping extends ThumbnailsPageMapping {
  final Publication publication;
  StreamSubscription<SnapshottingState> subscription;

  SnapshottingInfo snapshottingInfo;

  EpubThumbnailsPageMapping(Book book, this.publication) : super(book);

  void init(Stream<SnapshottingState> snapshottingStateStream) =>
      subscription = snapshottingStateStream.listen(_onStateChanged);

  void _onStateChanged(SnapshottingState state) => snapshottingInfo =
      (state is ThumbnailsState) ? state.snapshottingInfo : null;

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  int get nbThumbnails => snapshottingInfo?.nbThumbnails ?? 0;

  @override
  int get versionId => snapshottingInfo?.hashCode ?? super.versionId;

  @override
  int thumbnailIndexToPage(int thumbnailIndex) {
    SpineItemPagination spineItemPagination =
        _findSpineItemPagination(thumbnailIndex - 1);
    if (spineItemPagination != null) {
      Map<Link, LinkPagination> paginationInfo = publication.paginationInfo;
      Link link = publication.readingOrder[spineItemPagination.spineItemId];
      LinkPagination linkPagination = paginationInfo[link];
      Fimber.d("linkPagination: $linkPagination");
      int nbThumbnailsInSpineItem =
          thumbnailIndex - spineItemPagination.firstPage;
      double percent = nbThumbnailsInSpineItem / spineItemPagination.nbPages;
      int page = linkPagination.firstPageNumber +
          (percent * linkPagination.pagesCount).ceil();
      return page - 1;
    }
    return super.thumbnailIndexToPage(thumbnailIndex);
  }

  @override
  int pageToThumbnailIndex(int page) {
    MapEntry<Link, LinkPagination> entry = _findLinkPagination(page);
    if (entry != null && snapshottingInfo != null) {
      Link link = entry.key;
      LinkPagination linkPagination = entry.value;
      int indexOf = publication.readingOrder.indexOf(link);
      SpineItemPagination spineItemPagination =
          snapshottingInfo.spineItemPaginations[indexOf];
      int percent = linkPagination.computePercent(page);
      return spineItemPagination.firstPage +
          1 +
          spineItemPagination.nbPages * percent ~/ 100;
    }
    return super.pageToThumbnailIndex(page);
  }

  MapEntry<Link, LinkPagination> _findLinkPagination(int page) {
    Map<Link, LinkPagination> paginationInfo = publication.paginationInfo;
    for (Link spineItem in paginationInfo.keys) {
      LinkPagination linkPagination = paginationInfo[spineItem];
      if (linkPagination.containsPage(page)) {
        return MapEntry(spineItem, linkPagination);
      }
    }
    return null;
  }

  @override
  int paginationInfoToThumbnailIndex(PaginationInfo paginationInfo) {
    if (snapshottingInfo != null) {
      Page page = paginationInfo.openPages.first;
      SpineItemPagination spineItemPagination = snapshottingInfo
          .spineItemPaginations
          .firstWhere((e) => e.spineItemId == page.spineItemIndex,
              orElse: () => null);
      if (spineItemPagination != null) {
        return spineItemPagination.firstPage + page.spineItemPageIndex;
      }
    }
    return super.paginationInfoToThumbnailIndex(paginationInfo);
  }

  @override
  OpenPageRequest commandToOpenPageRequest(GoToThumbnailCommand command) {
    SpineItemPagination spineItemPagination =
        _findSpineItemPagination(command.thumbnailIndex - 1);
    if (spineItemPagination != null) {
      int index = command.thumbnailIndex - spineItemPagination.firstPage - 1;
      return OpenPageRequest.fromIdrefAndIndex(command.href, index);
    }
    return super.commandToOpenPageRequest(command);
  }

  SpineItemPagination _findSpineItemPagination(int thumbnailIndex) =>
      snapshottingInfo?.findSpineItemPagination(thumbnailIndex);
}
