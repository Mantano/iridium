// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_commons/utils/condition_type.dart';

class ConditionPredicate {
  final ConditionType type;
  final String field;
  final Object value;

  ConditionPredicate(this.type, this.field, this.value);

  bool get mustSplit =>
      type.maxListItems > 1 && (value as Iterable).length > type.maxListItems;

  @override
  String toString() =>
      'ConditionPredicate{type: $type, field: $field, value: $value}';
}
