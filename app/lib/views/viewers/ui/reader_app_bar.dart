// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iridium_app/util/router.dart';
import 'package:iridium_app/views/viewers/ui/reader_navigation_screen.dart';
import 'package:iridium_app/views/viewers/ui/settings/settings_panel.dart';
import 'package:mno_navigator/epub.dart';
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
  final GlobalKey _settingsKey = GlobalKey();
  late StreamSubscription<bool> _streamSubscription;
  double opacity = 0.0;
  OverlayEntry? _overlayEntry;

  ReaderContext get readerContext => widget.readerContext;

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
    _overlayEntry?.remove();
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
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                    key: _settingsKey,
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
    readerContext.toggleBookmark();
  }

  void _onSettingsPressed() {
    Fimber.d("onSettingsPressed");
    ViewerSettingsBloc viewerSettingsBloc =
        BlocProvider.of<ViewerSettingsBloc>(context);
    ReaderThemeBloc readerThemeBloc = BlocProvider.of<ReaderThemeBloc>(context);
    _overlayEntry ??= OverlayEntry(builder: (context) {
      RenderBox? renderButton =
          _settingsKey.currentContext?.findRenderObject() as RenderBox?;
      Offset? position = renderButton
          ?.localToGlobal(renderButton.size.bottomCenter(Offset.zero));
      return SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (state) => _overlayEntry?.remove(),
            ),
            Positioned(
              top: (position?.dy ?? 0.0) - MediaQuery.of(context).padding.top,
              right: 0,
              width: MediaQuery.of(context).size.width * 2 / 3,
              child: SettingsPanel(
                readerContext: readerContext,
                viewerSettingsBloc: viewerSettingsBloc,
                readerThemeBloc: readerThemeBloc,
              ),
            ),
          ],
        ),
      );
    });
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _onMenuPressed() {
    MyRouter.pushPage(
        context, ReaderNavigationScreen(readerContext: readerContext));
  }
}
