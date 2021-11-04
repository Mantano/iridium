import 'package:app/src/models/book.dart';
import 'package:app/src/models/notifiers/book_notifier.dart';
import 'package:app/src/models/notifiers/theme_notifier.dart';
import 'package:app/src/theme/colors.dart';
import 'package:app/src/widgets/book_cover.dart';
import 'package:app/src/widgets/buttons/confirm_button.dart';
import 'package:app/src/widgets/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../../style.dart';
import 'book_add.dart';

class BookDetails extends StatelessWidget {
  final Book _book;

  const BookDetails(Book book, {Key? key})
      : _book = book,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var bookNotifier = Provider.of<BookNotifier>(context);
    var themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: MediaQuery.of(context).size.width < wideLayoutThreshold
          ? _buildAppBar(context)
          : null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: BookCover(
                  url: _book.coverUrl,
                  boxFit: BoxFit.fitHeight,
                  height: 325,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 4.0),
                child: Text(
                  _book.title,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'By ',
                        style: Theme.of(context).textTheme.caption?.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                      TextSpan(
                        text: _book.author,
                        style: Theme.of(context).textTheme.caption?.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      TextSpan(
                        text: ' in ',
                        style: Theme.of(context).textTheme.caption?.copyWith(
                            fontSize: 16.0, fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: _book.category,
                        style: Theme.of(context).textTheme.caption?.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              StarRating(
                starCount: 5,
                rating: (_book.rating / 2).toDouble(),
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                height: 38.0,
              ),
              Text(
                _book.description,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .caption
                        ?.color
                        ?.withOpacity(0.85),
                    fontFamily: 'GoogleFonts.nunito().fontFamily',
                    fontSize: 16.0),
              ),
              ConfirmButton(
                text: 'READ NOW',
                onPressed: () {
                  print('Opening book...');
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: MediaQuery.of(context).size.width >
              wideLayoutThreshold
          ? SpeedDial(
              overlayOpacity: 0.25,
              overlayColor:
                  themeNotifier.darkModeEnabled ? Colors.black : Colors.white,
              animatedIcon: AnimatedIcons.home_menu,
              children: [
                _buildSubFab('Remove', Icons.delete,
                    () => _showDeleteDialog(context, bookNotifier)),
                _buildSubFab(
                    'Edit',
                    Icons.edit,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => BookAdd(book: _book)))),
                _buildSubFab(
                    'Add',
                    Icons.add,
                    () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => BookAdd())))
              ],
            )
          : FloatingActionButton(
              child: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, bookNotifier),
            ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Details'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.edit,
            size: 22.0,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BookAdd(book: _book),
              ),
            );
          },
        ),
      ],
    );
  }

  SpeedDialChild _buildSubFab(
      String label, IconData iconData, void Function()? onTap) {
    return SpeedDialChild(
      label: label,
      labelStyle: const TextStyle(color: kTextTitleColor),
      child: Icon(iconData),
      onTap: onTap,
    );
  }

  void _showDeleteDialog(
      BuildContext context, BookNotifier bookNotifier) async {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      primary: Colors.white.withOpacity(0.9),
      textStyle: TextStyle(color: Theme.of(context).textTheme.caption?.color),
    );

    final dialog = AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Delete book?'),
      content: Text(
        'This will delete the book from your book list',
        style: TextStyle(color: Theme.of(context).textTheme.caption?.color),
      ),
      actions: [
        TextButton(
          child: const Text('CANCEL'),
          style: flatButtonStyle,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('ACCEPT'),
          style: flatButtonStyle,
          onPressed: () {
            bookNotifier.removeBook(_book);
            // Pop details screen
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    await showDialog(context: context, builder: (context) => dialog);
  }
}
