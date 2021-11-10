// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_framework/styles/common_sizes.dart';

abstract class ReaderPanel extends StatefulWidget {
  const ReaderPanel({Key key}) : super(key: key);

  Widget buildIconWidget() => SizedBox.fromSize(
        size: const Size.square(CommonSizes.small1IconSize),
        child: buildIcon(),
      );

  Widget buildIcon();

  Future<bool> get display async => true;
}

abstract class ReaderPanelState<T extends ReaderPanel> extends State<T> {
  static const double paddingValue = CommonSizes.large2Margin;
  static const EdgeInsets padding = EdgeInsets.only(
    left: paddingValue,
    right: paddingValue,
    bottom: paddingValue,
    top: paddingValue,
  );

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: getDecoration(context),
        child: SafeArea(
          child: buildPanel(context),
        ),
      );

  Decoration getDecoration(BuildContext context) {
    ThemeBloc themeBloc = BlocProvider.of<ThemeBloc>(context);
    return themeBloc.currentTheme.primaryBoxDecoration;
  }

  Widget buildPanel(BuildContext context);
}
