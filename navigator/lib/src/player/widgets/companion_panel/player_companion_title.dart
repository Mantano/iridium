// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/document/playable_document.dart';
import 'package:model/model.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_commons/widgets/document_info/document_info_panel.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/widgets/custom_editable_text.dart';

class PlayerCompanionTitle extends StatefulWidget {
  final PlayableDocument playableDocument;
  final EdgeInsetsGeometry padding;

  const PlayerCompanionTitle(
      {Key key, this.playableDocument, this.padding = CommonSizes.padding})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PlayerCompanionTitleState();
}

class PlayerCompanionTitleState extends State<PlayerCompanionTitle> {
  bool _expanded = false;

  ThemeBloc get themeBloc => BlocProvider.of<ThemeBloc>(context);

  FileDocumentsBloc get fileDocumentsBloc =>
      BlocProvider.of<FileDocumentsBloc>(context);

  @override
  Widget build(BuildContext context) => ExpansionPanelList(
        animationDuration: const Duration(seconds: 1),
        elevation: 0,
        children: [
          ExpansionPanel(
            headerBuilder: (context, isExpanded) => buildTitleRow(context),
            backgroundColor: DefaultColors.transparent,
            body: DocumentInfoPanel(
              themeBloc: themeBloc,
              document: widget.playableDocument,
              addHeader: false,
            ),
            isExpanded: _expanded,
            canTapOnHeader: true,
          ),
        ],
        dividerColor: Colors.grey,
        expansionCallback: (panelIndex, isExpanded) {
          _expanded = !_expanded;
          setState(() {});
        },
      );

  Padding buildTitleRow(BuildContext context) => Padding(
        padding: widget.padding,
        child: _buildTitle(themeBloc, context),
        // child: Text(
        //   widget.playableDocument.title,
        //   style: Theme.of(context).textTheme.headline5,
        //   maxLines: 2,
        //   overflow: TextOverflow.ellipsis,
        // ),
      );

  Widget _buildTitle(ThemeBloc themeBloc, BuildContext context) =>
      CustomEditableText(
        defaultText: widget.playableDocument.title,
        onTextChange: _onTextChange,
        textStyle: Theme.of(context).textTheme.headline5,
        errorIconColor: themeBloc.currentTheme.primaryColor.colorLight,
      );

  void _onTextChange(String title) {
    widget.playableDocument.title = title?.trim();
    fileDocumentsBloc.documentRepository.save(widget.playableDocument);
  }
}
