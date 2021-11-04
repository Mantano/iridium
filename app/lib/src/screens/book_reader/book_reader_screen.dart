import 'package:app/src/models/book.dart';
import 'package:app/src/screens/book_reader/widgets/book_view.dart';
import 'package:app/src/utils/simple_asset_provider.dart';
import 'package:flutter/material.dart';
import 'package:app/src/utils/utils.dart';

import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';

class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen(Book book, {Key? key, required this.title})
      : super(key: key);

  final String title;

  @override
  _BookReaderScreenState createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  late ServerBloc serverBloc;
  late String address;

  bool isStarted = false;
  late PageController pageController;
  PubBox? pubBox;
  List<Link>? spines;

  @override
  void initState() {
    super.initState();

    serverBloc = ServerBloc();
    serverBloc.stream.listen((event) async {
      if (event is ServerStarted) {
        setState(() {
          address = event.address;
          isStarted = true;
          spines = pubBox?.publication.readingOrder;
        });

        pageController = PageController();

        debugPrint(address);
      } else if (event is ServerClosed) {
        setState(() {
          isStarted = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            spines != null
                ? Expanded(child: BookView(address, spines!, pageController))
                : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          serverBloc.add(ShutdownServer());
          setState(() {
            //
          });

          var dirPath = (await Utils.getFileFromAsset(
                  'assets/books/accessible_epub_3.epub'))
              .path;

          pubBox = await EpubParser().parse(dirPath);
          if (pubBox != null) {
            serverBloc.add(StartServer([
              AssetsRequestHandler("assets",
                  assetProvider: SimpleAssetProvider()),
              FetcherRequestHandler(pubBox!.publication)
            ]));
          }
        },
        tooltip: 'Open Book',
        child: const Icon(Icons.book),
      ),
    );
  }

  @override
  void dispose() {
    serverBloc.add(ShutdownServer());
    serverBloc.close();
    super.dispose();
  }
}
