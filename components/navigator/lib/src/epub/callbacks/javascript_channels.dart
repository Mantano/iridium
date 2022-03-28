// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

abstract class JavascriptChannels {
  Map<String, JavaScriptHandlerCallback> get channels;
}
