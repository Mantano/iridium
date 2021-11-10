// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/blocs/documents/load_attachment_bloc.dart';
import 'package:model/model.dart';
import 'package:ui_commons/ui/scroll_view_attachments.dart';
import 'package:ui_commons/ui/simple_document_list_tile.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/widgets/multi_select.dart';
import 'package:navigator/src/document/ui/drawer/reader_panel.dart';

class AttachmentsPanel extends ReaderPanel {
  final FileDocument document;

  const AttachmentsPanel(this.document, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AttachmentsPanelState();

  @override
  Future<bool> get display async => document.attachmentIds.isNotEmpty;

  @override
  Widget buildIcon() => const Icon(
        Icons.link,
        color: Colors.white,
        size: CommonSizes.small1IconSize,
      );
}

class AttachmentsPanelState extends ReaderPanelState<AttachmentsPanel> {
  static const double itemExtent = 80.0;
  LoadAttachmentBloc attachmentBloc;

  @override
  void initState() {
    super.initState();
    attachmentBloc = BlocProvider.of<LoadAttachmentBloc>(context);
  }

  @override
  Widget buildPanel(BuildContext context) => ScrollViewAttachments(
        document: widget.document,
        attachmentBloc: attachmentBloc,
        builder: (BuildContext context,
                List<FileDocument> documents,
                CustomMultiSelectController multiSelectController,
                OnTapDocument onTapDocument) =>
            ListView.builder(
          padding:
              const EdgeInsets.symmetric(vertical: CommonSizes.large2Margin),
          itemExtent: itemExtent,
          itemCount: documents.length,
          itemBuilder: (BuildContext context, int index) =>
              SimpleDocumentListTile(
            document: documents[index],
            multiSelectController: multiSelectController,
            itemHeight: itemExtent,
            onItemTap: () => onTapDocument(documents[index]),
          ),
        ),
      );
}
