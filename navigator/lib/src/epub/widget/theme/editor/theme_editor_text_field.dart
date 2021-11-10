// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/i18n.dart';
import 'package:model/css/reader_theme.dart';
import 'package:ui_framework/widgets/custom_text_field.dart';
import 'package:navigator/src/epub/widget/theme/bloc/reader_theme_list_bloc.dart';

class ThemeEditorTextField extends CustomTextField {
  final ReaderTheme editableReaderTheme;

  ThemeEditorTextField({
    Key key,
    @required CustomTextFieldController customTextFieldController,
    @required this.editableReaderTheme,
  })  : assert(customTextFieldController != null),
        assert(editableReaderTheme != null),
        super(
            key: key,
            customTextFieldController: customTextFieldController,
            defaultText: editableReaderTheme.name);

  @override
  State<StatefulWidget> createState() => ThemeEditorTextFieldState();
}

class ThemeEditorTextFieldState
    extends CustomTextFieldState<ThemeEditorTextField> {
  List<ReaderTheme> themes;

  ReaderTheme get editableReaderTheme => widget.editableReaderTheme;

  @override
  void initState() {
    super.initState();
    themes = <ReaderTheme>[];
  }

  @override
  Widget build(BuildContext context) {
    ReaderThemeListBloc readerThemeListBloc =
        BlocProvider.of<ReaderThemeListBloc>(context);
    return StreamBuilder(
        initialData: const <ReaderTheme>[],
        stream: readerThemeListBloc.readerThemeRepository.all(),
        builder:
            (BuildContext context, AsyncSnapshot<List<ReaderTheme>> snapshot) {
          if (snapshot.hasData) {
            themes = snapshot.data;
            return super.build(context);
          }
          return Container();
        });
  }

  @override
  void validateText(String value) {
    errorText = null;
    if (value.isEmpty) {
      errorText = BookariLocalizations.of(context).emptyText;
    } else {
      ReaderTheme existingReaderTheme = themes.firstWhere(
          (readerTheme) =>
              readerTheme.id != editableReaderTheme.id &&
              readerTheme.name == value,
          orElse: () => null);
      if (existingReaderTheme != null) {
        errorText = BookariLocalizations.of(context).duplicateName;
      }
    }
    setState(() => widget.customTextFieldController.errorText = errorText);
  }
}
