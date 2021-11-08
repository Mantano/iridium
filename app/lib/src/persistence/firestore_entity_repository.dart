// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fimber/fimber.dart';
import 'package:model/commons/entity_repository.dart';
import 'package:model/model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:utils/list/predicate.dart';

import 'firestore_config.dart';

typedef SnapshotToEntityTransformation<T> = Future<T> Function(
    DocumentSnapshot snapshot);

class FirestoreEntityRepository<T extends Entity> extends EntityRepository<T> {
  final FirestoreConfig firestoreConfig;
  final String _pathPrefix;
  final SnapshotToEntityTransformation<T> _snapshotToEntityTransformation;

  FirestoreEntityRepository(this.firestoreConfig, this._pathPrefix,
      this._snapshotToEntityTransformation);

  String get path => (firestoreConfig.userId != null)
      ? '$_pathPrefix/${firestoreConfig.userId}'
      : null;

  FirebaseFirestore get firestore => firestoreConfig.firestore;

  @override
  Future<void> save(T entity) async {
    if (entity.id != null) {
      return update(entity);
    }
    if (entity.isValid()) {
      return add(entity);
    }
    return;
  }

  @override
  Future<void> add(T entity, {Function continuation}) async {
    DocumentReference documentReference =
        firestore.collection(path).doc(entity.id);
    return documentReference.set(entity.toJson()).then((_) {
      entity.id = documentReference.id;
    }).catchError((ex, stacktrace) {
      Fimber.d("ERROR: $entity", ex: ex, stacktrace: stacktrace);
    }).whenComplete(() {
      if (continuation != null) {
        continuation();
      }
    });
  }

  @override
  Future<T> get(String id) async {
    if (firestore == null ||
        path == null ||
        path.isEmpty ||
        firestore.collection(path) == null) {
      return null;
    }
    DocumentReference documentReference = firestore.collection(path).doc(id);
    return documentReference.get().then((snapshot) async {
      if (snapshot.exists) {
        return _snapshotToEntityTransformation(snapshot);
      }
      return null;
    });
  }

  @override
  Future<void> delete(Iterable<String> idList) async {
    await Future.wait<void>(
        idList.map((id) => firestore.collection(path).doc(id).delete()));
  }

  @override
  Stream<List<T>> all() => SwitchLatestStream(firestore
          .collection(path)
          .snapshots()
          .map((snapshot) => Stream.fromFutures(snapshot.docs
              .where((documentSnapshot) =>
                  documentSnapshot.data() != null &&
                  documentSnapshot.data().isNotEmpty)
              .map(_snapshotToEntityTransformation)
              .where((element) => element != null)).toList().asStream()))
      .asBroadcastStream();

  @override
  Future<List<T>> allAsList() => firestore.collection(path).get().then(
      (snapshot) => Future.wait(snapshot.docs
          .where((documentSnapshot) =>
              documentSnapshot.data() != null &&
              documentSnapshot.data().isNotEmpty)
          .map(_snapshotToEntityTransformation)));

  @override
  Future<void> update(T entity) => updateData(entity.id, entity.toJson());

  @override
  Future<void> updateData(String id, Map<String, dynamic> data) async {
    DocumentReference documentReference = firestore.collection(path).doc(id);
    return documentReference.update(data);
  }

  @override
  Predicate<T> duplicatesPredicate(T entity) => null;
}
