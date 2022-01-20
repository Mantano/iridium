import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iridium_app/view_models/favorites_provider.dart';
import 'package:provider/provider.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  void initState() {
    super.initState();
    getFavorites();
  }

  @override
  void deactivate() {
    super.deactivate();
    getFavorites();
  }

  getFavorites() {
    SchedulerBinding.instance?.addPostFrameCallback(
      (_) {
        if (mounted) {
          Provider.of<FavoritesProvider>(context, listen: false).getFavorites();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (BuildContext context, FavoritesProvider favoritesProvider,
          Widget? child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Favorites',
            ),
          ),
          body: favoritesProvider.posts.isEmpty
              ? _buildEmptyListView()
              : _buildGridView(favoritesProvider),
        );
      },
    );
  }

  _buildEmptyListView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            'assets/images/empty.png',
            height: 300.0,
            width: 300.0,
          ),
          const Text(
            'Nothing is here',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _buildGridView(FavoritesProvider favoritesProvider) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      shrinkWrap: true,
      itemCount: favoritesProvider.posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 200 / 340,
      ),
      itemBuilder: (BuildContext context, int index) {
        throw UnimplementedError(
            "List of favorites not completely implemented");
        // Entry entry = Publication.fromJson(favoritesProvider.posts[index]['item']);
        // return Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 5.0),
        //   child: BookItem(
        //     img: entry.link[1].href,
        //     title: entry.title.t,
        //     publication: entry,
        //   ),
        // );
      },
    );
  }
}
