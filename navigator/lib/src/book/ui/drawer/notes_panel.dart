// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/model.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:navigator/src/document/ui/drawer/annotations_panel.dart';
import 'package:navigator/src/document/ui/drawer/reader_panel.dart';

class NotesPanel extends AnnotationsPanel {
  const NotesPanel(AnnotationsBloc annotationsBloc, Book book, {Key key})
      : super(annotationsBloc, AnnotationKind.highlight, book, key: key);

  @override
  State<StatefulWidget> createState() => NotesPanelState();

  @override
  Widget buildIcon() => SvgAssets.notes.widget();
}

class NotesPanelState extends ReaderPanelState<NotesPanel> {
  @override
  void initState() {
    super.initState();
    widget.annotationsBloc.add(LoadDocuments());
  }

  @override
  Decoration getDecoration(BuildContext context) {
    ThemeBloc themeBloc = BlocProvider.of<ThemeBloc>(context);
    return themeBloc.currentTheme.getListBoxDecoration(context);
  }

  @override
  Widget buildPanel(BuildContext context) => Container();
}
