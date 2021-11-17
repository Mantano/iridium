import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iridium_app/components/body_builder.dart';
import 'package:iridium_app/components/book_card.dart';
import 'package:iridium_app/components/book_list_item.dart';
// import 'package:iridium_app/models/category.dart';
import 'package:iridium_app/util/consts.dart';
import 'package:iridium_app/util/router.dart';
import 'package:iridium_app/view_models/home_provider.dart';
import 'package:iridium_app/views/genre/genre.dart';
import 'package:mno_shared/publication.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback(
      (_) => Provider.of<HomeProvider>(context, listen: false).getFeeds(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<HomeProvider>(
      builder:
          (BuildContext context, HomeProvider homeProvider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              Constants.appName,
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
          body: _buildBody(homeProvider),
        );
      },
    );
  }

  Widget _buildBody(HomeProvider homeProvider) {
    return BodyBuilder(
      apiRequestStatus: homeProvider.apiRequestStatus,
      child: _buildBodyList(homeProvider),
      reload: () => homeProvider.getFeeds(),
    );
  }

  Widget _buildBodyList(HomeProvider homeProvider) {
    return RefreshIndicator(
      onRefresh: () => homeProvider.getFeeds(),
      child: ListView(
        children: <Widget>[
          _buildFeaturedSection(homeProvider),
          const SizedBox(height: 20.0),
          _buildSectionTitle('Categories'),
          const SizedBox(height: 10.0),
          _buildGenreSection(homeProvider),
          const SizedBox(height: 20.0),
          _buildSectionTitle('Recently Added'),
          const SizedBox(height: 20.0),
          _buildNewSection(homeProvider),
        ],
      ),
    );
  }

  _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _buildFeaturedSection(HomeProvider homeProvider) {
    return SizedBox(
      height: 200.0,
      child: Center(
        child: ListView.builder(
          primary: false,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          scrollDirection: Axis.horizontal,
          itemCount: homeProvider.top?.feed?.publications.length ?? 0,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            Publication? publication =
                homeProvider.top?.feed?.publications[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: BookCard(
                img: publication?.links[1].href,
                entry: publication,
              ),
            );
          },
        ),
      ),
    );
  }

  _buildGenreSection(HomeProvider homeProvider) {
    return SizedBox(
      height: 50.0,
      child: Center(
        child: ListView.builder(
          primary: false,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          scrollDirection: Axis.horizontal,
          itemCount: homeProvider.top?.feed?.facets[1].links.length ?? 0,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            Link? link = homeProvider.top?.feed?.facets[1].links[index];

            // // We don't need the tags from 0-9 because
            // // they are not categories
            // if (false && (link == null || index < 10)) {
            //   return const SizedBox();
            // }

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  onTap: () {
                    Fimber.d("Opening ${link!.title} at URL: ${link.href}");
                    MyRouter.pushPage(
                      context,
                      Genre(
                        title: '${link.title}',
                        url: link.href,
                      ),
                    );
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        '${link!.title}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _buildNewSection(HomeProvider homeProvider) {
    return ListView.builder(
      primary: false,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: homeProvider.recent?.feed?.publications.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        Publication? publication =
            homeProvider.recent?.feed?.publications[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: BookListItem(
            img: publication?.manifest.links[1].href,
            title: publication?.metadata.title,
            author: publication?.metadata.authors[0].name ?? "** author **",
            desc: publication?.metadata.description ?? "** description **",
            publication: publication,
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
