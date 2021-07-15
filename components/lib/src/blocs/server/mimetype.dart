// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

class Mimetype {
  static const defaultBinaryMimetype = 'application/octet-stream';

  static const mimetypes = {
    'html': 'text/html',
    'xhtml': 'text/html',
    'xml': 'text/html',
    'htm': 'text/html',
    'css': 'text/css',
    'java': 'text/x-java-source: text/java',
    'txt': 'text/plain',
    'asc': 'text/plain',
    'gif': 'image/gif',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'bmp': 'image/bmp',
    'svg': 'image/svg+xml',
    'mp3': 'audio/mpeg',
    'm3u': 'audio/mpeg-url',
    'mp4': 'video/mp4',
    'ogv': 'video/ogg',
    'flv': 'video/x-flv',
    'mov': 'video/quicktime',
    'swf': 'application/x-shockwave-flash',
    'js': 'application/javascript',
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'ogg': 'application/x-ogg',
    'zip': 'application/octet-stream',
    'exe': 'application/octet-stream',
    'class': 'application/octet-stream',
    'webm': 'video/webm',
  };

  final String mimetype;
  String charset; // nullable
  Mimetype(this.mimetype, {this.charset}) : assert(mimetype != null);

  factory Mimetype.fromPath(String path, {String charset}) {
    if (path == null) {
      return null;
    }
    String extension = p.extension(path).toLowerCase();
    if (extension != null && extension.length > 1) {
      extension = extension.substring(1);
    }
    String mimetype = mimetypes[extension];
    if (mimetype == null) {
      return null;
    }

    return Mimetype(mimetype, charset: charset);
  }

  bool get isHtml => ['text/html', 'application/xhtml+xml'].contains(mimetype);

  ContentType get contentType {
    String type = mimetype;
    if (charset != null) {
      type += '; charset=$charset';
    }
    return ContentType.parse(type);
  }
}
