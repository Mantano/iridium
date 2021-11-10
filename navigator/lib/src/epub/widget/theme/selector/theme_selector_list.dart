// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/css/reader_theme.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/widgets/dialogs/delete_dialog.dart';
import 'package:navigator/src/epub/widget/theme/bloc/reader_theme_list_bloc.dart';
import 'package:navigator/src/epub/widget/theme/bloc/reader_theme_selection_bloc.dart';
import 'package:navigator/src/epub/widget/theme/theme_page_view_indicator.dart';
import 'package:navigator/src/epub/widget/theme/theme_selector_button.dart';

class ThemeSelectorList extends StatefulWidget {
  final ReaderThemeSelectionBloc readerThemeSelectionBloc;
  final VoidCallback goToThemesList;
  final VoidCallback goToEditTheme;
  final ThemeSelectorCallback applyThemeCallback;

  const ThemeSelectorList({
    Key key,
    @required this.readerThemeSelectionBloc,
    @required this.goToThemesList,
    @required this.goToEditTheme,
    @required this.applyThemeCallback,
  })  : assert(readerThemeSelectionBloc != null),
        assert(goToThemesList != null),
        assert(goToEditTheme != null),
        assert(applyThemeCallback != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeSelectorListState();
}

class ThemeSelectorListState extends State<ThemeSelectorList>
    with AutomaticKeepAliveClientMixin<ThemeSelectorList> {
  static const int nbItemsPerLine = 3;
  static const int nbLines = 2;
  static const int nbItemsPerPage = nbItemsPerLine * nbLines;

  PageController themesController;
  StreamController<int> pageIndexController;
  ValueNotifier<int> pageIndexNotifier;
  ReaderTheme selectedReaderTheme;
  List<ReaderTheme> _themes;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    themesController = PageController();
    pageIndexController = StreamController.broadcast();
    pageIndexNotifier = ValueNotifier<int>(0);
    _themes = [];
  }

  @override
  void dispose() {
    super.dispose();
    pageIndexController.close();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ReaderThemeListBloc readerThemeListBloc =
        BlocProvider.of<ReaderThemeListBloc>(context);
    return StreamBuilder(
      initialData: const <ReaderTheme>[],
      stream: readerThemeListBloc.readerThemeRepository.all(),
      builder:
          (BuildContext context, AsyncSnapshot<List<ReaderTheme>> snapshot) {
        if (snapshot.hasData) {
          _themes = snapshot.data;
          int nbPages = max(1, (_themes.length / nbItemsPerPage).ceil());
          pageIndexController.add(nbPages);
          return Column(
            children: <Widget>[
              const SizedBox(
                height: 22.0,
              ),
              _buildPageView(_themes, nbPages),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: CommonSizes.defaultMargin),
                child: _buildPaginationAndFAB(),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }

  void _goToEditNewTheme() {
    String name = _generateName('New', _themes);
    _goToEditTheme(selectedReaderTheme, ReaderTheme.createNew(name));
  }

  void _goToEditSelectedTheme(ReaderTheme readerTheme) {
    _goToEditTheme(readerTheme, readerTheme);
  }

  void _goToDuplicateTheme(ReaderTheme readerTheme) {
    String name = _generateName(readerTheme.name, _themes);
    _goToEditTheme(readerTheme, readerTheme.createDuplicate(name));
  }

  void _goToEditTheme(ReaderTheme readerTheme, ReaderTheme readerThemeToEdit) {
    widget.readerThemeSelectionBloc
        .add(ReaderThemeEditionEvent(readerTheme, readerThemeToEdit));
    widget.goToEditTheme();
  }

  Widget _buildPageView(List<ReaderTheme> themes, int nbPages) => BlocBuilder(
      bloc: widget.readerThemeSelectionBloc,
      builder: (BuildContext context, ReaderThemeSelectionState state) {
        selectedReaderTheme = state.readerTheme;
        return FutureBuilder<List<ReaderTheme>>(
            future: _sortThemes(themes),
            initialData: themes,
            builder: (BuildContext context,
                    AsyncSnapshot<List<ReaderTheme>> snapshot) =>
                Expanded(
                  child: PageView.builder(
                    controller: themesController,
                    itemCount: nbPages,
                    onPageChanged: (index) => pageIndexNotifier.value = index,
                    itemBuilder: (BuildContext context, int pageIndex) =>
                        Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: CommonSizes.defaultMargin),
                      child: Table(
                        children: [0, 1]
                            .map((lineIndex) => TableRow(
                                  children: _findThemes(snapshot.data ?? [],
                                          pageIndex, lineIndex)
                                      .map((readerTheme) => _buildThemeButton(
                                          context, readerTheme))
                                      .toList(),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ));
      });

  Container _buildThemeButton(BuildContext context, ReaderTheme readerTheme) {
    if (readerTheme == null) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.only(top: CommonSizes.defaultMargin),
      child: ThemeSelectorButton(
        readerTheme: readerTheme,
        applyThemeCallback: widget.applyThemeCallback,
        editThemeCallback: _goToEditSelectedTheme,
        duplicateThemeCallback: _goToDuplicateTheme,
        deleteCallback: _onDeletePressed,
        isSelected: readerTheme.id == selectedReaderTheme?.id,
      ),
    );
  }

  void _onDeletePressed(ReaderTheme readerTheme) {
    ThemeBloc themeBloc = BlocProvider.of<ThemeBloc>(context);
    DeleteDialog.showDialog(
        context: context,
//        keyButton: _keyButton,
        onDeleteConfirmed: () => _onDeleteConfirmed(readerTheme),
        icon: SvgAssets.deletePlain.widget(),
        color: themeBloc.currentTheme.secondaryColor.colorDark);
  }

  void _onDeleteConfirmed(ReaderTheme readerTheme) {
    ReaderThemeListBloc readerThemeListBloc =
        BlocProvider.of<ReaderThemeListBloc>(context);
    readerThemeListBloc.add(ReaderThemeDeleteEvent(readerTheme));
  }

  Container _buildPaginationAndFAB() => Container(
        height: 96.0,
        padding: const EdgeInsets.only(top: CommonSizes.defaultMargin),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                Container(),
                ThemePageViewIndicator(
                  pageIndexController: pageIndexController,
                  pageIndexNotifier: pageIndexNotifier,
                ),
                _buildFAB(),
              ],
            ),
          ],
        ),
      );

  SizedBox _buildFAB() => SizedBox(
        height: CommonSizes.large1IconSize,
        width: CommonSizes.large1IconSize,
        child: FloatingActionButton(
          heroTag: null,
          onPressed: _goToEditNewTheme,
          child: SvgAssets.add.widget(),
        ),
      );

  Iterable<ReaderTheme> _findThemes(
      List<ReaderTheme> themes, int pageIndex, int lineIndex) {
    int start = nbItemsPerPage * pageIndex + nbItemsPerLine * lineIndex;
    int end = min(start + nbItemsPerLine, themes.length);
    List<ReaderTheme> list =
        (start < themes.length) ? themes.sublist(start, end) : [];
    list.length = nbItemsPerLine;
    return list;
  }

  String _generateName(String name, List<ReaderTheme> themes) {
    String generated = name;
    int index = 1;
    bool stop = false;
    while (!stop) {
      ReaderTheme match = themes.firstWhere((theme) => generated == theme.name,
          orElse: () => null);
      stop = match == null;
      if (!stop) {
        generated = "$name$index";
        index++;
      }
    }
    return generated;
  }

  Future<List<ReaderTheme>> _sortThemes(List<ReaderTheme> themes) async {
    themes.sort();
    return themes;
  }
}
