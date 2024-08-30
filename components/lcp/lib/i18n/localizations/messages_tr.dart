// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

// ignore: non_constant_identifier_names
typedef MessageIfAbsent = Function(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'tr';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_lcp_dialog_continue":
            MessageLookupByLibrary.simpleMessage("Devam et"),
        "r2_lcp_dialog_cancel": MessageLookupByLibrary.simpleMessage("İptal"),
        "r2_lcp_dialog_reason_passphraseNotFound":
            MessageLookupByLibrary.simpleMessage("Parola Gerekiyor"),
        "r2_lcp_dialog_reason_invalidPassphrase":
            MessageLookupByLibrary.simpleMessage("Geçersiz Parola"),
        "r2_lcp_dialog_prompt": (String provider) =>
            "Bu yayın Readium LCP ile korunmaktadır.\\n\\n"
            "Açmak için, gereksinim duyulan parolayı bilmemiz gerekiyor: \\n\\n$provider.\\n\\n"
            "Bunu hatırlamanıza yardımcı olmak için, aşağıdaki ipucu mevcuttur:",
        "r2_lcp_dialog_forgotPassphrase":
            MessageLookupByLibrary.simpleMessage("Parolanızı mı unuttunuz?"),
        "r2_lcp_dialog_help": MessageLookupByLibrary.simpleMessage(
            "Daha fazla yardıma mı ihtiyacınız var?"),
        "r2_lcp_dialog_support": MessageLookupByLibrary.simpleMessage("Destek"),
        "r2_lcp_dialog_support_web":
            MessageLookupByLibrary.simpleMessage("Web sitesi"),
        "r2_lcp_exception_license_status_document_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Lisans Durum Belgesi kullanılamıyor"),
        "r2_lcp_exception_license_status_document_is_invalid":
            MessageLookupByLibrary.simpleMessage(
                "JSON geçerli bir Durum Belgesini temsil etmiyor"),
        "r2_lcp_exception_container_open_failed":
            MessageLookupByLibrary.simpleMessage(
                "Lisans konteynerini açamıyor"),
        "r2_lcp_exception_container_file_not_found":
            MessageLookupByLibrary.simpleMessage(
                "Lisans konteynerde bulunamadı"),
        "r2_lcp_exception_container_read_failed":
            MessageLookupByLibrary.simpleMessage(
                "Lisans konteynerden okunamıyor"),
        "r2_lcp_exception_container_write_failed":
            MessageLookupByLibrary.simpleMessage(
                "Lisans konteynere yazılamıyor"),
        "r2_lcp_exception_license_integrity_certificate_revoked":
            MessageLookupByLibrary.simpleMessage(
                "Sertifika CRL'de iptal edildi"),
        "r2_lcp_exception_license_integrity_invalid_certificate_signature":
            MessageLookupByLibrary.simpleMessage(
                "Sertifika CA tarafından imzalanmamış"),
        "r2_lcp_exception_license_integrity_invalid_license_signature_date":
            MessageLookupByLibrary.simpleMessage(
                "Lisans süresi dolmuş bir sertifika ile verilmiş"),
        "r2_lcp_exception_license_integrity_invalid_license_signature":
            MessageLookupByLibrary.simpleMessage("Lisans imzası eşleşmiyor"),
        "r2_lcp_exception_license_integrity_invalid_user_key_check":
            MessageLookupByLibrary.simpleMessage(
                "Kullanıcı anahtarı kontrolü geçersiz"),
        "r2_lcp_exception_decryption_content_key_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Şifreli içerik anahtarı kullanıcı anahtarından çözülemiyor"),
        "r2_lcp_exception_decryption_content_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "İçerik anahtarından şifreli içerik çözülemiyor"),
      };
}
