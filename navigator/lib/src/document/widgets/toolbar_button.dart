// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/styles/default_sizes.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/widgets/animations/animated_button.dart';

class ToolbarButton extends StatelessWidget {
  final SvgAssets svgAsset;
  final VoidCallback onPressed;
  final Color background;
  final Color color;
  final double elevation;
  final double padding;
  final double iconSize;

  const ToolbarButton({
    Key key,
    this.svgAsset,
    this.onPressed,
    this.background = DefaultColors.readerToolbarBottomBtnsBgColor,
    this.color = DefaultColors.toolbarLabelColor,
    this.elevation = 0.0,
    this.padding = DefaultSizes.toolbarBtnDefaultPadding,
    this.iconSize = CommonSizes.small1IconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedButton(
        child: Material(
          shape: const CircleBorder(),
          color: background,
          elevation: elevation,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            splashColor: DefaultColors.bgTranspDefaultColor,
            highlightColor: DefaultColors.bgTranspDefaultColor,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: svgAsset.widget(
                height: iconSize,
                width: iconSize,
                color: color,
              ),
            ),
          ),
        ),
      );
}
