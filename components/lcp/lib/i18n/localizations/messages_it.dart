// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

// ignore: non_constant_identifier_names
typedef MessageIfAbsent = Function(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'it';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_lcp_dialog_continue":
            MessageLookupByLibrary.simpleMessage("Continua"),
        "r2_lcp_dialog_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "r2_lcp_dialog_reason_passphraseNotFound":
            MessageLookupByLibrary.simpleMessage("Passphrase richiesta"),
        "r2_lcp_dialog_reason_invalidPassphrase":
            MessageLookupByLibrary.simpleMessage("Passphrase errata"),
        "r2_lcp_dialog_prompt": (String provider) =>
            "Questa pubblicazione è protetta da Readium LCP.\\n\\n"
            "Per aprirla, dobbiamo conoscere la passphrase richiesta da: \\n\\n$provider.\\n\\n"
            "Per aiutarti a ricordarla, è disponibile il seguente suggerimento:",
        "r2_lcp_dialog_forgotPassphrase": MessageLookupByLibrary.simpleMessage(
            "Hai dimenticato la passphrase?"),
        "r2_lcp_dialog_help":
            MessageLookupByLibrary.simpleMessage("Hai bisogno di più aiuto?"),
        "r2_lcp_dialog_support":
            MessageLookupByLibrary.simpleMessage("Supporto"),
        "r2_lcp_dialog_support_web":
            MessageLookupByLibrary.simpleMessage("Sito web"),
        "r2_lcp_exception_license_status_document_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Documento di stato della licenza non disponibile"),
        "r2_lcp_exception_license_status_document_is_invalid":
            MessageLookupByLibrary.simpleMessage(
                "Il JSON non rappresenta un Documento di Stato valido"),
        "r2_lcp_exception_container_open_failed":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile aprire il contenitore della licenza"),
        "r2_lcp_exception_container_file_not_found":
            MessageLookupByLibrary.simpleMessage(
                "Licenza non trovata nel contenitore"),
        "r2_lcp_exception_container_read_failed":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile leggere la licenza dal contenitore"),
        "r2_lcp_exception_container_write_failed":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile scrivere la licenza nel contenitore"),
        "r2_lcp_exception_license_integrity_certificate_revoked":
            MessageLookupByLibrary.simpleMessage(
                "Il certificato è stato revocato nella CRL"),
        "r2_lcp_exception_license_integrity_invalid_certificate_signature":
            MessageLookupByLibrary.simpleMessage(
                "Il certificato non è stato firmato dalla CA"),
        "r2_lcp_exception_license_integrity_invalid_license_signature_date":
            MessageLookupByLibrary.simpleMessage(
                "La licenza è stata emessa con un certificato scaduto"),
        "r2_lcp_exception_license_integrity_invalid_license_signature":
            MessageLookupByLibrary.simpleMessage(
                "La firma della licenza non corrisponde"),
        "r2_lcp_exception_license_integrity_invalid_user_key_check":
            MessageLookupByLibrary.simpleMessage(
                "Controllo della chiave utente non valido"),
        "r2_lcp_exception_decryption_content_key_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile decriptare la chiave di contenuto criptata dalla chiave utente"),
        "r2_lcp_exception_decryption_content_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile decriptare il contenuto criptato dalla chiave di contenuto"),
      };
}
