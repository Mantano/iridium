// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_framework/widgets/update_states.dart';
import 'package:utils/extensions/duration_format.dart';

class DurationTitle extends StatefulWidget {
  final UpdateStateController updateStateController;
  final Duration duration;

  const DurationTitle({Key key, this.duration, this.updateStateController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DurationTitleState();
}

class _DurationTitleState extends UpdateState<DurationTitle> {
  @override
  UpdateStateController get updateStateController =>
      widget.updateStateController;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.duration.print(),
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: DefaultColors.videoControlsLabelColor,
                ),
          ),
        ),
      );
}
