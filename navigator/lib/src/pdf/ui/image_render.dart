// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:mno_shared/publication.dart';
import 'package:navigator/src/pdf/model/page_tile.dart';

abstract class ImageRender extends StatefulWidget {
  final String address;
  final Link link;
  final PageTile pageTile;

  const ImageRender({
    Key key,
    this.address,
    this.link,
    this.pageTile,
  }) : super(key: key);
}

abstract class ImageRenderState<T extends ImageRender> extends State<T> {
  String get address => widget.address;

  Link get link => widget.link;

  PageTile get pageTile => widget.pageTile;

  String get imageUrl {
    String url = address;
    if (!link.href.startsWith('/')) {
      url += '/';
    }
    url += link.href;
    if (!link.href.contains('?')) {
      url += '?';
    }
    Map<String, int> params = fillUrlParams();
    if (params.isNotEmpty) {
      for (String key in params.keys) {
        url += "&$key=${params[key]}";
      }
    }
    return url;
  }

  Map<String, int> fillUrlParams() {
    Map<String, int> params = {};
    if (pageTile != null) {
      params['width'] = pageTile.pageWidth;
      params['height'] = pageTile.pageHeight;
      params['tileWidth'] = pageTile.tileWidth;
      params['tileHeight'] = pageTile.tileHeight;
      params['startX'] = pageTile.left;
      params['startY'] = pageTile.top;
    }
    return params;
  }
}
