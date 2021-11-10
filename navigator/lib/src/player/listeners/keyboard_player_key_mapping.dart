// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:navigator/src/document/listeners/key_mapping.dart';
import 'package:navigator/src/document/listeners/reader_action.dart';

class KeyboardPlayerKeyMapping implements KeyMapping {
  const KeyboardPlayerKeyMapping();

  @override
  ReaderAction matchKey(String key) {
    if (key.isNotEmpty) {
      switch (key) {
        case 's':
          return ReaderAction.speed;
        case 'l':
          return ReaderAction.loop;
        case 'b':
          return ReaderAction.back;
        case 'p':
          return ReaderAction.play;
        case 'f':
          return ReaderAction.forward;
      }
    }
    return ReaderAction.none;
  }
}
