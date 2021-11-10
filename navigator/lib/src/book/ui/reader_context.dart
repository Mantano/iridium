// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/model.dart';
import 'package:navigator/src/book/ui/thumbnails_page_mapping.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';
import 'package:navigator/src/epub/model/commands.dart';
import 'package:navigator/src/epub/model/open_page_request.dart';
import 'package:navigator/src/epub/model/readium_location.dart';
import 'package:navigator/src/epub/utils/toc_utils.dart';
import 'package:navigator/src/epub/widget/spine_item_context.dart';

class ReaderContextWidget extends InheritedWidget {
  final ReaderContext readerContext;

  const ReaderContextWidget({
    Key key,
    Widget child,
    @required this.readerContext,
  })  : assert(readerContext != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(ReaderContextWidget oldWidget) =>
      readerContext != oldWidget.readerContext;
}

class ReaderContext {
  final bool simplifiedMode;
  final AnnotationsBloc annotationsBloc;
  final UserException userException;
  final Book book;
  final FileAsset asset;
  final Annotation lastPosition;
  final ThumbnailsPageMapping thumbnailsPageMapping;
  final MediaType mediaType;
  final Publication publication;
  final Map<int, SpineItemContext> spineItemContextMap;
  StreamSubscription<PaginationInfo> _currentLocationSubscription;
  List<Link> _tableOfContents;
  List<Link> _flattenedTableOfContents;
  Map<Link, int> _tableOfContentsToSpineItemIndex;
  Link currentSpineItem;

  Fetcher get fetcher => publication.fetcher;

  List<Link> get tableOfContents => _tableOfContents;

  List<Link> get flattenedTableOfContents => _flattenedTableOfContents;

  Map<Link, int> get tableOfContentsToSpineItemIndex =>
      _tableOfContentsToSpineItemIndex;

  bool toolbarVisibility;
  final StreamController<bool> _toolbarStreamController =
      StreamController.broadcast();

  Stream<bool> get toolbarStream => _toolbarStreamController.stream;

  bool themeEditing;
  final StreamController<bool> _themeEditingStreamController =
      StreamController.broadcast();

  Stream<bool> get themeEditingStream => _themeEditingStreamController.stream;

  ReaderCommand readerCommand;

  /// [ReaderCommand]s Bus.
  final StreamController<ReaderCommand> _commandsStreamController =
      StreamController.broadcast();

  Stream<ReaderCommand> get commandsStream => _commandsStreamController.stream;

  PaginationInfo paginationInfo;

  /// [PaginationInfo]s Bus.
  final StreamController<PaginationInfo> _currentLocationController =
      StreamController.broadcast();

  Stream<PaginationInfo> get currentLocationStream =>
      _currentLocationController.stream;

  ReaderContext({
    @required this.simplifiedMode,
    @required this.annotationsBloc,
    @required this.userException,
    @required this.book,
    @required this.asset,
    @required this.lastPosition,
    @required this.mediaType,
    @required this.publication,
    @required this.thumbnailsPageMapping,
  })  : assert(simplifiedMode != null),
        assert(annotationsBloc != null),
        assert(book != null),
        assert(asset != null),
        assert(lastPosition != null),
        assert(mediaType != null),
        assert(userException != null || publication != null),
        assert(thumbnailsPageMapping != null),
        spineItemContextMap = {},
        toolbarVisibility = false,
        themeEditing = false {
    _tableOfContents = publication?.tableOfContents ?? [];
    _flattenedTableOfContents = TocUtils.flatten(_tableOfContents);
    _tableOfContentsToSpineItemIndex =
        TocUtils.mapTableOfContentToSpineItemIndex(
            publication, _flattenedTableOfContents);
    _toolbarStreamController.add(toolbarVisibility);
    _themeEditingStreamController.add(themeEditing);
    _currentLocationSubscription =
        currentLocationStream.listen(_onCurrentLocationChanged);
    currentSpineItem = publication?.readingOrder?.first;
  }

  bool get hasError => userException != null;

  int get currentPageNumber =>
      publication.paginationInfo[currentSpineItem].firstPageNumber;

  bool get hasThumbnail => !simplifiedMode && (cbz || epub || pdf);

  bool get hasCustomize => epub;

  bool get hasPlay => epub;

  bool get hasToolbar => !simplifiedMode;

  bool get hasNavigate => !simplifiedMode && epub;

  bool get cbz => mediaType.matches(MediaType.cbz);

  bool get epub => mediaType.matches(MediaType.epub);

  bool get pdf =>
      mediaType.matchesAny([MediaType.lcpProtectedPdf, MediaType.pdf]);

  void _onCurrentLocationChanged(PaginationInfo paginationInfo) =>
      lastPosition.location = paginationInfo.location.json;

  void dispose() {
    _toolbarStreamController.close();
    _themeEditingStreamController.close();
    _commandsStreamController.close();
    _currentLocationController.close();
    _currentLocationSubscription.cancel();
  }

  static ReaderContext of(BuildContext context) {
    final ReaderContextWidget readerContextWidget =
        context.dependOnInheritedWidgetOfExactType();
    return readerContextWidget?.readerContext;
  }

  void onTap() {
    toolbarVisibility = !toolbarVisibility;
    _toolbarStreamController.add(toolbarVisibility);
    closeThemeEdition();
  }

  List<String> getElementIdsFromSpineItem(int spineItemIndex) =>
      getTocItemsFromSpineItem(spineItemIndex)
          .map((link) => link.elementId)
          .where((s) => s != null)
          .toList();

  Iterable<Link> getTocItemsFromSpineItem(int spineItemIndex) {
    Link spineItem = publication?.readingOrder[spineItemIndex];
    return (spineItem != null)
        ? _flattenedTableOfContents
            .where((tocItem) => spineItem.href == tocItem.hrefPart)
        : const [];
  }

  void closeThemeEdition() => _updateThemeEdition(false);

  void openThemeEdition() => _updateThemeEdition(false);

  void notifyCurrentLocation(PaginationInfo paginationInfo, Link spineItem) {
    this.paginationInfo = paginationInfo;
    this.currentSpineItem = spineItem;
    _currentLocationController.add(paginationInfo);
  }

  void _updateThemeEdition(bool value) {
    this.themeEditing = value;
    _themeEditingStreamController.add(themeEditing);
  }

  /// Sends the given [ReaderCommand] on the command bus, to be executed by the
  /// relevant component.
  void execute(ReaderCommand command) {
    // Fimber.d("command: $command");
    _updateSpineItemIndexForCommand(command);
    _createOpenPageRequestForCommand(command);
    this.readerCommand = command;
    // Fimber.d("readerCommand: $readerCommand");
    _commandsStreamController.sink.add(command);
  }

  void _updateSpineItemIndexForCommand(ReaderCommand command) {
    List<Link> spine = publication.pageLinks;
    if (command is GoToHrefCommand) {
      command.spineItemIndex =
          spine.indexWhere((spineItem) => spineItem.href == command.href);
    }
    if (command is GoToLocationCommand) {
      ReadiumLocation readiumLocation = command.readiumLocation;
      command.spineItemIndex = spine
          .indexWhere((spineItem) => spineItem.id == readiumLocation.idref);
    }
    if (command is GoToPageCommand) {
      Map<Link, LinkPagination> paginationInfo = publication.paginationInfo;
      int page = command.page;
      for (Link spineItem in paginationInfo.keys) {
        LinkPagination linkPagination = paginationInfo[spineItem];
        if (linkPagination.containsPage(page)) {
          command.href = spineItem.href;
          command.percent = linkPagination.computePercent(page);
          command.spineItemIndex = spine.indexOf(spineItem);
        }
      }
    }
    if (command is GoToThumbnailCommand) {
      int page =
          thumbnailsPageMapping.thumbnailIndexToPage(command.thumbnailIndex);
      Map<Link, LinkPagination> paginationInfo = publication.paginationInfo;
      for (Link spineItem in paginationInfo.keys) {
        LinkPagination linkPagination = paginationInfo[spineItem];
        if (linkPagination.containsPage(page)) {
          command.href = spineItem.href;
          command.percent = linkPagination.computePercent(page);
          command.spineItemIndex = spine.indexOf(spineItem);
        }
      }
    }
    if (command.spineItemIndex != null && command.spineItemIndex >= 0) {
      currentSpineItem = spine[command.spineItemIndex];
    }
  }

  void _createOpenPageRequestForCommand(ReaderCommand command) {
    OpenPageRequest openPageRequestData;
    if (command is GoToHrefCommand) {
      openPageRequestData =
          OpenPageRequest.fromElementId(command.href, command.fragment);
    }
    if (command is GoToLocationCommand) {
      ReadiumLocation readiumLocation = command.readiumLocation;
      openPageRequestData = OpenPageRequest.fromIdrefAndCfi(
          readiumLocation.idref, readiumLocation.contentCFI);
    }
    if (command is GoToPageCommand) {
      openPageRequestData = OpenPageRequest.fromIdrefAndPercentage(
          command.href, command.normalizedPercent);
    }
    if (command is GoToThumbnailCommand) {
      openPageRequestData =
          thumbnailsPageMapping.commandToOpenPageRequest(command);
    }
    command.openPageRequest = openPageRequestData;
  }
}
