import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:iridium_app/components/book_list_item.dart';
import 'package:iridium_app/components/description_text.dart';
import 'package:iridium_app/components/loading_widget.dart';
import 'package:iridium_app/util/router.dart';
import 'package:iridium_app/view_models/details_provider.dart';
import 'package:iridium_app/views/viewers/epub_screen.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:provider/provider.dart';

class Details extends StatefulWidget {
  final Publication? publication;
  final String imgTag;
  final String titleTag;
  final String authorTag;

  const Details({
    Key? key,
    this.publication,
    required this.imgTag,
    required this.titleTag,
    required this.authorTag,
  }) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  void initState() {
    super.initState();
    if (widget.publication != null) {
      SchedulerBinding.instance?.addPostFrameCallback(
        (_) {
          Provider.of<DetailsProvider>(context, listen: false)
              .setEntry(widget.publication);
          Provider.of<DetailsProvider>(context, listen: false).getFeed(widget
              .publication!.metadata.authors[0].links[0].href
              .replaceAll(r'\&lang=en', ''));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailsProvider>(
      builder: (BuildContext context, DetailsProvider detailsProvider,
          Widget? child) {
        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                onPressed: () async {
                  if (detailsProvider.faved) {
                    detailsProvider.removeFav();
                  } else {
                    detailsProvider.addFav();
                  }
                },
                icon: Icon(
                  detailsProvider.faved ? Icons.favorite : Feather.heart,
                  color: detailsProvider.faved ? Colors.red : null,
                ),
              ),
              IconButton(
                onPressed: () => _share(),
                icon: const Icon(
                  Feather.share,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: <Widget>[
              const SizedBox(height: 10.0),
              _buildImageTitleSection(detailsProvider),
              const SizedBox(height: 30.0),
              _buildSectionTitle('Book Description'),
              _buildDivider(),
              const SizedBox(height: 10.0),
              DescriptionTextWidget(
                text: '${widget.publication?.metadata.description}',
              ),
              const SizedBox(height: 30.0),
              _buildSectionTitle('More from Author'),
              _buildDivider(),
              const SizedBox(height: 10.0),
              _buildMoreBook(detailsProvider),
            ],
          ),
        );
      },
    );
  }

  _buildDivider() {
    return Divider(
      color: Theme.of(context).textTheme.caption?.color,
    );
  }

  _buildImageTitleSection(DetailsProvider detailsProvider) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Hero(
          tag: widget.imgTag,
          child: CachedNetworkImage(
            imageUrl: '${widget.publication?.links[1].href}',
            placeholder: (context, url) => const SizedBox(
              height: 200.0,
              width: 130.0,
              child: LoadingWidget(),
            ),
            errorWidget: (context, url, error) => const Icon(Feather.x),
            fit: BoxFit.cover,
            height: 200.0,
            width: 130.0,
          ),
        ),
        const SizedBox(width: 20.0),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 5.0),
              Hero(
                tag: widget.titleTag,
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    '${widget.publication?.metadata.title.replaceAll(r'\', '')}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              Hero(
                tag: widget.authorTag,
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    '${widget.publication?.metadata.authors[0].name}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              _buildCategory(widget.publication, context),
              Center(
                child: SizedBox(
                  height: 40.0,
                  width: MediaQuery.of(context).size.width,
                  child: _buildDownloadReadButton(detailsProvider, context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  _buildMoreBook(DetailsProvider provider) {
    if (provider.loading) {
      return const SizedBox(
        height: 100.0,
        child: LoadingWidget(),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.related.feed?.publications.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          Publication? entry = provider.related.feed?.publications[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: BookListItem(
              img: entry?.links[1].href,
              title: entry?.metadata.title,
              author: entry?.metadata.authors[0].name,
              desc: entry?.metadata.description ?? "** description **",
              publication: entry,
            ),
          );
        },
      );
    }
  }

  openBook(DetailsProvider provider) async {
    List dlList = await provider.getDownload();
    if (dlList.isNotEmpty) {
      // dlList is a list of the downloads relating to this Book's id.
      // The list will only contain one item since we can only
      // download a book once. Then we use `dlList[0]` to choose the
      // first value from the string as out local book path
      Map dl = dlList[0];
      String path = dl['path'];
      MyRouter.pushPage(
        context,
        EpubScreen(
          asset: FileAsset(File(path)),
        ),
      );
    }
  }

  _buildDownloadReadButton(DetailsProvider provider, BuildContext context) {
    if (provider.downloaded) {
      return TextButton(
        onPressed: () => openBook(provider),
        child: const Text(
          'Read Book',
        ),
      );
    } else {
      return TextButton(
        onPressed: () {
          var epubDownloadLink =
              widget.publication?.links.firstWithMediaType(MediaType.epub);
          if (epubDownloadLink != null &&
              widget.publication != null &&
              widget.publication?.metadata.title != null) {
            provider.downloadFile(
              context,
              epubDownloadLink.href,
              widget.publication!.metadata.title
                  .replaceAll(' ', '_')
                  .replaceAll(r"\'", "'"),
            );
          }
        },
        child: const Text(
          'Download',
        ),
      );
    }
  }

  _buildCategory(Publication? publication, BuildContext context) {
    if (publication == null) {
      return const SizedBox();
    } else {
      return SizedBox(
        height: publication.metadata.subjects.length < 3 ? 55.0 : 95.0,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: publication.metadata.subjects.length > 4
              ? 4
              : publication.metadata.subjects.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 210 / 80,
          ),
          itemBuilder: (BuildContext context, int index) {
            Subject cat = publication.metadata.subjects[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      cat.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: cat.name.length > 18 ? 6.0 : 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  _share() {
    // Share.text(
    //   '${widget.entry.title.t} by ${widget.entry.author.name.t}',
    //   'Read/Download ${widget.entry.title.t} from ${widget.entry.link[3].href}.',
    //   'text/plain',
    // );
  }
}
