// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/css/reader_theme.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_framework/styles/common_sizes.dart';

class ThemePreviewButton extends StatelessWidget {
  final ReaderTheme readerTheme;
  final double size;

  const ThemePreviewButton({
    Key key,
    this.readerTheme,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.circle,
        elevation: CommonSizes.popupElevation,
        color: _backgroundColor(context),
        child: Container(
          decoration: _decoration,
          alignment: Alignment.center,
          height: size,
          width: size,
          child: Text(
            "Aa",
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: _textColor,
                ),
          ),
        ),
      );

  Decoration get _decoration => readerTheme.backgroundColor == null
      ? BoxDecoration(
          color: Colors.white30,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3.0,
            style: BorderStyle.solid,
          ),
        )
      : null;

  Color get _textColor => readerTheme.textColor ?? Colors.white;

  Color _backgroundColor(BuildContext context) {
    ThemeBloc themeBloc = BlocProvider.of<ThemeBloc>(context);
    return readerTheme.backgroundColor ??
        themeBloc.currentTheme.secondaryColor.colorLight.withOpacity(0.5);
  }
}
