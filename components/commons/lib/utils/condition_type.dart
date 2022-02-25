// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class ConditionType {
  static const ConditionType isGreaterThan =
          ConditionType._(0, "isGreaterThan", 1),
      isLessThan = ConditionType._(1, "isLessThan", 1),
      isEqualTo = ConditionType._(2, "isEqualTo", 1),
      contains = ConditionType._(6, "whereGreaterThanOrEqualTo", 1),
      arrayContainsAny = ConditionType._(3, "arrayContainsAny", 10),
      arrayContains = ConditionType._(3, "arrayContains", 10),
      whereIn = ConditionType._(4, "whereIn", 10),
      whereNotIn = ConditionType._(5, "whereNotIn", 10);

  static const List<ConditionType> _values = [
    isGreaterThan,
    isLessThan,
    isEqualTo,
  ];

  final int id;
  final String name;
  // FOLLOWING Firestore Documentation https://firebase.google.com/docs/firestore/query-data/queries
  final int maxListItems;

  const ConditionType._(this.id, this.name, this.maxListItems);

  static ConditionType from(int id) =>
      _values.firstWhere((type) => type.id == id);

  @override
  String toString() => 'ConditionType.$name';
}
