// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/css/reader_theme.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/widgets/animations/animated_button.dart';
import 'package:navigator/src/epub/widget/theme/selector/theme_selector_button_fab.dart';
import 'package:navigator/src/epub/widget/theme/theme_preview_button.dart';

typedef ThemeSelectorCallback = void Function(
    BuildContext context, ReaderTheme readerTheme);

class ThemeSelectorButton extends StatelessWidget {
  static const double themeButtonSize = CommonSizes.large6Margin;
  static const double selectedThemeButtonSize = 84.0;
  static const double fabSize = CommonSizes.iconSize;
  static const double boxSize = themeButtonSize + fabSize / 2;
  final ReaderTheme readerTheme;
  final ThemeSelectorCallback applyThemeCallback;
  final ValueChanged<ReaderTheme> editThemeCallback;
  final ValueChanged<ReaderTheme> duplicateThemeCallback;
  final ValueChanged<ReaderTheme> deleteCallback;
  final bool isSelected;

  const ThemeSelectorButton({
    Key key,
    @required this.readerTheme,
    @required this.applyThemeCallback,
    @required this.editThemeCallback,
    @required this.duplicateThemeCallback,
    @required this.deleteCallback,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          SizedBox(
            width: boxSize,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: CommonSizes.defaultMargin),
                    child: GestureDetector(
                      onTap: () => applyThemeCallback(context, readerTheme),
                      child: AnimatedButton(
                        child: ThemePreviewButton(
                          readerTheme: readerTheme,
                          size: isSelected
                              ? selectedThemeButtonSize
                              : themeButtonSize,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  child: _buildDuplicateFAB(
                      context, readerTheme.duplicable && isSelected),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: _buildEditFAB(
                      context, readerTheme.editable && isSelected),
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  left: 0.0,
                  child: _buildDeleteFAB(
                      context, readerTheme.editable && isSelected),
                ),
              ],
            ),
          ),
          Padding(
            padding: CommonSizes.smallPadding,
            child: Text(
              readerTheme.name,
              style: Theme.of(context).textTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
        ],
      );

  Widget _buildDuplicateFAB(BuildContext context, bool visible) => _buildFAB(
      context,
      visible,
      SvgAssets.copyPlain,
      null,
      () => duplicateThemeCallback(readerTheme));

  Widget _buildEditFAB(BuildContext context, bool visible) => _buildFAB(context,
      visible, SvgAssets.annotate, null, () => editThemeCallback(readerTheme));

  Widget _buildDeleteFAB(BuildContext context, bool visible) {
    ThemeBloc themeBloc = BlocProvider.of(context);
    return _buildFAB(
        context,
        visible,
        SvgAssets.deletePlain,
        themeBloc.currentTheme.secondaryColor.colorLight,
        () => deleteCallback(readerTheme));
  }

  Widget _buildFAB(
    BuildContext context,
    bool visible,
    SvgAssets svgAssets,
    Color backgroundColor,
    VoidCallback onPressed,
  ) =>
      ThemeSelectorButtonFab(
        visible: visible,
        svgAssets: svgAssets,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
      );
}
