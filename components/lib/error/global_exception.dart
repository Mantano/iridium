// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'exception_type.dart';

class GlobalException implements Exception {
  String message;
  String i18nMessage;
  String i18nTitle;
  String code;
  String stacktrace;
  ExceptionType type;

  GlobalException(this.type, this.i18nTitle, this.i18nMessage, this.code,
      this.message, this.stacktrace);

  @override
  String toString() =>
      'GlobalException{message: $message,i18nTitle: $i18nTitle, i18nMessage: $i18nMessage, code: $code, stacktrace: $stacktrace, type: $type}';
}
