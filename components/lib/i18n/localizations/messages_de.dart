// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent = Function(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'de';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_lcp_dialog_continue":
            MessageLookupByLibrary.simpleMessage("Continue"),
        "r2_lcp_dialog_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "r2_lcp_dialog_reason_passphraseNotFound":
            MessageLookupByLibrary.simpleMessage("Passphrase Required"),
        "r2_lcp_dialog_reason_invalidPassphrase":
            MessageLookupByLibrary.simpleMessage("Incorrect Passphrase"),
        "r2_lcp_dialog_prompt": (String provider) =>
            "This publication is protected by Readium LCP.\n\n"
            "In order to open it, we need to know the passphrase required by: \n\n$provider.\n\n"
            "To help you remember it, the following hint is available:",
        "r2_lcp_dialog_forgotPassphrase":
            MessageLookupByLibrary.simpleMessage("Forgot your passphrase?"),
        "r2_lcp_dialog_help":
            MessageLookupByLibrary.simpleMessage("Need more help?"),
        "r2_lcp_dialog_support":
            MessageLookupByLibrary.simpleMessage("Support"),
        "r2_lcp_dialog_support_web":
            MessageLookupByLibrary.simpleMessage("Website"),
        "r2_lcp_dialog_support_phone":
            MessageLookupByLibrary.simpleMessage("Phone"),
        "r2_lcp_dialog_support_mail":
            MessageLookupByLibrary.simpleMessage("Mail"),
      };
}
