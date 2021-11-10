// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/styles/default_sizes.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:navigator/src/document/widgets/toolbar_button.dart';

class CloseDocumentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color background;
  final Color color;

  const CloseDocumentButton({
    Key key,
    this.onPressed,
    this.background,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.centerLeft,
        height: DefaultSizes.toolbarHeight,
        padding: const EdgeInsets.only(left: 8.0),
        child: ToolbarButton(
          svgAsset: SvgAssets.close,
          background: background,
          color: color,
          padding: CommonSizes.small1Margin,
          elevation: CommonSizes.smallElevation,
          iconSize: CommonSizes.small2IconSize,
          onPressed: onPressed,
        ),
      );
}
