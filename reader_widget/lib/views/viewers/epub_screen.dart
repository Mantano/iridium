import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'package:universal_io/io.dart';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'book_screen.dart';
import 'package:iridium_reader_widget/views/viewers/model/fonts.dart';
import 'package:mno_commons/utils/functions.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';

class EpubScreen extends BookScreen {
  final String? location;
  final int? settings;
  final Map<String,dynamic>? theme;

  const EpubScreen({Key? key, required FileAsset asset, this.location, this.settings, this.theme})
      : super(key: key, asset: asset);

  factory EpubScreen.fromPath({Key? key, required String filePath, String? location}) {
    return EpubScreen(key: key, asset: FileAsset(File(filePath)), location: location);
  factory EpubScreen.fromPath({Key? key, required String filePath, String? location, String? settings, String? theme}) {
    Map<String,dynamic>? decodedTheme;
    try {
      decodedTheme = json.decode(theme!);
    }
    catch (e){
      debugPrint('failure to decode theme: $e');
    }
    return EpubScreen(key: key, asset: FileAsset(File(filePath)), location: location, settings: int.tryParse(settings ?? '100'), theme: decodedTheme,);
  }
  factory EpubScreen.fromFile({Key? key, required File file, String? location}) {
    return EpubScreen(key: key, asset: FileAsset(file), location: location);
  }
  @override
  State<StatefulWidget> createState() => EpubScreenState();
}

class EpubScreenState extends BookScreenState<EpubScreen, EpubController> {
  late ViewerSettingsBloc _viewerSettingsBloc;
  late ReaderThemeBloc _readerThemeBloc;

  @override
  void initState() {
    super.initState();
    _viewerSettingsBloc = ViewerSettingsBloc(EpubReaderState("", widget.settings ?? 100));
    debugPrint(widget.theme.toString());
    _readerThemeBloc = ReaderThemeBloc(widget.theme!=null ? ReaderThemeConfig.fromJson(widget.theme!) : ReaderThemeConfig.defaultTheme);
  }

  @override
  Future<bool> onWillPop() async {
    try {
      Navigator.pop(context, {
        'location': readerContext.paginationInfo!.location.json,
        'settings': _viewerSettingsBloc.viewerSettings.fontSize.toString(),
        'theme': json.encode(_readerThemeBloc.currentTheme.toJson()),
      });
    } catch (e) {
      // perhaps a snackbar notification can be added to indicate that there was a problem saving last location and settings
      debugPrint('error returning location and settings');
    }
    return true;

  }


  @override
  Future<String?> get openLocation async => widget.location;

  @override
  Future<String?> get openLocation async => widget.location;

  @override
  EpubController createPublicationController(
      Function onServerClosed,
      Function? onPageJump,
      Future<String?> locationFuture,
      FileAsset fileAsset,
      Future<Streamer> streamerFuture,
      ReaderAnnotationRepository readerAnnotationRepository,
      Function0<List<RequestHandler>> handlersProvider) =>
      EpubController(onServerClosed, onPageJump, locationFuture, fileAsset,
          streamerFuture, readerAnnotationRepository, handlersProvider);

  @override
  Widget createPublicationNavigator({
    required WidgetBuilder waitingScreenBuilder,
    required WidgetErrorBuilder displayErrorBuilder,
    required Consumer<ReaderContext> onReaderContextCreated,
    required WrapperWidgetBuilder wrapper,
    required EpubController publicationController,
  }) =>
      EpubNavigator(
          waitingScreenBuilder: waitingScreenBuilder,
          displayErrorBuilder: displayErrorBuilder,
          onReaderContextCreated: onReaderContextCreated,
          wrapper: wrapper,
          epubController: publicationController);

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => _viewerSettingsBloc),
      BlocProvider(create: (context) => _readerThemeBloc),
    ],
    child: super.build(context),
  );

  @override
  Widget buildBackground() => BlocBuilder(
    bloc: _readerThemeBloc,
    builder: (BuildContext context, ReaderThemeState state) => Container(
      color: state.readerTheme.backgroundColor,
    ),
  );

  @override
  Function0<List<RequestHandler>> get handlersProvider => () => [
    AssetsRequestHandler(
      'packages/mno_navigator/assets',
      assetProvider: _AssetProvider(),
      transformData: _transformAssetData,
    ),
    FetcherRequestHandler(readerContext.publication!,
        googleFonts: Fonts.googleFonts)
  ];
  Uint8List _transformAssetData(String href, Uint8List data) {
    if (href == 'xpub-js/ReadiumCSS-after.css') {
      ReadiumThemeValues values = ReadiumThemeValues(
          _readerThemeBloc.currentTheme, _viewerSettingsBloc.viewerSettings);
      String string = values.replaceValues(String.fromCharCodes(data));
      return Uint8List.fromList(string.codeUnits);
    }
    return data;
  }
}

class _AssetProvider implements AssetProvider {
  @override
  Future<ByteData> load(String path) => rootBundle.load(path);
}
