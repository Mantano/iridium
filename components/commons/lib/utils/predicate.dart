// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:mno_commons/utils/condition_predicate.dart';
import 'package:mno_commons/utils/condition_type.dart';

abstract class Predicate<T> {
  final bool dbOnly = true;

  List<ConditionPredicate> conditionsPredicate = [];

  static const Predicate acceptAll = AcceptAllPredicate();

  void addEqualsCondition(String field, Object value) {
    conditionsPredicate
        .add(ConditionPredicate(ConditionType.isEqualTo, field, value));
  }

  void addGreaterThanCondition(String field, Object value) {
    conditionsPredicate
        .add(ConditionPredicate(ConditionType.isGreaterThan, field, value));
  }

  void addIdInCondition(String field, List<Object> value) {
    _addInArrayCondition(field, value, ConditionType.whereIn);
  }

  void addArrayContainsAnyCondition(String field, List<Object> value) {
    _addInArrayCondition(field, value, ConditionType.arrayContainsAny);
  }

  void _addInArrayCondition(
      String field, List<Object> value, ConditionType conditionType) {
    conditionsPredicate.add(ConditionPredicate(conditionType, field, value));

    if (value.length > conditionType.maxListItems) {
      Fimber.d(
          "ERROR !!!!!! in , not-in , and array-contains-any cannot contain more than ${conditionType.maxListItems} values. ");
    }
  }

  bool test(T element);

  @override
  String toString() =>
      'Predicate{dbOnly: $dbOnly, conditionsPredicate: $conditionsPredicate}';
}

class AcceptAllPredicate<T> implements Predicate<T> {
  const AcceptAllPredicate();

  @override
  bool test(T element) => true;

  @override
  void addEqualsCondition(String field, Object value) {}

  @override
  void _addInArrayCondition(
      String field, List<Object> value, ConditionType conditionType) {}

  @override
  void addIdInCondition(String field, List<Object> value) {}

  @override
  List<ConditionPredicate> get conditionsPredicate => [];

  @override
  set conditionsPredicate(List<ConditionPredicate> _conditionsPredicate) {}

  @override
  bool get dbOnly => true;

  @override
  void addGreaterThanCondition(String field, Object value) {}

  @override
  void addArrayContainsAnyCondition(String field, List<Object> value) {}
}
