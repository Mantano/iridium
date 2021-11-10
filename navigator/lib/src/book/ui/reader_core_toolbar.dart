// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/styles/default_sizes.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_commons/widgets/document_info/display_document_info_widget.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/utils/state.dart';
import 'package:ui_framework/widgets/animations/collapsible_panel.dart';
import 'package:ui_framework/widgets/common_slider_theme.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/document/widgets/toolbar_button.dart';
import 'package:navigator/src/epub/model/commands.dart';
import 'package:navigator/src/epub/widget/nb_pages_text.dart';

class ReaderCoreToolbar extends StatefulWidget {
  final ReaderContext readerContext;
  final StreamController<int> pageNumberController;
  final CollapsiblePanelController collapsibleCustomizePanelController;
  final void Function() onPrevious;
  final void Function() onNext;
  final int lastPage;

  const ReaderCoreToolbar({
    Key key,
    this.readerContext,
    this.pageNumberController,
    this.collapsibleCustomizePanelController,
    this.onPrevious,
    this.onNext,
    this.lastPage,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReaderCoreToolbarState();
}

class ReaderCoreToolbarState extends State<ReaderCoreToolbar> {
  static const double firstRowFraction = 2.0;
  static const double secondRowFraction = 3.0;
  static const double allRowsFraction = firstRowFraction + secondRowFraction;
  static const double defaultInnerToolbarHeight =
      CommonSizes.iconSize * allRowsFraction;
  static const double defaultToolbarHeight =
      defaultInnerToolbarHeight + 3 * CommonSizes.small2Margin;
  static const double firstRowHeight =
      defaultInnerToolbarHeight * firstRowFraction / allRowsFraction;
  static const double secondRowHeight =
      defaultInnerToolbarHeight * secondRowFraction / allRowsFraction;

  ReaderContext get readerContext => widget.readerContext;

  StreamController<int> get pageNumberController => widget.pageNumberController;

  CollapsiblePanelController get collapsibleCustomizePanelController =>
      widget.collapsibleCustomizePanelController;

  Function() get onPrevious => widget.onPrevious;

  Function() get onNext => widget.onNext;

  int get lastPage => widget.lastPage;

  ThemeBloc get themeBloc => BlocProvider.of<ThemeBloc>(context);

  @override
  Widget build(BuildContext context) => _buildCoreToolbar(context);

  Widget _buildCoreToolbar(BuildContext context) => Container(
        padding: const EdgeInsets.only(top: CommonSizes.small2Margin),
        height: defaultToolbarHeight + viewPaddingBottom,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CommonSizes.large2Margin,
            vertical: CommonSizes.small2Margin,
          ),
          decoration: themeBloc.currentTheme.primaryBoxDecoration.copyWith(
            boxShadow: <BoxShadow>[
              const BoxShadow(
                offset: Offset(0.0, 4.0),
                blurRadius: CommonSizes.standardElevation,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: firstRowHeight,
                child: _firstRow(context),
              ),
              SizedBox(
                height: secondRowHeight,
                child: _secondRow(context),
              ),
            ],
          ),
        ),
      );

  Widget _firstRow(BuildContext context) => Row(
        children: <Widget>[
          ToolbarButton(
            svgAsset: SvgAssets.previousSection,
            background: DefaultColors.readerToolbarTopBtnsBgColor,
            padding: DefaultSizes.toolbarBtnBigPadding,
            iconSize: CommonSizes.small3IconSize,
            onPressed: onPrevious,
          ),
          const SizedBox(width: 8.0),
          NbPagesText(
            nbPages: lastPage,
          ),
          Expanded(
            child: CommonSliderTheme(
              child: Slider(
                onChanged: (value) => pageNumberController.add(value.toInt()),
                onChangeEnd: (value) {
                  readerContext.execute(GoToPageCommand(value.toInt()));
                },
                min: 1.0,
                max: readerContext.book.nbPages.toDouble(),
                value: lastPage.toDouble(),
                activeColor: themeBloc.currentTheme.secondaryColor.colorDark,
                inactiveColor: DefaultColors.inactive,
              ),
            ),
          ),
          NbPagesText(
            nbPages: readerContext.book.nbPages,
          ),
          const SizedBox(width: 8.0),
          ToolbarButton(
            svgAsset: SvgAssets.nextSection,
            background: DefaultColors.readerToolbarTopBtnsBgColor,
            padding: DefaultSizes.toolbarBtnBigPadding,
            iconSize: CommonSizes.small3IconSize,
            onPressed: onNext,
          ),
        ],
      );

  Widget _secondRow(BuildContext context) {
    List<Widget> children = [
      ToolbarButton(
        svgAsset: SvgAssets.info,
        onPressed: () => DisplayDocumentInfo.of(context)
            .display(context, readerContext.book),
      )
    ];
    if (readerContext.hasCustomize) {
      children.add(const Spacer());
      children.add(ToolbarButton(
        background: collapsibleCustomizePanelController.visible
            ? Colors.black26
            : DefaultColors.readerToolbarBottomBtnsBgColor,
        svgAsset: SvgAssets.customize,
        onPressed: () => setState(() {
          collapsibleCustomizePanelController.toggle();
        }),
      ));
    }
    if (readerContext.hasPlay) {
      children.add(const Spacer());
      children.add(ToolbarButton(
        svgAsset: SvgAssets.playerPlay,
        onPressed: () {
          Fimber.d("TODO onPressed: play");
        },
      ));
    }
    if (readerContext.hasNavigate) {
      children.add(const Spacer());
      children.add(ToolbarButton(
        svgAsset: SvgAssets.navigate,
        onPressed: Scaffold.of(context).openEndDrawer,
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
