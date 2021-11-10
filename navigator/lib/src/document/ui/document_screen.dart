// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:model/document/document.dart';
import 'package:ui_commons/document_opener/document_opener.dart';
import 'package:ui_commons/widgets/cover/cover_widget.dart';
import 'package:ui_framework/widgets/update_states.dart';

abstract class DocumentState<T extends StatefulWidget> extends UpdateState<T> {
  Widget _waitingScreen;

  Document get document;

  OnCloseDocument get onCloseDocument;

  Widget buildWaitingScreen(BuildContext context) => _waitingScreen ??= Stack(
        children: <Widget>[
          Hero(
            tag: document.id,
            child: CoverWidget(
              document,
              elevation: 0.0,
              generatesDefaultCover: false,
            ),
          ),
          buildProgressIndicator(context),
        ],
      );

  Widget buildProgressIndicator(BuildContext context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary),
        ),
      );
}
