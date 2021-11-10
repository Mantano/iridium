// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:mno_shared/publication.dart';
import 'package:navigator/src/pdf/model/page_tile.dart';
import 'package:navigator/src/pdf/ui/image_render.dart';

class FullImageRender extends ImageRender {
  final BoxFit fit;
  final double width;
  final double height;

  const FullImageRender({
    Key key,
    String address,
    Link link,
    PageTile pageTile,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  }) : super(key: key, address: address, link: link, pageTile: pageTile);

  @override
  State<StatefulWidget> createState() => FullImageRenderState();
}

class FullImageRenderState extends ImageRenderState<FullImageRender> {
  @override
  Widget build(BuildContext context) => Image(
        height: widget.height,
        width: widget.width,
        errorBuilder:
            (BuildContext context, Object error, StackTrace stackTrace) =>
                const SizedBox.shrink(),
        image: NetworkImage(imageUrl),
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        fit: widget.fit,
      );

  @override
  Map<String, int> fillUrlParams() {
    Map<String, int> params = super.fillUrlParams();
    if (widget.width != null) {
      params['constraintWidth'] = widget.width.toInt();
    }
    if (widget.height != null) {
      params['constraintHeight'] = widget.height.toInt();
    }
    return params;
  }
}
