// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:mno_shared/publication.dart';
import 'package:navigator/src/pdf/model/page_tile.dart';
import 'package:navigator/src/pdf/ui/image_render.dart';

class PartialImageRender extends ImageRender {
  final Size size;
  final EdgeInsetsGeometry tilePadding;

  const PartialImageRender({
    Key key,
    this.size,
    this.tilePadding,
    String address,
    Link link,
    PageTile pageTile,
  }) : super(key: key, address: address, link: link, pageTile: pageTile);

  @override
  State<StatefulWidget> createState() => PartialImageRenderState();
}

class PartialImageRenderState extends ImageRenderState<PartialImageRender> {
  Size get size => widget.size;

  EdgeInsetsGeometry get tilePadding => widget.tilePadding;

  @override
  Widget build(BuildContext context) => Container(
        padding: tilePadding,
        width: size.width,
        height: size.height,
        child: Image(
          image: NetworkImage(imageUrl),
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          fit: BoxFit.fitWidth,
        ),
      );
}
