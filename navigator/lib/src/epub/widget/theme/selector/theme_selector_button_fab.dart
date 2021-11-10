// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_framework/styles/common_sizes.dart';

class ThemeSelectorButtonFab extends StatefulWidget {
  final bool visible;
  final SvgAssets svgAssets;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const ThemeSelectorButtonFab({
    Key key,
    this.visible,
    this.svgAssets,
    this.onPressed,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeSelectorButtonFabState();
}

class ThemeSelectorButtonFabState extends State<ThemeSelectorButtonFab>
    with SingleTickerProviderStateMixin {
  final double size = CommonSizes.iconSize;
  final Duration duration = const Duration(milliseconds: 150);
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.animateTo(widget.visible ? 1.0 : 0.0);
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: widget.backgroundColor,
        onPressed: widget.onPressed,
        child: Padding(
          padding: CommonSizes.smallPadding,
          child: widget.svgAssets.widget(),
        ),
      ),
    );
  }

  Widget _buildChildren(BuildContext context, Widget child) => Container(
        alignment: Alignment.center,
        height: size,
        width: size,
        child: SizedBox(
          height: size * _controller.value,
          width: size * _controller.value,
          child: child,
        ),
      );
}
