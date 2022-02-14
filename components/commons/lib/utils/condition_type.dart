// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class ConditionType {
  static const ConditionType isGreaterThan =
          ConditionType._(0, "isGreaterThan"),
      isLessThan = ConditionType._(1, "isLessThan"),
      isEqualTo = ConditionType._(2, "isEqualTo"),
      arrayContainsAny = ConditionType._(3, "arrayContainsAny");

  static const List<ConditionType> _values = [
    isGreaterThan,
    isLessThan,
    isEqualTo,
  ];

  final int id;
  final String name;

  const ConditionType._(this.id, this.name);

  static ConditionType from(int id) =>
      _values.firstWhere((type) => type.id == id);

  @override
  String toString() => 'ConditionType.$name';
}
