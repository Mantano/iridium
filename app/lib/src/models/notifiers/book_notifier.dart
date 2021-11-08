import 'package:flutter/widgets.dart';

import '../book.dart';

/// Class used to manage the state in the app
/// Contains all the books that are available
/// and provides methods to manage the state such as
/// addBook, removeBook
class BookNotifier extends ChangeNotifier {
  List<Book> _books = initialBooks;
  List<Book> get books => _books;
  set books(List<Book> books) {
    _books = books;
    notifyListeners();
  }

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  BookNotifier();

  Book addBook(Book book) {
    books = (_books..add(book));
    return book;
  }

  Book removeBook(Book book) {
    books = (_books..remove(book));
    return book;
  }

  Book updateBook(Book oldBook, Book newBook) {
    // TODO: Give a book an unique property so we can search in the books
    // and update the properties with the updated version
    oldBook.author = newBook.author;
    oldBook.category = newBook.category;
    oldBook.coverUrl = newBook.coverUrl;
    oldBook.description = newBook.description;
    oldBook.rating = newBook.rating;
    oldBook.title = newBook.title;

    final index = books.indexOf(oldBook);
    books[index] = newBook;
    notifyListeners();
    return newBook;
  }
}
