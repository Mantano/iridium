// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/i18n.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/model.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_commons/widgets/document_tile/document_tile.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/widgets/animations/animated_baseline.dart';
import 'package:ui_framework/widgets/animations/animated_button.dart';
import 'package:ui_framework/widgets/dialogs/delete_dialog.dart';
import 'package:ui_framework/widgets/multi_select.dart';
import 'package:ui_framework/widgets/slide_menu.dart';
import 'package:ui_framework/widgets/text_field_utils.dart';
import 'package:navigator/src/document/ui/drawer/reader_panel.dart';

typedef OnOpenAnnotation = void Function(Annotation);

enum BookmarkListType { book, video }

class _BookBookmarkListTile extends BookmarkListTile {
  const _BookBookmarkListTile({
    Key key,
    Annotation annotation,
    CustomMultiSelectController multiSelectController,
    OnOpenAnnotation onOpenAnnotation,
  }) : super._(
          key: key,
          annotation: annotation,
          multiSelectController: multiSelectController,
          onOpenAnnotation: onOpenAnnotation,
        );

  @override
  State<StatefulWidget> createState() => BookBookmarkListTileState();
}

class _VideoBookmarkListTile extends BookmarkListTile {
  const _VideoBookmarkListTile({
    Key key,
    Annotation annotation,
    CustomMultiSelectController multiSelectController,
    OnOpenAnnotation onOpenAnnotation,
  }) : super._(
          key: key,
          annotation: annotation,
          multiSelectController: multiSelectController,
          onOpenAnnotation: onOpenAnnotation,
        );

  @override
  State<StatefulWidget> createState() => VideoBookmarkListTileState();
}

abstract class BookmarkListTile extends DocumentTile<Annotation> {
  final OnOpenAnnotation onOpenAnnotation;

  const BookmarkListTile._({
    Key key,
    Annotation annotation,
    CustomMultiSelectController multiSelectController,
    this.onOpenAnnotation,
  }) : super(
          key: key,
          document: annotation,
          multiSelectController: multiSelectController,
        );

  factory BookmarkListTile.create({
    Key key,
    Annotation annotation,
    CustomMultiSelectController multiSelectController,
    BookmarkListType type,
    OnOpenAnnotation onOpenAnnotation,
  }) {
    if (type == BookmarkListType.book) {
      return _BookBookmarkListTile(
        key: key,
        annotation: annotation,
        multiSelectController: multiSelectController,
        onOpenAnnotation: onOpenAnnotation,
      );
    }
    return _VideoBookmarkListTile(
      key: key,
      annotation: annotation,
      multiSelectController: multiSelectController,
      onOpenAnnotation: onOpenAnnotation,
    );
  }
}

class BookBookmarkListTileState extends BookmarkListTileState {
  @override
  CustomMultiSelectController get multiSelectController =>
      widget.multiSelectController;

  @override
  Widget _buildTrailing() => Visibility(
        visible: !editing,
        child: Text(
          BookariLocalizations.of(context).page(document.page),
          style: _textStyle(context),
        ),
      );
}

class VideoBookmarkListTileState extends BookmarkListTileState {
  Locator _locator;

  @override
  CustomMultiSelectController get multiSelectController =>
      widget.multiSelectController;

  @override
  void initState() {
    super.initState();
    _locator = Locator.fromJsonString(widget.document.location);
  }

  @override
  Widget _buildTrailing() => Visibility(
        visible: !editing,
        child: Text(
          _locator.title,
          style: _textStyle(context),
        ),
      );
}

abstract class BookmarkListTileState
    extends DocumentTileState<Annotation, BookmarkListTile>
    with TickerProviderStateMixin {
  static const Duration animationDuration = Duration(milliseconds: 200);
  final GlobalKey _textFormKey = GlobalKey();
  final GlobalKey _editKey = GlobalKey();
  final GlobalKey _deleteKey = GlobalKey();
  ThemeBloc _themeBloc;
  AnimatedBaselineController _animatedBaselineController;
  SlideMenuController _slideMenuController;
  TextEditingController _textFieldController;
  FocusNode _textFieldFocusNode;
  bool editing;

  AnnotationsBloc get annotationsBloc =>
      BlocProvider.of<AnnotationsBloc>(context);

  @override
  void initState() {
    super.initState();
    _themeBloc = BlocProvider.of<ThemeBloc>(context);
    _animatedBaselineController = AnimatedBaselineController();
    _slideMenuController = SlideMenuController();
    _textFieldController = TextEditingController(text: document.title ?? '');
    _textFieldFocusNode = FocusNode();
    editing = false;
    _textFieldFocusNode.addListener(() {
      if (!_textFieldFocusNode.hasFocus && editing) {
        _onValidTitle();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textFieldController?.dispose();
    _textFieldFocusNode?.dispose();
  }

  @override
  void onLongPress() => _onEditPressed();

  @override
  Widget buildItem(BuildContext context) => SlideMenu(
        slideMenuController: _slideMenuController,
        decoration: _themeBloc.currentTheme.secondaryBoxDecoration,
        menuItems: (!editing) ? _buildMenuItems(_themeBloc) : [],
        elevation: (!editing) ? CommonSizes.standardElevation : 0.0,
        padding: 0.0,
        size: CommonSizes.large1IconSize,
        itemColorBackground: _themeBloc.currentTheme.primaryColor.colorLight,
        child: _buildBookmarkItem(context),
      );

  Widget _buildBookmarkItem(BuildContext context) => SizedBox.expand(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: (!editing) ? () => widget.onOpenAnnotation(document) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: ReaderPanelState.paddingValue),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        _buildDisplayText(),
                        _buildTextField(),
                        NotificationListener<SizeChangedLayoutNotification>(
                          onNotification: (notification) {
                            _animatedBaselineController.refreshSize();
                            return true;
                          },
                          child: SizeChangedLayoutNotifier(
                            child: _buildBaseline(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: CommonSizes.small2Margin,
                  ),
                  _buildTrailing(),
                  _buildValidationButton(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildDisplayText() => Visibility(
        visible: !editing,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            document.smartTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: _textStyle(context),
          ),
        ),
      );

  Widget _buildTextField() => Visibility(
        visible: editing,
        child: TextFormField(
          key: _textFormKey,
          decoration: TextFieldUtils.createInputDecoration(),
          controller: _textFieldController,
          focusNode: _textFieldFocusNode,
          style: _textStyle(context),
          maxLines: 1,
        ),
      );

  Widget _buildBaseline() => AnimatedBaseline(
        controller: _animatedBaselineController,
        textFormKey: _textFormKey,
        focusNode: _textFieldFocusNode,
        padding: const EdgeInsets.only(bottom: 12.0),
      );

  Widget _buildTrailing();

  Widget _buildValidationButton() => Visibility(
        visible: editing,
        child: AnimatedButton(
          child: InkWell(
            onTap: _onValidTitle,
            child: SvgAssets.annotate.widget(),
          ),
        ),
      );

  TextStyle _textStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyText2.copyWith(
            color: Colors.white,
          );

  List<MenuItem> _buildMenuItems(ThemeBloc _themeBloc) => <MenuItem>[
        MenuItem(
          onPressed: _onEditPressed,
          child: SvgAssets.annotate.widget(
            key: _editKey,
            color: Colors.white,
            height: CommonSizes.small1IconSize,
          ),
        ),
        MenuItem(
          onPressed: _onDeletePressed,
          child: SvgAssets.deletePlain.widget(
            key: _deleteKey,
            color: Colors.white,
            height: CommonSizes.small1IconSize,
          ),
        ),
      ];

  void _onEditPressed() {
    setState(() {
      _textFieldController.text = document.title;
      editing = true;
      Future.delayed(const Duration(milliseconds: 10),
          () => _textFieldFocusNode.requestFocus());
      _slideMenuController.closeMenu();
    });
  }

  void _onValidTitle() {
    Fimber.d("text: ${_textFieldController.value.text}");
    setState(() {
      document.title = _textFieldController.value.text;
      annotationsBloc.add(UpdateDocument(document));
      editing = false;
      _textFieldFocusNode.unfocus();
      _slideMenuController.closeMenu(animate: false);
    });
  }

  void _onDeletePressed() => DeleteDialog.showDialog(
        context: context,
        keyButton: _deleteKey,
        onDeleteConfirmed: _onDeleteConfirmed,
        icon: SvgAssets.deletePlain.widget(
          color: Colors.grey.shade500,
        ),
        color: Colors.white,
      );

  void _onDeleteConfirmed() {
    annotationsBloc.add(DeleteDocuments(items: [id]));
    setState(_slideMenuController.closeMenu);
  }
}
