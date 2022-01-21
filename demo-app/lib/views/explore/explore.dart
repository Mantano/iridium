import 'package:flutter/material.dart';
import 'package:iridium_app/components/body_builder.dart';
import 'package:iridium_app/components/book_card.dart';
import 'package:iridium_app/components/loading_widget.dart';
import 'package:iridium_app/util/api.dart';
import 'package:iridium_app/util/router.dart';
import 'package:iridium_app/view_models/home_provider.dart';
import 'package:iridium_app/views/genre/genre.dart';
import 'package:mno_shared/opds.dart';
import 'package:mno_shared/publication.dart';
import 'package:provider/provider.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  Api api = Api();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder:
          (BuildContext context, HomeProvider homeProvider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Explore',
            ),
          ),
          body: BodyBuilder(
            apiRequestStatus: homeProvider.apiRequestStatus,
            child: _buildBodyList(homeProvider),
            reload: () => homeProvider.getFeeds(),
          ),
        );
      },
    );
  }

  _buildBodyList(HomeProvider homeProvider) {
    return ListView.builder(
//      itemCount: homeProvider.top?.feed?.links.length ?? 0,
      itemCount: homeProvider.top?.feed?.facets[1].links.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        Link? link = homeProvider.top?.feed?.facets[1].links[index];

        // We don't need the tags from 0-9 because
        // they are not categories
        if (link == null || index < 10) {
          return const SizedBox();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: <Widget>[
              _buildSectionHeader(link),
              const SizedBox(height: 10.0),
              _buildSectionBookList(link),
            ],
          ),
        );
      },
    );
  }

  _buildSectionHeader(Link link) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              '${link.title}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              MyRouter.pushPage(
                context,
                Genre(
                  title: '${link.title}',
                  url: link.href,
                ),
              );
            },
            child: Text(
              'See All',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildSectionBookList(Link link) {
    return FutureBuilder<ParseData>(
      future: api.getCategory(link.href),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          ParseData? category = snapshot.data;

          return SizedBox(
            height: 200.0,
            child: Center(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                scrollDirection: Axis.horizontal,
                itemCount: category?.feed?.publications.length ?? 0,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  Publication entry = category!.feed!.publications[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 10.0,
                    ),
                    child: BookCard(
                      img: entry.links[1].href,
                      entry: entry,
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return const SizedBox(
            height: 200.0,
            child: LoadingWidget(),
          );
        }
      },
    );
  }
}
