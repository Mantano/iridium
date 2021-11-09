// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreConfig {
  static FirestoreConfig _instance;

  static FirestoreConfig get instance => _instance;
  final FirebaseFirestore firestore;
  String userId;

  FirestoreConfig(this.firestore) {
    _instance = this;
  }
}
