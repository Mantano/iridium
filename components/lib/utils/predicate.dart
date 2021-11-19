// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

abstract class Predicate<T> {
  static const Predicate acceptAll = AcceptAllPredicate();

  bool test(T element);
}

class AcceptAllPredicate<T> implements Predicate<T> {
  const AcceptAllPredicate();

  @override
  bool test(T element) => true;
}
