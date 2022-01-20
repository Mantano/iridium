import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iridium_app/components/loading_widget.dart';
import 'package:iridium_app/util/router.dart';
import 'package:mno_shared/publication.dart';
import 'package:uuid/uuid.dart';

import '../views/details/details.dart';

class BookListItem extends StatelessWidget {
  final String? img;
  final String? title;
  final String? author;
  final String desc;
  final Publication? publication;

  BookListItem({
    Key? key,
    this.img,
    this.title,
    this.author,
    this.desc = "** description **",
    this.publication,
  }) : super(key: key);

  static const uuid = Uuid();
  final String imgTag = uuid.v4();
  final String titleTag = uuid.v4();
  final String authorTag = uuid.v4();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        MyRouter.pushPage(
          context,
          Details(
            publication: publication!,
            imgTag: imgTag,
            titleTag: titleTag,
            authorTag: authorTag,
          ),
        );
      },
      child: SizedBox(
        height: 150.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              elevation: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
                child: Hero(
                  tag: imgTag,
                  child: CachedNetworkImage(
                    imageUrl: '$img',
                    placeholder: (context, url) => const SizedBox(
                      height: 150.0,
                      width: 100.0,
                      child: LoadingWidget(
                        isImage: true,
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/place.png',
                      fit: BoxFit.cover,
                      height: 150.0,
                      width: 100.0,
                    ),
                    fit: BoxFit.cover,
                    height: 150.0,
                    width: 100.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: titleTag,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        '${title?.replaceAll(r'\', '')}',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headline6?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Hero(
                    tag: authorTag,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        '$author',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    '${desc.length < 100 ? desc : desc.substring(0, 100)}...'
                        .replaceAll(r'\n', '\n')
                        .replaceAll(r'\r', '')
                        .replaceAll(r'\"', '"'),
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Theme.of(context).textTheme.caption?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
