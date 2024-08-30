// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef MessageIfAbsent = Function(String messageStr, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'tr';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_shared_publication_opening_exception_error":
            MessageLookupByLibrary.simpleMessage("Belge açılırken hata oluştu"),
        "r2_shared_publication_opening_exception_unsupported_format":
            MessageLookupByLibrary.simpleMessage("Format desteklenmiyor"),
        "r2_shared_publication_opening_exception_not_found":
            MessageLookupByLibrary.simpleMessage("Dosya bulunamadı"),
        "r2_shared_publication_opening_exception_parsing_failed":
            MessageLookupByLibrary.simpleMessage("Dosya bozuk ve açılamıyor"),
        "r2_shared_publication_opening_exception_forbidden":
            MessageLookupByLibrary.simpleMessage(
                "Bu yayını açmanıza izin verilmiyor"),
        "r2_shared_publication_opening_exception_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Mevcut değil, lütfen daha sonra tekrar deneyin"),
        "r2_shared_publication_opening_exception_incorrect_credentials":
            MessageLookupByLibrary.simpleMessage(
                "Sağlanan kimlik bilgileri yanlıştı"),
        "r2_shared_resource_exception_bad_request":
            MessageLookupByLibrary.simpleMessage("İşlenemeyen geçersiz istek"),
        "r2_shared_resource_exception_not_found":
            MessageLookupByLibrary.simpleMessage("Kaynak bulunamadı"),
        "r2_shared_resource_exception_forbidden":
            MessageLookupByLibrary.simpleMessage("Kaynağa erişim izniniz yok"),
        "r2_shared_resource_exception_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Kaynak şu anda kullanılamıyor, lütfen daha sonra tekrar deneyin"),
        "r2_shared_resource_exception_out_of_memory":
            MessageLookupByLibrary.simpleMessage(
                "Kaynak bu cihazda okunamayacak kadar büyük"),
        "r2_shared_resource_exception_cancelled":
            MessageLookupByLibrary.simpleMessage("İstek iptal edildi"),
        "r2_shared_resource_exception_other":
            MessageLookupByLibrary.simpleMessage("Bir hizmet hatası oluştu"),
      };
}
