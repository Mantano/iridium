// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

// ignore: non_constant_identifier_names
typedef MessageIfAbsent = Function(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'pt';

  @override
  Map<String, dynamic> get messages => _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => {
        "r2_lcp_dialog_continue":
            MessageLookupByLibrary.simpleMessage("Continuar"),
        "r2_lcp_dialog_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "r2_lcp_dialog_reason_passphraseNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Frase de segurança necessária"),
        "r2_lcp_dialog_reason_invalidPassphrase":
            MessageLookupByLibrary.simpleMessage(
                "Frase de segurança incorreta"),
        "r2_lcp_dialog_prompt": (String provider) =>
            "Esta publicação é protegida pelo Readium LCP.\\n\\n"
            "Para abri-la, precisamos saber a frase de segurança exigida por: \\n\\n$provider.\\n\\n"
            "Para ajudá-lo a lembrá-la, a seguinte dica está disponível:",
        "r2_lcp_dialog_forgotPassphrase": MessageLookupByLibrary.simpleMessage(
            "Esqueceu sua frase de segurança?"),
        "r2_lcp_dialog_help":
            MessageLookupByLibrary.simpleMessage("Precisa de mais ajuda?"),
        "r2_lcp_dialog_support":
            MessageLookupByLibrary.simpleMessage("Suporte"),
        "r2_lcp_dialog_support_web":
            MessageLookupByLibrary.simpleMessage("Website"),
        "r2_lcp_exception_license_status_document_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Documento de Status da Licença indisponível"),
        "r2_lcp_exception_license_status_document_is_invalid":
            MessageLookupByLibrary.simpleMessage(
                "O JSON não representa um Documento de Status válido"),
        "r2_lcp_exception_container_open_failed":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível abrir o contêiner da licença"),
        "r2_lcp_exception_container_file_not_found":
            MessageLookupByLibrary.simpleMessage(
                "Licença não encontrada no contêiner"),
        "r2_lcp_exception_container_read_failed":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível ler a licença do contêiner"),
        "r2_lcp_exception_container_write_failed":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível escrever a licença no contêiner"),
        "r2_lcp_exception_license_integrity_certificate_revoked":
            MessageLookupByLibrary.simpleMessage(
                "O certificado foi revogado na CRL"),
        "r2_lcp_exception_license_integrity_invalid_certificate_signature":
            MessageLookupByLibrary.simpleMessage(
                "O certificado não foi assinado pela CA"),
        "r2_lcp_exception_license_integrity_invalid_license_signature_date":
            MessageLookupByLibrary.simpleMessage(
                "A licença foi emitida por um certificado expirado"),
        "r2_lcp_exception_license_integrity_invalid_license_signature":
            MessageLookupByLibrary.simpleMessage(
                "A assinatura da licença não corresponde"),
        "r2_lcp_exception_license_integrity_invalid_user_key_check":
            MessageLookupByLibrary.simpleMessage(
                "Verificação da chave do usuário inválida"),
        "r2_lcp_exception_decryption_content_key_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível descriptografar a chave de conteúdo criptografada a partir da chave do usuário"),
        "r2_lcp_exception_decryption_content_decrypt_error":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível descriptografar o conteúdo criptografado a partir da chave de conteúdo"),
      };
}
