// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_commons/theme/theme.dart';
import 'package:ui_commons/theme/theme_bloc.dart';

class ThemeEditorBackButton extends StatelessWidget {
  final VoidCallback quitAction;

  const ThemeEditorBackButton({
    Key key,
    @required this.quitAction,
  })  : assert(quitAction != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    MantanoTheme bookariTheme =
        BlocProvider.of<ThemeBloc>(context).currentTheme;
    return Material(
      type: MaterialType.transparency,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: quitAction,
        splashColor: DefaultColors.bgTranspDefaultColor,
        highlightColor: DefaultColors.bgTranspDefaultColor,
        customBorder: const CircleBorder(),
        child: Container(
          alignment: Alignment.center,
          height: 48.0,
          width: 48.0,
          padding: const EdgeInsets.fromLTRB(10.0, 12.0, 14.0, 12.0),
          child: SvgAssets.arrowLeft.widget(
            color: bookariTheme.primaryColor.colorLight,
          ),
        ),
      ),
    );
  }
}
