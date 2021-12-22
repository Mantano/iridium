// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:mno_navigator/publication.dart';

class ReaderAppBar extends StatefulWidget {
  final ReaderContext readerContext;
  final PublicationController publicationController;

  const ReaderAppBar({
    Key? key,
    required this.readerContext,
    required this.publicationController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReaderAppBarState();
}

class ReaderAppBarState extends State<ReaderAppBar> {
  static const double height = kToolbarHeight;
  late StreamSubscription<bool> _streamSubscription;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.readerContext.toolbarStream.listen((visible) {
      setState(() {
        opacity = (visible) ? 1.0 : 0.0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: IgnorePointer(
          ignoring: opacity < 1.0,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              height: height,
              child: AppBar(
                backgroundColor: Colors.black,
                iconTheme: IconThemeData(
                  color: Theme.of(context).iconTheme.color,
                ),
                actions: [
                  IconButton(
                    onPressed: _onBookmarkPressed,
                    icon: const ImageIcon(
                      AssetImage(
                        'assets/images/icon_bookmark.png',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _onSettingsPressed,
                    icon: const ImageIcon(
                      AssetImage(
                        'assets/images/icon_settings.png',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _onMenuPressed,
                    icon: const ImageIcon(
                      AssetImage(
                        'assets/images/icon_menu.png',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _onBookmarkPressed() {
    Fimber.d("_onBookmarkPressed");
  }

  void _onSettingsPressed() {
    Fimber.d("onSettingsPressed");
  }

  void _onMenuPressed() {
    Fimber.d("onMenuPressed");
  }
}
