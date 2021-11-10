// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:navigator/src/document/ui/drawer/reader_panel.dart';

class BookSearchPanel extends ReaderPanel {
  const BookSearchPanel({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SearchPanelState();

  @override
  Widget buildIcon() => SvgAssets.search.widget();
}

class SearchPanelState extends ReaderPanelState<BookSearchPanel> {
  @override
  Widget buildPanel(BuildContext context) => Container();
}
