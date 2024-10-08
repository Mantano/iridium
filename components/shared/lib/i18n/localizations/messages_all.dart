// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
// ignore: implementation_imports
import 'package:intl/src/intl_helpers.dart';
import 'package:mno_shared/i18n/localizations/messages_de.dart' as messages_de;
import 'package:mno_shared/i18n/localizations/messages_en.dart' as messages_en;
import 'package:mno_shared/i18n/localizations/messages_es.dart' as messages_es;
import 'package:mno_shared/i18n/localizations/messages_fr.dart' as messages_fr;
import 'package:mno_shared/i18n/localizations/messages_it.dart' as messages_it;
import 'package:mno_shared/i18n/localizations/messages_nl.dart' as messages_nl;
import 'package:mno_shared/i18n/localizations/messages_pt.dart' as messages_pt;
import 'package:mno_shared/i18n/localizations/messages_ru.dart' as messages_ru;
import 'package:mno_shared/i18n/localizations/messages_tr.dart' as messages_tr;

typedef LibraryLoader = Future<dynamic> Function();

Map<String, LibraryLoader> _deferredLibraries = {
  'en': () => Future.value(null),
  'es': () => Future.value(null),
  'fr': () => Future.value(null),
  'de': () => Future.value(null),
  'it': () => Future.value(null),
  'tr': () => Future.value(null),
  'ru': () => Future.value(null),
  'pt': () => Future.value(null),
  'nl': () => Future.value(null),
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'en':
      return messages_en.messages;
    case 'es':
      return messages_es.messages;
    case 'de':
      return messages_de.messages;
    case 'fr':
      return messages_fr.messages;
    case 'it':
      return messages_it.messages;
    case 'ru':
      return messages_ru.messages;
    case 'tr':
      return messages_tr.messages;
    case 'pt':
      return messages_pt.messages;
    case 'nl':
      return messages_nl.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) async {
  LibraryLoader? lib = _deferredLibraries[Intl.canonicalizedLocale(localeName)];
  await (lib == null ? Future.value(false) : lib());
  initializeInternalMessageLookup(() => CompositeMessageLookup());
  messageLookup.addLocale(localeName, _findGeneratedMessagesFor);
  return true;
}

bool _messagesExistFor(String locale) => _findExact(locale) != null;

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  String? actualLocale =
      Intl.verifiedLocale(locale, _messagesExistFor, onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
