// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

// ignore: non_constant_identifier_names
typedef MessageIfAbsent = Function(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'ru';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_lcp_dialog_continue":
            MessageLookupByLibrary.simpleMessage("Продолжить"),
        "r2_lcp_dialog_cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
        "r2_lcp_dialog_reason_passphraseNotFound":
            MessageLookupByLibrary.simpleMessage("Требуется парольная фраза"),
        "r2_lcp_dialog_reason_invalidPassphrase":
            MessageLookupByLibrary.simpleMessage(
                "Неправильная парольная фраза"),
        "r2_lcp_dialog_prompt": (String provider) =>
            "Эта публикация защищена Readium LCP.\\n\\n"
            "Чтобы открыть её, нам нужно знать парольную фразу, требуемую: \\n\\n$provider.\\n\\n"
            "Чтобы помочь вам её запомнить, доступен следующий намек:",
        "r2_lcp_dialog_forgotPassphrase": MessageLookupByLibrary.simpleMessage(
            "Забыли свою парольную фразу?"),
        "r2_lcp_dialog_help": MessageLookupByLibrary.simpleMessage(
            "Нужна дополнительная помощь?"),
        "r2_lcp_dialog_support":
            MessageLookupByLibrary.simpleMessage("Поддержка"),
        "r2_lcp_dialog_support_web":
            MessageLookupByLibrary.simpleMessage("Веб-сайт"),
        "r2_lcp_exception_license_status_document_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Документ состояния лицензии недоступен"),
        "r2_lcp_exception_license_status_document_is_invalid":
            MessageLookupByLibrary.simpleMessage(
                "JSON не представляет действительный Документ Состояния"),
        "r2_lcp_exception_container_open_failed":
            MessageLookupByLibrary.simpleMessage(
                "Невозможно открыть контейнер лицензии"),
        "r2_lcp_exception_container_file_not_found":
            MessageLookupByLibrary.simpleMessage(
                "Лицензия не найдена в контейнере"),
        "r2_lcp_exception_container_read_failed":
            MessageLookupByLibrary.simpleMessage(
                "Невозможно прочитать лицензию из контейнера"),
        "r2_lcp_exception_container_write_failed":
            MessageLookupByLibrary.simpleMessage(
                "Невозможно записать лицензию в контейнер"),
        "r2_lcp_exception_license_integrity_certificate_revoked":
            MessageLookupByLibrary.simpleMessage("Сертификат отозван в CRL"),
        "r2_lcp_exception_license_integrity_invalid_certificate_signature":
            MessageLookupByLibrary.simpleMessage("Сертификат не подписан УЦ"),
        "r2_lcp_exception_license_integrity_invalid_license_signature_date":
            MessageLookupByLibrary.simpleMessage(
                "Лицензия выдана по истечении срока действия сертификата"),
        "r2_lcp_exception_license_integrity_invalid_license_signature":
            MessageLookupByLibrary.simpleMessage(
                "Подпись лицензии не совпадает"),
        "r2_lcp_exception_license_integrity_invalid_user_key_check":
            MessageLookupByLibrary.simpleMessage(
                "Проверка пользовательского ключа недействительна"),
        "r2_lcp_exception_decryption_content_key_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Невозможно расшифровать зашифрованный ключ контента с пользовательского ключа"),
        "r2_lcp_exception_decryption_content_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Невозможно расшифровать зашифрованный контент с ключа контента"),
      };
}
