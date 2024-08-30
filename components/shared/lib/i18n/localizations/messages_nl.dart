// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a nl locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef MessageIfAbsent = Function(String messageStr, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'nl';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_shared_publication_opening_exception_error":
            MessageLookupByLibrary.simpleMessage(
                "Fout bij het openen van het document"),
        "r2_shared_publication_opening_exception_unsupported_format":
            MessageLookupByLibrary.simpleMessage("Formaat niet ondersteund"),
        "r2_shared_publication_opening_exception_not_found":
            MessageLookupByLibrary.simpleMessage("Bestand niet gevonden"),
        "r2_shared_publication_opening_exception_parsing_failed":
            MessageLookupByLibrary.simpleMessage(
                "Het bestand is beschadigd en kan niet worden geopend"),
        "r2_shared_publication_opening_exception_forbidden":
            MessageLookupByLibrary.simpleMessage(
                "Je mag deze publicatie niet openen"),
        "r2_shared_publication_opening_exception_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Niet beschikbaar, probeer het later opnieuw"),
        "r2_shared_publication_opening_exception_incorrect_credentials":
            MessageLookupByLibrary.simpleMessage(
                "Verstrekte inloggegevens waren onjuist"),
        "r2_shared_resource_exception_bad_request":
            MessageLookupByLibrary.simpleMessage(
                "Ongeldig verzoek dat niet kan worden verwerkt"),
        "r2_shared_resource_exception_not_found":
            MessageLookupByLibrary.simpleMessage("Bron niet gevonden"),
        "r2_shared_resource_exception_forbidden":
            MessageLookupByLibrary.simpleMessage(
                "Je hebt geen toegang tot de bron"),
        "r2_shared_resource_exception_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "De bron is momenteel niet beschikbaar, probeer het later opnieuw"),
        "r2_shared_resource_exception_out_of_memory":
            MessageLookupByLibrary.simpleMessage(
                "De bron is te groot om op dit apparaat te worden gelezen"),
        "r2_shared_resource_exception_cancelled":
            MessageLookupByLibrary.simpleMessage("Het verzoek is geannuleerd"),
        "r2_shared_resource_exception_other":
            MessageLookupByLibrary.simpleMessage(
                "Er is een servicefout opgetreden"),
      };
}
