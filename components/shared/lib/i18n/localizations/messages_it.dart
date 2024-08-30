// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef MessageIfAbsent = Function(String messageStr, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'it';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_shared_publication_opening_exception_error":
            MessageLookupByLibrary.simpleMessage(
                "Errore nell'apertura del documento"),
        "r2_shared_publication_opening_exception_unsupported_format":
            MessageLookupByLibrary.simpleMessage("Formato non supportato"),
        "r2_shared_publication_opening_exception_not_found":
            MessageLookupByLibrary.simpleMessage("File non trovato"),
        "r2_shared_publication_opening_exception_parsing_failed":
            MessageLookupByLibrary.simpleMessage(
                "Il file è corrotto e non può essere aperto"),
        "r2_shared_publication_opening_exception_forbidden":
            MessageLookupByLibrary.simpleMessage(
                "Non sei autorizzato ad aprire questa pubblicazione"),
        "r2_shared_publication_opening_exception_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Non disponibile, riprova più tardi"),
        "r2_shared_publication_opening_exception_incorrect_credentials":
            MessageLookupByLibrary.simpleMessage(
                "Le credenziali fornite erano errate"),
        "r2_shared_resource_exception_bad_request":
            MessageLookupByLibrary.simpleMessage(
                "Richiesta non valida che non può essere elaborata"),
        "r2_shared_resource_exception_not_found":
            MessageLookupByLibrary.simpleMessage("Risorsa non trovata"),
        "r2_shared_resource_exception_forbidden":
            MessageLookupByLibrary.simpleMessage(
                "Non sei autorizzato ad accedere alla risorsa"),
        "r2_shared_resource_exception_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "La risorsa non è attualmente disponibile, riprova più tardi"),
        "r2_shared_resource_exception_out_of_memory":
            MessageLookupByLibrary.simpleMessage(
                "La risorsa è troppo grande per essere letta su questo dispositivo"),
        "r2_shared_resource_exception_cancelled":
            MessageLookupByLibrary.simpleMessage(
                "La richiesta è stata annullata"),
        "r2_shared_resource_exception_other":
            MessageLookupByLibrary.simpleMessage(
                "Si è verificato un errore di servizio"),
      };
}
