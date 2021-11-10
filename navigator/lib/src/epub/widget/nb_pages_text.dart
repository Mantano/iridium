// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_framework/widgets/update_states.dart';

class NbPagesText extends StatefulWidget {
  final UpdateStateController updateStateController;
  final int nbPages;

  const NbPagesText({Key key, this.nbPages, this.updateStateController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _NbPagesTextState();
}

class _NbPagesTextState extends UpdateState<NbPagesText> {
  @override
  UpdateStateController get updateStateController =>
      widget.updateStateController;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          alignment: Alignment.center,
          child: Text(
            widget.nbPages.toString(),
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: DefaultColors.toolbarLabelColor,
                ),
          ),
        ),
      );
}
