// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/css/reader_theme.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:navigator/src/book/ui/reader_core_toolbar.dart';
import 'package:navigator/src/epub/bloc/reader_theme_bloc.dart';
import 'package:navigator/src/epub/widget/theme/bloc/reader_theme_selection_bloc.dart';
import 'package:navigator/src/epub/widget/theme/editor/theme_editor.dart';
import 'package:navigator/src/epub/widget/theme/selector/theme_selector_list.dart';

class ThemeSelector extends StatefulWidget {
  static const double height = 380.0;
  final Stream<bool> stream;

  const ThemeSelector({
    Key key,
    @required this.stream,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeSelectorState();
}

class ThemeSelectorState extends State<ThemeSelector> {
  static const int nbItemsPerLine = 3;
  static const int nbLines = 2;
  static const int nbItemsPerPage = nbItemsPerLine * nbLines;
  PageController layoutController;
  ReaderThemeSelectionBloc readerThemeSelectionBloc;
  StreamSubscription<bool> _streamSubscription;

  @override
  void initState() {
    super.initState();
    layoutController = PageController();
    ReaderThemeBloc readerThemeBloc = BlocProvider.of<ReaderThemeBloc>(context);
    readerThemeSelectionBloc =
        ReaderThemeSelectionBloc(readerThemeBloc.defaultTheme);
    _streamSubscription = widget.stream.listen((visible) => _goToThemesList());
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ThemeBloc themeBloc = BlocProvider.of<ThemeBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: ThemeSelector.height,
          child: Stack(
            children: <Widget>[
              Container(
                decoration:
                    themeBloc.currentTheme.secondaryBoxDecoration.copyWith(
                  boxShadow: <BoxShadow>[
                    const BoxShadow(
                      offset: Offset(0.0, 4.0),
                      blurRadius: CommonSizes.standardElevation,
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(top: CommonSizes.defaultMargin),
              ),
              PageView.builder(
                controller: layoutController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return ThemeSelectorList(
                      readerThemeSelectionBloc: readerThemeSelectionBloc,
                      goToThemesList: _goToThemesList,
                      goToEditTheme: _goToEditTheme,
                      applyThemeCallback: _applyTheme,
                    );
                  }
                  return ThemeEditor(
                    readerThemeSelectionBloc: readerThemeSelectionBloc,
                    applyThemeCallback: _applyTheme,
                    quitAction: _goToThemesList,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          height: ReaderCoreToolbarState.defaultToolbarHeight - 8,
        ),
      ],
    );
  }

  void _goToThemesList() => _goToPage(0);

  void _goToEditTheme() => _goToPage(1);

  Future<void> _goToPage(int page) => layoutController.animateToPage(page,
      duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

  void _applyTheme(BuildContext context, ReaderTheme readerTheme) {
    _goToThemesList();
    readerThemeSelectionBloc.add(ReaderThemeSelectedEvent(readerTheme));
    BlocProvider.of<ReaderThemeBloc>(context)
        .add(ReaderThemeEvent(readerTheme));
  }
}
