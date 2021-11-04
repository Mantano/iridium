import 'package:app/src/models/book.dart';
import 'package:app/src/models/notifiers/book_notifier.dart';
import 'package:app/src/models/notifiers/theme_notifier.dart';
import 'package:app/src/widgets/book_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../style.dart';
import 'book/book_add.dart';
import 'book/book_details.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeNotifier = Provider.of<ThemeNotifier>(context);
    var bookNotifier = Provider.of<BookNotifier>(context);
    // FIXME: Want to set wideScreen here but it can't be null
    // Don't know why it is not possible to initialize it here

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
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => BookAdd()));
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
