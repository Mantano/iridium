// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';
import 'dart:math';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/epub.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';
import 'package:model/blocs/scan/cover/cover_generator.dart';
import 'package:model/model.dart';
import 'package:ui_commons/document_opener/document_opener.dart';
import 'package:ui_commons/ui/lcp_dialog_authentication.dart';
import 'package:ui_commons/widgets/utils/user_exception_dialog.dart';
import 'package:universal_io/io.dart';
import 'package:navigator/src/book/ui/drawer/book_reader_drawer.dart';
import 'package:navigator/src/book/ui/reader_app_bar.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/book/ui/reader_toolbar.dart';
import 'package:navigator/src/book/ui/thumbnails_page_mapping.dart';
import 'package:navigator/src/document/ui/document_screen.dart';
import 'package:navigator/src/epub/bloc/current_spine_item_bloc.dart';
import 'package:navigator/src/epub/model/commands.dart';
import 'package:navigator/src/epub/model/readium_location.dart';

abstract class BookScreen extends StatefulWidget {
  final Book book;
  final bool simplifiedMode;
  final OnCloseDocument onCloseDocument;

  const BookScreen({
    Key key,
    @required this.book,
    @required this.simplifiedMode,
    @required this.onCloseDocument,
  })  : assert(book != null),
        assert(simplifiedMode != null),
        super(key: key);
}

abstract class BookScreenState<T extends BookScreen> extends DocumentState<T> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool flingMode = false;
  FileDocumentsBloc fileDocumentsBloc;
  AnnotationsBloc annotationsBloc;
  ServerBloc serverBloc;
  CurrentSpineItemBloc currentSpineItemBloc;
  ReaderContext readerContext;
  StreamSubscription<ReaderCommand> readerCommandSubscription;

  @override
  Document get document => book;

  @override
  OnCloseDocument get onCloseDocument => widget.onCloseDocument;

  Book get book => widget.book;

  bool get pageControllerAttached;

  void jumpToPage(int page);

  List<RequestHandler> get handlers;

  @override
  void initState() {
    super.initState();
    serverBloc = ServerBloc();
    currentSpineItemBloc = CurrentSpineItemBloc();
    serverBloc.stream.listen((ServerState state) {
      if (state is ServerStarted) {
        readerCommandSubscription?.cancel();
        readerCommandSubscription =
            readerContext.commandsStream.listen(onReaderCommand);
        if (readerContext.lastPosition.location != null) {
          readerContext.execute(
              GoToLocationCommand(readerContext.lastPosition.location));
        }
      }
      if (state is ServerClosed) {
        onServerClosed();
      }
    });
  }

  void onReaderCommand(ReaderCommand command) {
    if (pageControllerAttached) {
      jumpToPage(command.spineItemIndex);
      if (_scaffoldKey.currentState.isEndDrawerOpen) {
        Navigator.pop(context);
      }
    }
  }

  Future<ReaderContext> readerContextFuture(BuildContext context) async {
    AnnotationsBloc annotationsBloc = BlocProvider.of<AnnotationsBloc>(context);
    Streamer streamer = await StreamerFactory.createStreamer(
        authentication: LcpDialogAuthentication());
    FileAsset asset = FileAsset(File(book.absoluteFilepath));
    Fimber.d("asset: $asset");
    UserException userException;
    Publication publication;
    try {
      PublicationTry<Publication> publicationResult = await streamer
          .open(asset, true, sender: context)
          .onError((error, stackTrace) {
        if (error is UserException) {
          return PublicationTry.failure(error);
        }
        return PublicationTry.failure(OpeningException.unsupportedFormat);
      });
      publication = publicationResult?.onFailure((ex) {
        userException = ex;
      })?.getOrNull();
      if (publication != null) {
        book.nbPages = publication.nbPages;
        if (book.coverFile?.fileId == null) {
          FileDocumentsBloc fileDocumentBloc =
              BlocProvider.of<FileDocumentsBloc>(context);
          BookCoverGenerator(fileDocumentBloc.documentRepository, publication)
              .setCover(document);
        }
      }
    } on UserException catch (ex) {
      userException = ex;
    }
    ThumbnailsPageMapping thumbnailsPageMapping =
        initThumbnailsPageMapping(publication);
    // Annotation lastPosition = await _initLastPosition();
    Annotation lastPosition = Annotation.position(book.id);
    Fimber.d("lastPosition: $lastPosition");
    return ReaderContext(
      simplifiedMode: widget.simplifiedMode,
      annotationsBloc: annotationsBloc,
      userException: userException,
      book: book,
      asset: asset,
      mediaType: await asset.mediaType,
      lastPosition: lastPosition,
      publication: publication,
      thumbnailsPageMapping: thumbnailsPageMapping,
    );
  }

  ThumbnailsPageMapping initThumbnailsPageMapping(Publication publication) =>
      ThumbnailsPageMapping(widget.book);

  Future<Annotation> _initLastPosition() async {
    Annotation lastPosition;
    if (book.lastPositionRef != null) {
      lastPosition =
          await annotationsBloc.documentRepository.get(book.lastPositionRef);
    }
    if (lastPosition == null) {
      lastPosition = Annotation.position(book.id);
      await annotationsBloc.documentRepository.add(lastPosition,
          continuation: () {
        book.lastPositionRef = lastPosition.id;
        fileDocumentsBloc.documentRepository.save(book);
      });
    }
    return lastPosition;
  }

  @protected
  void saveBookPosition() {
    annotationsBloc.documentRepository.save(readerContext.lastPosition);
    book.lastPage = readerContext.currentPageNumber;
    book.nbPages = readerContext.publication.nbPages;
    fileDocumentsBloc.documentRepository.save(book);
  }

  @override
  Widget build(BuildContext context) {
    // fileDocumentsBloc = BlocProvider.of<FileDocumentsBloc>(context);
    // annotationsBloc = BlocProvider.of<AnnotationsBloc>(context);
    return BlocProvider<CurrentSpineItemBloc>(
      create: (BuildContext context) => currentSpineItemBloc,
      child: FutureBuilder(
          future: readerContextFuture(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return buildWaitingScreen(context);
            } else {
              readerContext = snapshot.data;
              if (readerContext.hasError) {
                _displayErrorDialog(readerContext.userException);
                return buildWaitingScreen(context);
              }
              int initialPage = _initPageFromLocation();
              initPageController(initialPage);
              onPageChanged(initialPage);
              List<Link> spine = readerContext.publication.pageLinks;
              serverBloc.add(StartServer(handlers));
              return ReaderContextWidget(
                readerContext: readerContext,
                child: WillPopScope(
                  onWillPop: _onWillPop,
                  child: Scaffold(
                    key: _scaffoldKey,
                    endDrawer: _buildReaderDrawer(),
                    body: BlocBuilder(
                        bloc: serverBloc,
                        builder: (BuildContext context, ServerState state) =>
                            (state is ServerStarted)
                                ? buildStack(spine, state)
                                : buildWaitingScreen(context)),
                  ),
                ),
              );
            }
          }),
    );
  }

  BookReaderDrawer _buildReaderDrawer() => (readerContext.hasNavigate)
      ? BookReaderDrawer(
          book: book,
          readerContext: readerContext,
        )
      : null;

  Widget buildStack(List<Link> spine, ServerStarted state) => SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: <Widget>[
              Visibility(
                visible: readerContext.hasToolbar,
                child: buildReaderSnapshottingView(spine, state),
              ),
              buildReaderView(spine, state),
              Visibility(
                visible: readerContext.hasToolbar,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ReaderToolbar(
                    readerContext: readerContext,
                    serverBloc: serverBloc,
                    onPrevious: onPrevious,
                    onNext: onNext,
                    maxHeight: constraints.maxHeight,
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ReaderAppBar(
                    readerContext: readerContext,
                    serverBloc: serverBloc,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildReaderView(List<Link> spine, ServerStarted serverState);

  Widget buildReaderSnapshottingView(
          List<Link> spine, ServerStarted serverState) =>
      const SizedBox.shrink();

  void onPrevious();

  void onNext();

  @override
  void dispose() {
    super.dispose();
    serverBloc.add(ShutdownServer());
    readerContext?.dispose();
    readerCommandSubscription?.cancel();
  }

  void onServerClosed() {
    saveBookPosition();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        onCloseDocument(context);
      }
    });
  }

  void onPageChanged(int position) =>
      currentSpineItemBloc.add(CurrentSpineItemEvent(position));

  Future<bool> _onWillPop() async {
    if (readerContext != null) {
      if (readerContext.themeEditing) {
        readerContext.closeThemeEdition();
        return false;
      }
      if (readerContext.toolbarVisibility) {
        readerContext.onTap();
        return false;
      }
    }
    serverBloc.add(ShutdownServer());
    return false;
  }

  int _initPageFromLocation() {
    int page = 0;
    if (readerContext.lastPosition.location != null) {
      ReadiumLocation readiumLocation =
          ReadiumLocation.createLocation(readerContext.lastPosition.location);
      page = readerContext.publication.readingOrder
          .indexWhere((link) => link.id == readiumLocation.idref);
      if (page < 0) {
        page = readerContext.publication.pageList
            .indexWhere((link) => link.id == readiumLocation.idref);
      }
    }
    return max(0, page);
  }

  void initPageController(int initialPage);

  void _displayErrorDialog(UserException userException) =>
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
          UserExceptionWidget.openDialog(context, userException,
              onClose: () => Navigator.pop(context)));
}
