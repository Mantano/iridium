// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/css/reader_theme.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/widgets/dialogs/material_picker_dialog.dart';
import 'package:navigator/src/epub/bloc/reader_theme_bloc.dart';
import 'package:navigator/src/epub/widget/theme/theme_preview_button.dart';

class ThemeEditorPreview extends StatefulWidget {
  final ReaderTheme readerTheme;

  const ThemeEditorPreview({
    Key key,
    @required this.readerTheme,
  })  : assert(readerTheme != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeEditorPreviewState();
}

class ThemeEditorPreviewState extends State<ThemeEditorPreview> {
  static const double themeButtonSize = 86.0;
  static const double colorPickerButtonSize = 48.0;
  static const double boxSize = themeButtonSize + colorPickerButtonSize / 2;
  final GlobalKey _themePreviewKey = GlobalKey();
  final GlobalKey _themeTextColorKey = GlobalKey();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: boxSize,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                MaterialPickerDialog.showDialog(context, _themePreviewKey,
                    widget.readerTheme.backgroundColor, (color) {
                  setState(() {
                    widget.readerTheme.backgroundColor = color;
                    BlocProvider.of<ReaderThemeBloc>(context)
                        .add(ReaderThemeEvent(widget.readerTheme));
                  });
                });
              },
              child: ThemePreviewButton(
                key: _themePreviewKey,
                readerTheme: widget.readerTheme,
                size: themeButtonSize,
              ),
            ),
            Positioned(
              bottom: 0.0,
              right: 8.0,
              child: GestureDetector(
                onTap: () {
                  MaterialPickerDialog.showDialog(
                      context, _themeTextColorKey, widget.readerTheme.textColor,
                      (color) {
                    setState(() {
                      widget.readerTheme.textColor = color;
                      BlocProvider.of<ReaderThemeBloc>(context)
                          .add(ReaderThemeEvent(widget.readerTheme));
                    });
                  });
                },
                child: Material(
                  key: _themeTextColorKey,
                  type: MaterialType.circle,
                  elevation: CommonSizes.popupElevation,
                  color: widget.readerTheme.textColor,
                  child: Container(
                    alignment: Alignment.center,
                    height: colorPickerButtonSize,
                    width: colorPickerButtonSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
