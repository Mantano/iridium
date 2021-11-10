// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:navigator/src/document/listeners/key_mapping.dart';
import 'package:navigator/src/document/listeners/reader_action.dart';

class VidamiPlayerKeyMapping implements KeyMapping {
  const VidamiPlayerKeyMapping();

  @override
  ReaderAction matchKey(String key) {
    if (key.isNotEmpty) {
      switch (key) {
        case '`':
        case '.':
          return ReaderAction.speed;
        case ';':
        case '/':
          return ReaderAction.loop;
        case '{':
        case 'P':
          return ReaderAction.back;
        case 'K':
        case '\\':
          return ReaderAction.play;
        case '}':
        case ',':
          return ReaderAction.forward;
      }
    }
    return ReaderAction.none;
  }
}
