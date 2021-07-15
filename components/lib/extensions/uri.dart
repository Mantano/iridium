// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as p;

extension UriExtension on Uri {
  Uri removeLastComponent() {
    if (pathSegments.isEmpty) {
      return this;
    }
    return replace(
        pathSegments: pathSegments.sublist(0, pathSegments.length - 1));
  }

  String get extension => p.extension(path);
}
