import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iridium_app/components/body_builder.dart';
import 'package:iridium_app/components/book_list_item.dart';
import 'package:iridium_app/components/loading_widget.dart';
import 'package:iridium_app/view_models/genre_provider.dart';
import 'package:mno_shared/publication.dart';
import 'package:provider/provider.dart';

class Genre extends StatefulWidget {
  final String title;
  final String url;

  const Genre({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  _GenreState createState() => _GenreState();
}

class _GenreState extends State<Genre> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback(
      (_) => Provider.of<GenreProvider>(context, listen: false)
          .getFeed(widget.url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, GenreProvider provider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(widget.title),
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(GenreProvider provider) {
    return BodyBuilder(
      apiRequestStatus: provider.apiRequestStatus,
      child: _buildBodyList(provider),
      reload: () => provider.getFeed(widget.url),
    );
  }

  _buildBodyList(GenreProvider provider) {
    return ListView(
      controller: provider.controller,
      children: <Widget>[
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          shrinkWrap: true,
          itemCount: provider.items.length,
          itemBuilder: (BuildContext context, int index) {
            Publication entry = provider.items[index];
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: BookListItem(
                img: entry.links[1].href,
                title: entry.metadata.title,
                author: entry.metadata.authors[0].name,
                desc: entry.metadata.description ?? "** description **",
                publication: entry,
              ),
            );
          },
        ),
        const SizedBox(height: 10.0),
        provider.loadingMore
            ? SizedBox(
                height: 80.0,
                child: _buildProgressIndicator(),
              )
            : const SizedBox(),
      ],
    );
  }

  _buildProgressIndicator() {
    return const LoadingWidget();
  }
}
