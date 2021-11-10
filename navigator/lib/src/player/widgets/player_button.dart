// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_framework/styles/common_sizes.dart';

class PlayerButton extends StatelessWidget {
  final SvgAssets svgAsset;
  final VoidCallback onPressed;

  const PlayerButton({
    Key key,
    this.svgAsset,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        shape: const CircleBorder(),
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: CommonSizes.smallPadding,
            child: svgAsset.widget(
              height: CommonSizes.small1IconSize,
              color: DefaultColors.videoControlsLabelColor,
            ),
          ),
        ),
      );
}
