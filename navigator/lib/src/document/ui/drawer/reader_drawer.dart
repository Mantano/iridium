// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/model.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/utils/state.dart';
import 'package:ui_framework/widgets/animations/animated_button.dart';
import 'package:navigator/src/document/ui/drawer/reader_panel.dart';

abstract class ReaderDrawer<T extends FileDocument> extends StatefulWidget {
  final FileDocument document;

  const ReaderDrawer({
    Key key,
    @required this.document,
  }) : super(key: key);
}

class ReaderDrawerState<T extends FileDocument, U extends ReaderDrawer<T>>
    extends State<U> {
  @protected
  final List<ReaderPanel> readerPanels = [];
  int _currentPanelIndex;

  T get document => widget.document;

  ThemeBloc get themeBloc => BlocProvider.of<ThemeBloc>(context);

  double get bottomBarHeight => viewPaddingBottom + 80.0;

  @override
  void initState() {
    super.initState();
    _currentPanelIndex = 0;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<ReaderPanel>>(
      future: _futureReaderPanels(),
      initialData: const <ReaderPanel>[],
      builder:
          (BuildContext context, AsyncSnapshot<List<ReaderPanel>> snapshot) {
        if (!snapshot.hasData || snapshot.data.isEmpty) {
          return const SizedBox.shrink();
        }
        return Drawer(
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0.0,
                right: 0.0,
                height: bottomBarHeight,
                bottom: 0.0,
                child: Container(
                  decoration: themeBloc.currentTheme.secondaryBoxDecoration,
                  padding: const EdgeInsets.all(CommonSizes.small2Margin)
                      .add(EdgeInsets.only(bottom: viewPaddingBottom)),
                  child: Row(
                    children: buildIcons(snapshot.data),
                  ),
                ),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: bottomBarHeight,
                top: 0.0,
                child: Material(
                  elevation: CommonSizes.smallElevation,
                  child: IndexedStack(
                    index: _currentPanelIndex,
                    children: snapshot.data,
                  ),
                ),
              ),
            ],
          ),
        );
      });

  /// Filter panels to only display those that have something to display
  Future<List<ReaderPanel>> _futureReaderPanels() {
    Iterable<Future<ReaderPanel>> readerPanelsToDisplay =
        readerPanels.map((panel) async => (await panel.display) ? panel : null);
    return Future.wait(readerPanelsToDisplay)
        .then((value) => value.where((panel) => panel != null).toList());
  }

  List<Widget> buildIcons(List<ReaderPanel> readerPanelsToDisplay) =>
      readerPanelsToDisplay
          .asMap()
          .map((index, readerPanel) => MapEntry(
              index,
              Expanded(
                child: AnimatedButton(
                  child: Material(
                    type: MaterialType.transparency,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => setState(() => _currentPanelIndex = index),
                      splashColor: DefaultColors.bgTranspDefaultColor,
                      highlightColor: DefaultColors.bgTranspDefaultColor,
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: (_currentPanelIndex == index)
                              ? DefaultColors.bgTranspDefaultColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: readerPanel.buildIconWidget(),
                      ),
                    ),
                  ),
                ),
              )))
          .values
          .toList();
}
