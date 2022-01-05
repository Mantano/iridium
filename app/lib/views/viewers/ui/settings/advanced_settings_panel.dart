import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iridium_app/views/viewers/ui/settings/alignment_button.dart';
import 'package:iridium_app/views/viewers/ui/settings/settings_row.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class AdvancedSettingsPanel extends StatefulWidget {
  final ReaderContext readerContext;
  final ReaderThemeBloc readerThemeBloc;

  const AdvancedSettingsPanel({
    Key? key,
    required this.readerContext,
    required this.readerThemeBloc,
  }) : super(key: key);

  @override
  State<AdvancedSettingsPanel> createState() => _AdvancedSettingsPanelState();
}

class _AdvancedSettingsPanelState extends State<AdvancedSettingsPanel> {
  bool publisherDefaultValue = false;

  @override
  Widget build(BuildContext context) => BlocBuilder(
      bloc: widget.readerThemeBloc,
      builder: (BuildContext context, ReaderThemeState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPublishersDefaultRow(),
              _buildTextAlignmentRow(state),
              _buildPageMarginRow(state),
              _buildLineSpacingRow(state),
            ],
          ),
        );
      });

  Widget _buildPublishersDefaultRow() => SwitchListTile(
        title: const Text("Publisher's default"),
        value: publisherDefaultValue,
        onChanged: (value) => setState(() {
          publisherDefaultValue = value;
        }),
      );

  Widget _buildTextAlignmentRow(ReaderThemeState state) => Row(
        children: [TextAlign.left, TextAlign.justify]
            .map((textAlign) => Expanded(
                  child: AlignmentButton(
                    readerThemeBloc: widget.readerThemeBloc,
                    readerTheme: state.readerTheme,
                    textAlign: textAlign,
                  ),
                ))
            .toList(),
      );

  Widget _buildPageMarginRow(ReaderThemeState state) => SettingsRow<TextMargin>(
        readerThemeBloc: widget.readerThemeBloc,
        readerTheme: state.readerTheme,
        label: "Page Margins",
        value: state.readerTheme.textMargin,
        values: TextMargin.values,
      );

  Widget _buildLineSpacingRow(ReaderThemeState state) =>
      SettingsRow<LineHeight>(
        readerThemeBloc: widget.readerThemeBloc,
        readerTheme: state.readerTheme,
        label: "Line Height",
        value: state.readerTheme.lineHeight,
        values: LineHeight.values,
      );
}
