// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigator/src/epub/widget/mask_bloc.dart';

class Mask extends StatefulWidget {
  final MaskBloc _maskBloc;

  const Mask(this._maskBloc, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MaskWidgetState();
}

class MaskWidgetState extends State<Mask> {
  MaskBloc get _maskBloc => widget._maskBloc;

  @override
  Widget build(BuildContext context) => BlocBuilder(
        bloc: _maskBloc,
        builder: (BuildContext context, MaskState state) => Visibility(
          visible: state.visibility,
          child: Container(
//        color: Theme.of(context).scaffoldBackgroundColor,
            color: Theme.of(context).highlightColor,
          ),
        ),
      );
}
