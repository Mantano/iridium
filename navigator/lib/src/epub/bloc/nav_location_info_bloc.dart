// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mno_shared/publication.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/epub/bloc/nav_location_info.dart';
import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';

class NavLocationInfoBloc
    extends Bloc<NavLocationInfoEvent, NavLocationInfoState> {
  final ReaderContext readerContext;
  StreamSubscription<PaginationInfo> _onCurrentLocationSubscription;

  NavLocationInfoBloc(this.readerContext)
      : super(NavLocationInfoState(
            NavLocationInfo(readerContext.paginationInfo),
            _LinkSelector(readerContext)
                ._selectedLink(readerContext.paginationInfo))) {
    _onCurrentLocationSubscription =
        readerContext.currentLocationStream.listen(_onCurrentLocationChanged);
    on<NavLocationInfoEvent>(_onNavLocationInfoEvent);
  }

  @override
  Future<void> close() async {
    await super.close();
    await _onCurrentLocationSubscription?.cancel();
  }

  NavLocationInfo get currentTheme => state.navLocationInfo;

  Future<void> _onNavLocationInfoEvent(
      NavLocationInfoEvent event, Emitter<NavLocationInfoState> emit) async {
    NavLocationInfo navLocationInfo = NavLocationInfo(event.paginationInfo);
    Link selectedLink = state.selectedLink;
    if (navLocationInfo != state.navLocationInfo) {
      selectedLink =
          _LinkSelector(readerContext)._selectedLink(event.paginationInfo);
    }
    emit(NavLocationInfoState(navLocationInfo, selectedLink));
  }

  void _onCurrentLocationChanged(PaginationInfo paginationInfo) {
    add(NavLocationInfoEvent(paginationInfo));
  }
}

class _LinkSelector {
  final ReaderContext readerContext;

  _LinkSelector(this.readerContext);

  Link _selectedLink(PaginationInfo paginationInfo) {
    if (paginationInfo == null) {
      return null;
    }
    Link selectedTocItem;
    for (Link tocItem in readerContext.flattenedTableOfContents) {
      if (_isTocItemAfter(tocItem, paginationInfo)) {
        break;
      }
      selectedTocItem = tocItem;
    }
    return selectedTocItem;
  }

  bool _isTocItemAfter(Link tocItem, PaginationInfo paginationInfo) {
    if (paginationInfo.openPages.isEmpty) {
      return false;
    }
    int positionSpineItemPageIndex =
        paginationInfo.openPages[0].spineItemPageIndex;
    int positionSpineItemIndex = paginationInfo.openPages[0].spineItemIndex;
    int spineItemIndex = readerContext.tableOfContentsToSpineItemIndex[tocItem];
    if (spineItemIndex > positionSpineItemIndex) {
      return true;
    }
    if (spineItemIndex == positionSpineItemIndex) {
      int pageIndex =
          paginationInfo.elementIdsWithPageIndex[tocItem.elementId] ?? 0;
      return positionSpineItemPageIndex < pageIndex;
    }
    return false;
  }
}

@immutable
class NavLocationInfoEvent extends Equatable {
  final PaginationInfo paginationInfo;

  const NavLocationInfoEvent([this.paginationInfo]);

  @override
  List<Object> get props => [];

  @override
  String toString() =>
      'NavLocationInfoEvent { paginationInfo: $paginationInfo }';
}

@immutable
class NavLocationInfoState extends Equatable {
  final NavLocationInfo navLocationInfo;
  final Link selectedLink;

  const NavLocationInfoState([this.navLocationInfo, this.selectedLink]);

  @override
  List<Object> get props => [navLocationInfo];

  @override
  String toString() =>
      'NavLocationInfoState { navLocationInfo: $navLocationInfo }';
}
