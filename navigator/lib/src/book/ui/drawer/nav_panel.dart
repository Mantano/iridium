// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_shared/publication.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_framework/widgets/tree_view.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/document/ui/drawer/reader_panel.dart';
import 'package:navigator/src/epub/bloc/nav_location_info_bloc.dart';
import 'package:navigator/src/epub/model/commands.dart';

class NavPanel extends ReaderPanel {
  final ReaderContext readerContext;

  const NavPanel(this.readerContext, {Key key})
      : assert(readerContext != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _NavPanelState();

  @override
  Widget buildIcon() => SvgAssets.toc.widget();

  @override
  Future<bool> get display async => readerContext.tableOfContents.isNotEmpty;
}

class _NavPanelState extends ReaderPanelState<NavPanel> {
  NavLocationInfoBloc _navLocationInfoBloc;

  List<Link> get tableOfContents => widget.readerContext.tableOfContents;

  List<Link> get flattenedTableOfContents =>
      widget.readerContext.flattenedTableOfContents;

  Map<Link, int> get tableOfContentsToSpineItemIndex =>
      widget.readerContext.tableOfContentsToSpineItemIndex;

  @override
  void initState() {
    super.initState();
    _navLocationInfoBloc = NavLocationInfoBloc(widget.readerContext);
  }

  @override
  void dispose() {
    super.dispose();
    _navLocationInfoBloc.close();
  }

  @override
  Widget buildPanel(BuildContext context) => BlocBuilder(
        bloc: _navLocationInfoBloc,
        builder: (BuildContext context, NavLocationInfoState state) =>
            TreeView<Link>(
          maximumIndent: 2,
          padding: ReaderPanelState.padding,
          children: _buildChildNodes(tableOfContents, state.selectedLink),
          onTap: _onTap,
          emptyAsset: SvgAssets.dash,
          expandedAsset: SvgAssets.arrowDown,
          collapsedAsset: SvgAssets.arrowRight,
        ),
      );

  List<TreeNode<Link>> _buildChildNodes(
          List<Link> children, Link selectedLink) =>
      children
          .where((link) => link.title != null && link.title.isNotEmpty)
          .map((link) {
        List<TreeNode<Link>> children =
            _buildChildNodes(link.children, selectedLink);
        bool expanded = (selectedLink != null &&
                selectedLink.href == link.href) ||
            children.firstWhere((node) => node.expanded, orElse: () => null) !=
                null;
        return TreeNode(
          title: link.title,
          data: link,
          expanded: expanded,
          children: children,
        );
      }).toList();

  void _onTap(TreeNode<Link> node) {
    Link link = node.data;
    if (link != null) {
      ReaderContext.of(context)
          .execute(GoToHrefCommand(link.hrefPart, link.elementId));
    }
  }
}
