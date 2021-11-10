// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/css/line_height.dart';
import 'package:model/css/reader_theme.dart';
import 'package:model/css/text_align.dart' as css;
import 'package:model/css/text_margin.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/widgets/animations/animated_button.dart';
import 'package:ui_framework/widgets/custom_radio.dart';
import 'package:ui_framework/widgets/custom_text_field.dart';
import 'package:ui_framework/widgets/discrete_slider.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/epub/bloc/reader_theme_bloc.dart';
import 'package:navigator/src/epub/widget/theme/bloc/reader_theme_list_bloc.dart';
import 'package:navigator/src/epub/widget/theme/bloc/reader_theme_selection_bloc.dart';
import 'package:navigator/src/epub/widget/theme/editor/theme_editor_back_button.dart';
import 'package:navigator/src/epub/widget/theme/editor/theme_editor_dropdown.dart';
import 'package:navigator/src/epub/widget/theme/editor/theme_editor_preview.dart';
import 'package:navigator/src/epub/widget/theme/editor/theme_editor_text_field.dart';
import 'package:navigator/src/epub/widget/theme/theme_selector_button.dart';

class ThemeEditor extends StatefulWidget {
  final ReaderThemeSelectionBloc readerThemeSelectionBloc;
  final ThemeSelectorCallback applyThemeCallback;
  final VoidCallback quitAction;

  const ThemeEditor({
    Key key,
    @required this.readerThemeSelectionBloc,
    @required this.applyThemeCallback,
    @required this.quitAction,
  })  : assert(quitAction != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeEditorState();
}

class ThemeEditorState extends State<ThemeEditor>
    with AutomaticKeepAliveClientMixin<ThemeEditor> {
  static final Map<css.TextAlign, SvgAssets> cssAlignToSvgAsset = {
    css.TextAlign.left: SvgAssets.customizeAlignLeft,
    css.TextAlign.center: SvgAssets.customizeAlignCenter,
    css.TextAlign.right: SvgAssets.customizeAlignRight,
    css.TextAlign.justify: SvgAssets.customizeAlignJustified,
  };
  CustomTextFieldController _customTextFieldController;
  ReaderTheme _readerTheme;
  ReaderTheme _editableReaderTheme;
  StreamSubscription<String> _nameSubscription;

  StreamSubscription<bool> themeEditingSubscription;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _customTextFieldController = CustomTextFieldController();
    _nameSubscription = _customTextFieldController.nameStream
        .listen((name) => _editableReaderTheme?.name = name);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ReaderContext readerContext = ReaderContext.of(context);
      readerContext.openThemeEdition();
      themeEditingSubscription =
          readerContext.themeEditingStream.listen((themeEditing) {
        if (!themeEditing) {
          _saveTheme();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    themeEditingSubscription?.cancel();
    _nameSubscription?.cancel();
    _customTextFieldController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder(
        bloc: widget.readerThemeSelectionBloc,
        builder: (BuildContext context, ReaderThemeSelectionState state) {
          if (state is ReaderThemeEditionState) {
            _readerTheme = state.readerThemeToEdit;
            _editableReaderTheme =
                _editableReaderTheme ?? state.readerThemeToEdit.clone();
            return Stack(
              children: <Widget>[
                _buildBackButton(),
                _buildEditorPanel(),
              ],
            );
          }
          return Container();
        });
  }

  Positioned _buildBackButton() => Positioned(
        bottom: 0.0,
        top: 0.0,
        child: ThemeEditorBackButton(
          quitAction: _saveTheme,
        ),
      );

  Widget _buildEditorPanel() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildPreviewRow(),
            _buildAlignRow(),
            _buildMarginRow(),
            _buildLineHeightRow(),
            const SizedBox(
              height: CommonSizes.defaultMargin,
            ),
          ],
        ),
      );

  Widget _buildPreviewRow() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ThemeEditorPreview(
            readerTheme: _editableReaderTheme,
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: CommonSizes.defaultMargin,
                    top: 20.0,
                  ),
                  child: ThemeEditorTextField(
                    customTextFieldController: _customTextFieldController,
                    editableReaderTheme: _editableReaderTheme,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    left: CommonSizes.defaultMargin,
                    top: 70.0,
                    bottom: 10.0,
                  ),
                  child: StreamBuilder(
                      initialData: false,
                      stream: _customTextFieldController.errorStream,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.data) {
                          return const SizedBox.shrink();
                        }
                        return const ThemeEditorDropdown();
                      }),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildAlignRow() {
    CustomRadioController<css.TextAlign> radioController =
        CustomRadioController<css.TextAlign>(
            selectedModel: _editableReaderTheme.textAlign,
            onChangeCallback: (controller, model) {
              setState(() {
                _editableReaderTheme.textAlign = model;
                BlocProvider.of<ReaderThemeBloc>(context)
                    .add(ReaderThemeEvent(_editableReaderTheme));
              });
              controller.resetStates();
            });
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cssAlignToSvgAsset.entries
          .map((entry) => CustomRadioItem<css.TextAlign>(
              radioController: radioController,
              model: entry.key,
              builder: (BuildContext context, bool selected) => AnimatedButton(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? DefaultColors.bgTranspDefaultColor
                            : Colors.transparent,
                      ),
                      padding: CommonSizes.padding,
                      child: entry.value.widget(),
                    ),
                  )))
          .toList(),
    );
  }

  Widget _buildMarginRow() => _buildSliderRow(
      svgAsset: SvgAssets.customizeHorizontalMargin,
      discreteSlider: DiscreteSlider<TextMargin>(
        value: _editableReaderTheme.textMargin,
        items: TextMargin.values,
        onChangeCallback: (value) {
          _editableReaderTheme.textMargin = value;
          BlocProvider.of<ReaderThemeBloc>(context)
              .add(ReaderThemeEvent(_editableReaderTheme));
        },
      ));

  Widget _buildLineHeightRow() => _buildSliderRow(
      svgAsset: SvgAssets.customizeLineHeight,
      discreteSlider: DiscreteSlider<LineHeight>(
        value: _editableReaderTheme.lineHeight,
        items: LineHeight.values,
        onChangeCallback: (value) {
          _editableReaderTheme.lineHeight = value;
          BlocProvider.of<ReaderThemeBloc>(context)
              .add(ReaderThemeEvent(_editableReaderTheme));
        },
      ));

  Widget _buildSliderRow({
    SvgAssets svgAsset,
    Widget discreteSlider,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            svgAsset.widget(),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: CommonSizes.large2Margin),
                child: discreteSlider,
              ),
            ),
          ],
        ),
      );

  void _saveTheme() {
    _readerTheme.apply(_editableReaderTheme);
    ReaderThemeListBloc readerThemeListBloc =
        BlocProvider.of<ReaderThemeListBloc>(context);
    readerThemeListBloc.add(ReaderThemeSaveEvent(_readerTheme));
    Future.delayed(const Duration(milliseconds: 200),
        () => widget.applyThemeCallback(context, _readerTheme));
  }
}
