import 'dart:io';

import 'package:app/src/persistence/repository_factory.dart';
import 'package:app/src/screens/splashscreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigator/src/document_opener/cbz_document_opener.dart';
import 'package:navigator/src/document_opener/epub_document_opener.dart';
import 'package:navigator/src/document_opener/pdf_document_opener.dart';
import 'package:app/src/models/book.dart';
import 'package:app/src/models/notifiers/book_notifier.dart';
import 'package:app/src/models/notifiers/theme_notifier.dart';
import 'package:app/src/widgets/book_list.dart';
import 'package:flutter/material.dart';
import 'package:model/document/reader_sdk.dart';
import 'package:provider/provider.dart';
import 'package:model/repositories/bloc_factory.dart';
import 'package:ui_commons/document_opener/document_opener.dart';
import 'package:ui_commons/model/dependencies.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../style.dart';
import 'book/book_add.dart';
import 'book/book_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _askPermission = false;
  BlocFactory blocFactory;

  @override
  void initState() {
    super.initState();
    blocFactory = BlocFactory.create(RepositoryFactory.create());

    _initDocumentOpeners();
  }

  @override
  void dispose() {
    super.dispose();
    blocFactory?.dispose();
  }

  void _initDocumentOpeners() {
    DocumentOpener.registerDocumentOpener(
        ReaderSdk.readium,
        EpubDocumentOpener(
            blocFactory.repositoryFactory.readerThemeRepository));
    // DocumentOpener.registerDocumentOpener(
    //     ReaderSdk.video, PlayableDocumentOpener());
    // DocumentOpener.registerDocumentOpener(
    //     ReaderSdk.audio, PlayableDocumentOpener());
    DocumentOpener.registerDocumentOpener(ReaderSdk.cbz, CbzDocumentOpener());
    DocumentOpener.registerDocumentOpener(
        ReaderSdk.pdfium, PdfDocumentOpener());
  }

  Future<PermissionStatus> checkPermissionStatus() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return Permission.storage.status;
    }
    return PermissionStatus.granted;
  }

  Future<void> requestPermission(Permission permission) async {
    if (!_askPermission) {
      _askPermission = true;
      final List<Permission> permissions = <Permission>[permission];
      await permissions
          .request()
          .then((Map<Permission, PermissionStatus> permissionRequestResult) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: checkPermissionStatus(),
        builder:
            (BuildContext context, AsyncSnapshot<PermissionStatus> snapshot) {
          if (!snapshot.hasData) {
            return const Splashscreen();
          } else if (snapshot.data == PermissionStatus.denied) {
            requestPermission(Permission.storage);
            return const Splashscreen();
          }
          return _buildUI(context);
        },
      );

  DependenciesWidget _buildUI(BuildContext context) {
    var themeNotifier = Provider.of<ThemeNotifier>(context);
    var bookNotifier = Provider.of<BookNotifier>(context);
    // FIXME: Want to set wideScreen here but it can't be null
    // Don't know why it is not possible to initialize it here

    Dependencies dependencies = Dependencies(
        BlocProvider.of<ThemeBloc>(context),
        blocFactory.loginBloc,
        blocFactory.authenticationBloc,
        blocFactory.documentsBloc,
        blocFactory.annotationsBloc,
        blocFactory.metadataFilterBloc,
        blocFactory.metadatasBloc,
        blocFactory.scanBloc,
        blocFactory.searchBloc);

    return DependenciesWidget(
      dependencies: dependencies,
      child: _buildHomeFragment(context, themeNotifier, bookNotifier),
    );
  }

  Scaffold _buildHomeFragment(BuildContext context, ThemeNotifier themeNotifier,
      BookNotifier bookNotifier) {
    return Scaffold(
      appBar: _buildAppBar(context, themeNotifier),
      body: Container(
        child: MediaQuery.of(context).size.width > wideLayoutThreshold
            ? Row(
                children: <Widget>[
                  Flexible(
                    flex: 4,
                    child: BookList(),
                  ),
                  Flexible(
                    flex: 6,
                    child: BookDetails(
                        bookNotifier.books[bookNotifier.selectedIndex]),
                  ),
                ],
              )
            : const BookList(),
      ),
      floatingActionButton:
          MediaQuery.of(context).size.width < wideLayoutThreshold
              ? FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const BookAdd()));
                  },
                )
              : Container(),
    );
  }

  AppBar _buildAppBar(BuildContext context, ThemeNotifier themeNotifier) {
    return AppBar(
      title: const Text('Books'),
      actions: [
        IconButton(
          icon: themeNotifier.darkModeEnabled
              ? const Icon(Icons.brightness_7)
              : const Icon(Icons.brightness_2),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => themeNotifier.toggleTheme(),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: BookSearch());
          },
        ),
      ],
    );
  }
}

class BookSearch extends SearchDelegate<Book> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        color: Theme.of(context).iconTheme.color,
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: Theme.of(context).iconTheme.color,
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final books = Provider.of<BookNotifier>(context).books;

    final results = books
        .where((book) =>
            book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query))
        .toList();

    return BookList(books: results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final books = Provider.of<BookNotifier>(context).books;

    final results = books
        .where((book) =>
            book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query))
        .toList();

    return BookList(books: results);
  }
}
