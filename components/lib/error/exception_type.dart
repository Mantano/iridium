// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

class ExceptionType {
  static const ExceptionType platform = ExceptionType._(1, "PLATFORM");
  static const ExceptionType firebaseAuth = ExceptionType._(2, "FIREBASE_AUTH");
  static const ExceptionType firebase = ExceptionType._(3, "FIREBASE");
  static const ExceptionType unknown = ExceptionType._(0, "UNKNOWN");

  static const List<ExceptionType> _values = [
    unknown,
    platform,
    firebaseAuth,
    firebase,
  ];
  final int id;
  final String name;

  const ExceptionType._(this.id, this.name);

  static ExceptionType from(int id) =>
      _values.firstWhere((type) => type.id == id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'ExceptionType.$name';
}
