// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ui_framework/widgets/common_page_view_indicator.dart';

class ThemePageViewIndicator extends StatelessWidget {
  final StreamController<int> pageIndexController;
  final ValueNotifier<int> pageIndexNotifier;

  const ThemePageViewIndicator({
    Key key,
    this.pageIndexController,
    this.pageIndexNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: 0.5,
        child: StreamBuilder<int>(
            initialData: 1,
            stream: pageIndexController.stream,
            builder: (context, snapshot) => CommonPageViewIndicator(
                  key: ValueKey(snapshot.data),
                  pageIndexNotifier: pageIndexNotifier,
                  length: snapshot.data,
                )),
      );
}
