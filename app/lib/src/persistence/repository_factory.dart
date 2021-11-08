// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model/commons/entity_repository.dart';
import 'package:model/css/reader_theme_repository.dart';
import 'package:model/metadata/metadata_repository.dart';
import 'package:model/model.dart';
import 'package:model/search/search_repository.dart';
import 'package:model/signin/signin.dart';
import 'package:model/storage/gdrive_service.dart';
import 'package:model/storage/gdriver_repository.dart';
import 'package:model/user/user_repository.dart';
import 'package:model/repositories/repository_factory.dart' as brf;

import 'firestore_config.dart';
import 'firestore_entity_repository.dart';
import 'firestore_repository_factory.dart';

class RepositoryFactory extends brf.RepositoryFactory {
  final FirestoreConfig firestoreConfig;
  final GdriveService gdriveService;
  final EntityRepository<SignIn> firestoreSignInRepository;
/*
        firestoreConfig,
        gdriveService,
        userRepository,
        annotationsRepository,
        fileDocumentRepository,
        firestoreSignInRepository,
        metadataRepository,
        searchRepository,
        readerThemeRepository);

 */
  RepositoryFactory._(
      this.firestoreConfig,
      this.gdriveService,
      userRepository,
      annotationsRepository,
      fileDocumentRepository,
      this.firestoreSignInRepository,
      metadataRepository,
      searchRepository,
      readerThemeRepository)
      : super(userRepository, annotationsRepository, fileDocumentRepository,
            metadataRepository, searchRepository, readerThemeRepository);

  @override
  EntityRepository<SignIn> get signInRepository => firestoreSignInRepository;

  @override
  void dispose() {
    gdriveService.dispose();
  }

  factory RepositoryFactory.create() {
    UserRepository userRepository = UserRepository();
    GdriveRepository gdriveRepository = GdriveRepository(userRepository);
    GdriveService gdriveService = GdriveService(gdriveRepository);

    FirestoreConfig firestoreConfig =
        FirestoreConfig(FirebaseFirestore.instance);
    FirestoreEntityRepository<Metadata> firestoreMetadatasRepository =
        FirestoreRepositoryFactory.createMetadataRepository(firestoreConfig);

    FirestoreEntityRepository<SignIn> firestoreSignInRepository =
        FirestoreRepositoryFactory.createSignInRepository(firestoreConfig);

    FirestoreEntityRepository<FileDocument> firestoreDocumentsRepository =
        FirestoreRepositoryFactory.createDocumentRepository(
            firestoreConfig, gdriveService, firestoreMetadatasRepository);

    FirestoreEntityRepository<Annotation> firestoreAnnotationsRepository =
        FirestoreRepositoryFactory.createAnnotationRepository(
            firestoreConfig, firestoreMetadatasRepository);

    MetadataRepository metadataRepository =
        MetadataRepository(firestoreMetadatasRepository);

    SearchRepository searchRepository = SearchRepository(
        FirestoreRepositoryFactory.createSearchRepository(
            firestoreConfig, firestoreMetadatasRepository));
    ReaderThemeRepository readerThemeRepository = ReaderThemeRepository(
        FirestoreRepositoryFactory.createReaderThemeRepository(
            firestoreConfig));

    FileDocumentRepository fileDocumentRepository = FileDocumentRepository(
        firestoreDocumentsRepository, gdriveService,
        metadataRepository: metadataRepository);

    DocumentRepository<Annotation> annotationsRepository = DocumentRepository(
        firestoreAnnotationsRepository,
        metadataRepository: metadataRepository);

    gdriveService.init(fileDocumentRepository);

    return RepositoryFactory._(
        firestoreConfig,
        gdriveService,
        userRepository,
        annotationsRepository,
        fileDocumentRepository,
        firestoreSignInRepository,
        metadataRepository,
        searchRepository,
        readerThemeRepository);
  }
}
