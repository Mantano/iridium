// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a nl locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

// ignore: non_constant_identifier_names
typedef MessageIfAbsent = Function(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'nl';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_lcp_dialog_continue":
            MessageLookupByLibrary.simpleMessage("Doorgaan"),
        "r2_lcp_dialog_cancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "r2_lcp_dialog_reason_passphraseNotFound":
            MessageLookupByLibrary.simpleMessage("Wachtwoordzin vereist"),
        "r2_lcp_dialog_reason_invalidPassphrase":
            MessageLookupByLibrary.simpleMessage("Onjuiste wachtwoordzin"),
        "r2_lcp_dialog_prompt": (String provider) =>
            "Deze publicatie is beschermd door Readium LCP.\\n\\n"
            "Om het te openen, moeten we de wachtwoordzin weten die vereist is door: \\n\\n$provider.\\n\\n"
            "Om u te helpen herinneren, is de volgende hint beschikbaar:",
        "r2_lcp_dialog_forgotPassphrase":
            MessageLookupByLibrary.simpleMessage("Uw wachtwoordzin vergeten?"),
        "r2_lcp_dialog_help":
            MessageLookupByLibrary.simpleMessage("Meer hulp nodig?"),
        "r2_lcp_dialog_support":
            MessageLookupByLibrary.simpleMessage("Ondersteuning"),
        "r2_lcp_dialog_support_web":
            MessageLookupByLibrary.simpleMessage("Website"),
        "r2_lcp_exception_license_status_document_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Licentiestatusdocument niet beschikbaar"),
        "r2_lcp_exception_license_status_document_is_invalid":
            MessageLookupByLibrary.simpleMessage(
                "De JSON vertegenwoordigt geen geldig statusdocument"),
        "r2_lcp_exception_container_open_failed":
            MessageLookupByLibrary.simpleMessage(
                "Kan de licentiecontainer niet openen"),
        "r2_lcp_exception_container_file_not_found":
            MessageLookupByLibrary.simpleMessage(
                "Licentie niet gevonden in container"),
        "r2_lcp_exception_container_read_failed":
            MessageLookupByLibrary.simpleMessage(
                "Kan licentie niet lezen uit container"),
        "r2_lcp_exception_container_write_failed":
            MessageLookupByLibrary.simpleMessage(
                "Kan licentie niet in container schrijven"),
        "r2_lcp_exception_license_integrity_certificate_revoked":
            MessageLookupByLibrary.simpleMessage(
                "Certificaat is ingetrokken in de CRL"),
        "r2_lcp_exception_license_integrity_invalid_certificate_signature":
            MessageLookupByLibrary.simpleMessage(
                "Certificaat is niet ondertekend door CA"),
        "r2_lcp_exception_license_integrity_invalid_license_signature_date":
            MessageLookupByLibrary.simpleMessage(
                "Licentie is uitgegeven door een verlopen certificaat"),
        "r2_lcp_exception_license_integrity_invalid_license_signature":
            MessageLookupByLibrary.simpleMessage(
                "Licentiehandtekening komt niet overeen"),
        "r2_lcp_exception_license_integrity_invalid_user_key_check":
            MessageLookupByLibrary.simpleMessage(
                "Gebruikerssleutelcontrole ongeldig"),
        "r2_lcp_exception_decryption_content_key_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Kan de versleutelde inhoudssleutel niet ontsleutelen met gebruikerssleutel"),
        "r2_lcp_exception_decryption_content_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Kan versleutelde inhoud niet ontsleutelen met inhoudssleutel"),
      };
}
