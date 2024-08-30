// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef MessageIfAbsent = Function(String messageStr, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'ru';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_shared_publication_opening_exception_error":
            MessageLookupByLibrary.simpleMessage(
                "Ошибка при открытии документа"),
        "r2_shared_publication_opening_exception_unsupported_format":
            MessageLookupByLibrary.simpleMessage("Формат не поддерживается"),
        "r2_shared_publication_opening_exception_not_found":
            MessageLookupByLibrary.simpleMessage("Файл не найден"),
        "r2_shared_publication_opening_exception_parsing_failed":
            MessageLookupByLibrary.simpleMessage(
                "Файл поврежден и не может быть открыт"),
        "r2_shared_publication_opening_exception_forbidden":
            MessageLookupByLibrary.simpleMessage(
                "Вам не разрешено открывать эту публикацию"),
        "r2_shared_publication_opening_exception_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Недоступно, попробуйте позже"),
        "r2_shared_publication_opening_exception_incorrect_credentials":
            MessageLookupByLibrary.simpleMessage(
                "Предоставленные учетные данные были неверны"),
        "r2_shared_resource_exception_bad_request":
            MessageLookupByLibrary.simpleMessage(
                "Неверный запрос, который не может быть обработан"),
        "r2_shared_resource_exception_not_found":
            MessageLookupByLibrary.simpleMessage("Ресурс не найден"),
        "r2_shared_resource_exception_forbidden":
            MessageLookupByLibrary.simpleMessage(
                "Вам не разрешено получать доступ к ресурсу"),
        "r2_shared_resource_exception_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Ресурс в настоящее время недоступен, попробуйте позже"),
        "r2_shared_resource_exception_out_of_memory":
            MessageLookupByLibrary.simpleMessage(
                "Ресурс слишком велик, чтобы его можно было прочитать на этом устройстве"),
        "r2_shared_resource_exception_cancelled":
            MessageLookupByLibrary.simpleMessage("Запрос был отменен"),
        "r2_shared_resource_exception_other":
            MessageLookupByLibrary.simpleMessage("Произошла ошибка службы"),
      };
}
