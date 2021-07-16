// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:mno_commons_dart/utils/jsonable.dart';
import 'package:mno_shared_dart/publication.dart';

extension SubcollectionMap on Map<String, List<PublicationCollection>> {
  /// Serializes a map of [PublicationCollection] indexed by their role into a RWPM JSON representation.
  Map<String, dynamic> toJSONObject() => appendToJSONObject({});

  /// Serializes a map of [PublicationCollection] indexed by their role into a RWPM JSON representation
  /// and add them to the given [jsonObject].
  Map<String, dynamic> appendToJSONObject(Map<String, dynamic> jsonObject) =>
      jsonObject.also((it) {
        for (MapEntry<String, List<PublicationCollection>> entry in entries) {
          String role = entry.key;
          List<PublicationCollection> collections = entry.value;
          if (collections.length == 1) {
            it.putJSONableIfNotEmpty(role, collections.first);
          } else {
            it.putIterableIfNotEmpty(role, collections);
          }
        }
      });
}
