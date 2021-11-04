import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/src/models/notifiers/book_notifier.dart';
import 'package:app/src/widgets/book_item.dart';
import 'package:app/src/models/book.dart';

class BookList extends StatelessWidget {
  final List<Book>? _books;

  const BookList({Key? key, books})
      : _books = books,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var bookNotifier = Provider.of<BookNotifier>(context);

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      separatorBuilder: ((context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Divider(
            color: Colors.grey.withOpacity(0.3),
            height: 18.0,
          ),
        );
      }),
      itemCount: _books?.length ?? bookNotifier.books.length,
      itemBuilder: ((context, index) {
        return BookItem(_books?.elementAt(index) ?? bookNotifier.books[index]);
      }),
    );
  }
}
