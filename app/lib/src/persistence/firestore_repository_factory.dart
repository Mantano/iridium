// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fimber/fimber.dart';
import 'package:model/annotation/annotation.dart';
import 'package:model/audio/audio.dart';
import 'package:model/book/book.dart';
import 'package:model/css/reader_theme.dart';
import 'package:model/document/file_document.dart';
import 'package:model/model.dart';
import 'package:model/signin/signin.dart';
import 'package:model/storage/gdrive_service.dart';
import 'package:universal_io/io.dart';
import 'package:utils/io/internet_utils.dart';

import 'firestore_config.dart';
import 'firestore_entity_repository.dart';

class FirestoreRepositoryFactory {
  static const String metadataPath = 'metadata/user';
  static const String documentPath = 'document/user';
  static const String annotationPath = 'annotation/user';
  static const String searchInPath = 'search/user';
  static const String signInPath = 'signin/user';
  static const String readerThemePath = 'reader_theme/user';

  static FirestoreEntityRepository<SignIn> createSignInRepository(
          FirestoreConfig firestoreConfig) =>
      FirestoreEntityRepository<SignIn>(
          firestoreConfig,
          signInPath,
          (DocumentSnapshot snapshot) async =>
              SignIn.fromJson(snapshot.id, snapshot.data()));

  static FirestoreEntityRepository<Metadata> createMetadataRepository(
          FirestoreConfig firestoreConfig) =>
      FirestoreEntityRepository<Metadata>(
          firestoreConfig,
          metadataPath,
          (DocumentSnapshot snapshot) async =>
              Metadata.fromJson(snapshot.id, snapshot.data()));

  static FirestoreEntityRepository<ReaderTheme> createReaderThemeRepository(
          FirestoreConfig firestoreConfig) =>
      FirestoreEntityRepository<ReaderTheme>(
          firestoreConfig,
          readerThemePath,
          (DocumentSnapshot snapshot) async =>
              ReaderTheme.fromJson(snapshot.id, snapshot.data()));

  static FirestoreEntityRepository<FileDocument> createDocumentRepository(
          FirestoreConfig firestoreConfig,
          GdriveService gdriveService,
          FirestoreEntityRepository<Metadata> firestoreMetadatasRepository) =>
      FirestoreEntityRepository<FileDocument>(
          firestoreConfig,
          documentPath,
          _snapshotToDocumentTransformation(
              gdriveService, firestoreMetadatasRepository));

  static FirestoreEntityRepository<Annotation> createAnnotationRepository(
          FirestoreConfig firestoreConfig,
          FirestoreEntityRepository<Metadata> firestoreMetadataRepository) =>
      FirestoreEntityRepository<Annotation>(
          firestoreConfig,
          annotationPath,
          (DocumentSnapshot snapshot) async =>
              Annotation.fromJson(snapshot.id, snapshot.data()));

  static SnapshotToEntityTransformation<FileDocument>
      _snapshotToDocumentTransformation(
              GdriveService gdriveService,
              FirestoreEntityRepository<Metadata>
                  firestoreMetadataRepository) =>
          (DocumentSnapshot snapshot) {
            FileDocument document = _mapJsonToDocument(snapshot);
            if (document != null && firestoreMetadataRepository != null) {
              return Stream.fromFutures(document.metadataRefs.map((mRef) =>
                      firestoreMetadataRepository
                          .get(mRef.id)
                          .then((m) => mRef.metadata = m)))
                  .toList()
                  .then((_) => InternetUtils.isOnline().then((_) {
                        _loadCoverIfNeeded(gdriveService, document);
                        return document..sanitize();
                      }));
            }
            return Future.value(null);
          };

  static FirestoreEntityRepository<Search> createSearchRepository(
          FirestoreConfig firestoreConfig,
          FirestoreEntityRepository<Metadata> firestoreMetadataRepository) =>
      FirestoreEntityRepository<Search>(firestoreConfig, searchInPath,
          _snapshotToSearchTransformation(firestoreMetadataRepository));

  static SnapshotToEntityTransformation<Search> _snapshotToSearchTransformation(
          FirestoreEntityRepository<Metadata> firestoreMetadataRepository) =>
      (DocumentSnapshot snapshot) {
        Search search = Search.fromJson(snapshot.id, snapshot.data());
        return Stream.fromFutures(search.filters.map((mRef) =>
                firestoreMetadataRepository
                    .get(mRef.id)
                    .then((m) => mRef.metadata = m)))
            .toList()
            .then((_) => search..sanitize());
      };

  static FileDocument _mapJsonToDocument(DocumentSnapshot snapshot) {
    try {
      if (snapshot == null) {
        return null;
      }
      if (snapshot["mimetypeCategory"] == null) {
        Fimber.d("mimetypeCategory is null");
        return null;
      }

      MimetypeCategory mimetypeCategory =
          MimetypeCategory.from(snapshot["mimetypeCategory"] as int);
      if (mimetypeCategory == null) {
        Fimber.d("mimetypeCategory is null");
        return null;
      }
      switch (mimetypeCategory) {
        case MimetypeCategory.book:
          return Book.fromJson(snapshot.id, snapshot.data());
        case MimetypeCategory.video:
          return Video.fromJson(snapshot.id, snapshot.data());
        case MimetypeCategory.document:
          return FileDocument.fromJson(snapshot.id, snapshot.data());
        case MimetypeCategory.audio:
          return Audio.fromJson(snapshot.id, snapshot.data());
        default:
          return null;
      }
    } catch (e, st) {
      Fimber.d("ERROR", ex: e, stacktrace: st);
      return null;
    }
  }

  static void _loadCoverIfNeeded(
      GdriveService gdriveService, FileDocument document) {
    if (document.coverFile != null) {
      String coverPath = document.absoluteCoverPath;
      gdriveService.download(File(coverPath), document.coverFile);
    }
  }
}
