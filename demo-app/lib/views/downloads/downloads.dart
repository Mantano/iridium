import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:iridium_app/components/loading_widget.dart';
import 'package:iridium_app/database/download_helper.dart';
import 'package:iridium_app/models/locator_reader_annotation_repository.dart';
import 'package:iridium_app/util/router.dart';
import 'package:iridium_app/views/downloads/book_cover_generator.dart';
import 'package:iridium_reader_widget/views/viewers/epub_screen.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class Downloads extends StatefulWidget {
  const Downloads({super.key});

  @override
  State<StatefulWidget> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  bool done = true;
  var db = DownloadsDB();
  static const uuid = Uuid();

  List dls = [];

  Future getDownloads() async {
    List l = await db.listAll();
    setState(() {
      dls.addAll(l);
    });
  }

  @override
  void initState() {
    super.initState();
    getDownloads();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Downloads'),
        ),
        body: dls.isEmpty ? _buildEmptyListView() : _buildBodyList(),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Import book',
          child: const Icon(Icons.add),
          onPressed: () {
            Fimber.d("Import book");
            _onImportBook();
          },
        ),
      );

  Widget _buildBodyList() => ListView.separated(
        shrinkWrap: true,
        itemCount: dls.length,
        itemBuilder: (BuildContext context, int index) {
          Map dl = dls[index];
          String imageUrl2 = dl['image'];
          Fimber.d("--- cover: ${imageUrl2}");
          return Dismissible(
            key: ObjectKey(uuid.v4()),
            direction: DismissDirection.endToStart,
            background: _dismissibleBackground(),
            onDismissed: (d) => _deleteBook(dl, index),
            child: InkWell(
              onTap: () async {
                String path = dl['path'];
                String id = dl['id'];
                MyRouter.pushPage(
                  context,
                  EpubScreen.fromPath(
                    filePath: path,
                    readerAnnotationRepository:
                        await LocatorReaderAnnotationRepository
                            .createLocatorReaderAnnotationRepository(id),
                    isTextInteractionEnabled: true,
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Row(
                  children: <Widget>[
                    imageUrl2.startsWith("http")
                        ? CachedNetworkImage(
                            imageUrl: imageUrl2,
                            placeholder: (context, url) => const SizedBox(
                              height: 70.0,
                              width: 70.0,
                              child: LoadingWidget(),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/place.png',
                              fit: BoxFit.cover,
                              height: 70.0,
                              width: 70.0,
                            ),
                            fit: BoxFit.cover,
                            height: 70.0,
                            width: 70.0,
                          )
                        : Image.file(
                            File(imageUrl2),
                            fit: BoxFit.cover,
                            height: 70.0,
                            width: 70.0,
                          ),
                    const SizedBox(width: 10.0),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            dl['name'],
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'COMPLETED',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                dl['size'],
                                style: const TextStyle(
                                  fontSize: 13.0,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      );

  Widget _buildEmptyListView() => Center(
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

  Widget _dismissibleBackground() => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(
          Feather.trash_2,
          color: Colors.white,
        ),
      );

  void _deleteBook(Map dl, int index) {
    // https://github.com/Mantano/iridium/issues/97 fixed by https://github.com/charlestyra89
    db.remove(dl).then((v) async {
      File f = File(dl['path']);
      if (await f.exists()) {
        f.delete();
      }
      setState(() {
        dls.removeAt(index);
      });
    });
  }

  Future<void> _onImportBook() async {
    // Show file explorer allowing only ".epub" and ".lcpl" files to be selected
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: [
        MediaType.epub.fileExtension!,
        MediaType.lcpLicenseDocument.fileExtension!,
        MediaType.lcpProtectedAudiobook.fileExtension!,
        MediaType.lcpProtectedPdf.fileExtension!,
      ],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      Fimber.d("Filename: ${file.name}");
      Fimber.d("Bytes.length: ${file.bytes?.length}");
      Fimber.d("Size: ${file.size}");
      Fimber.d("Path: ${file.path}");

      // Copy file to application storage directory

      checkPermissionsAndCopyFile(this, file);
    } else {
      Fimber.d("Import cancelled");
    }
  }

  Future checkPermissionsAndCopyFile(State state, PlatformFile file) async {
    PermissionStatus permission = Platform.isMacOS
        ? PermissionStatus.granted
        : await Permission.storage.status;

    // On MacOS, the permission is always granted
    if (permission != PermissionStatus.granted) {
      await Permission.storage.request();
      // access media location needed for android 10/Q
      await Permission.accessMediaLocation.request();
      // manage external storage needed for android 11/R
      await Permission.manageExternalStorage.request();
    }
    if (permission != PermissionStatus.granted || !state.mounted) {
      return;
    }
    import(file);
  }

  Future import(PlatformFile file) async {
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      Directory(appDocDir!.path).createSync();
    }

    String path = '${appDocDir!.path}/${file.name}';

    Fimber.d("Orig path: ${file.path}");
    Fimber.d("Dest path: $path");
    File destFile = File(path);
    if (await destFile.exists()) {
      await destFile.delete();
    }
    await destFile.create();
    await destFile.writeAsBytes(file.bytes!);

    if (destFile.path.endsWith("epub") || destFile.path.endsWith("webpub")) {
      await _importPublication(destFile, file);
    } else if (destFile.path.endsWith("lcpl")) {
      // await _importLcpPublication(destFile, file);
    }
  }

  String fileSizeAsString(PlatformFile file) {
    String size = (file.size / 1024).toStringAsFixed(2);
    if (file.size > 1024 * 1024) {
      size = '${(file.size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      size = '$size KB';
    }
    return size;
  }

  Future addDownload(Map body) async {
    Fimber.d("Adding download: $body");
    await db.removeAllWithId({'id': body['id']});
    await db.add(body);
    getDownloads();
    // checkDownload();
  }

  Future<void> saveBookInDatabase(
      Publication publication, PlatformFile file) async {
    BookCoverGenerator bookCoverGenerator = BookCoverGenerator(publication);
    File? coverFile = await bookCoverGenerator.generateAndSetFile(file.path!);
    Fimber.d("saveBookInDatabase, coverFile $coverFile");
    addDownload(
      {
        'id': publication.metadata.identifier,
        'path': file.path,
        'image': coverFile != null
            ? coverFile.path
            : "https://bookstoreromanceday.org/wp-content/uploads/2020/08/book-cover-placeholder.png",
        'size': fileSizeAsString(file),
        'name': file.name,
      },
    );
  }

  Streamer createStreamer({required bool showDialog}) {
    return Streamer(contentProtections: []);

    // return Streamer(
    //     contentProtections: await StreamerFactoryConfig.create(showDialog),
    // useSniffers: StreamerFactoryConfig.useSniffers,
    // pdfFactory: StreamerFactoryConfig.pdfFactory,
    // parsers: [
    // ...StreamerFactoryConfig._streamPublicationParser,
    // FileReaderParser()
    // ]);
  }

  _importPublication(File destFile, PlatformFile file) async {
    Streamer streamer = createStreamer(showDialog: false);
    FileAsset asset = FileAsset(destFile);
    (await streamer.open(asset, false)).onSuccess((publication) {
      Fimber.d("_publication $publication");
      saveBookInDatabase(publication, file);
    }).onFailure((openingException) {
      Fimber.e("Fail to open publication: $file", ex: openingException);
    });
  }

// _importLcpPublication(File destFile) {
//
//   LcpServiceFactory.create(LcpClientNative()).then((lcpService) {
//     if (lcpService != null) {
//       destFile
//           .readAsBytes()
//           .then((data) => lcpService
//           .acquirePublication(ByteData.sublistView(data))
//           .then((result) async {
//         if (result.isSuccess) {
//           return await result.map((publication) async {
//             String newPath = p.join(
//                 FolderSettings.instance.localPath!,
//                 p.basename(publication.suggestedFilename));
//             var _bookFile = await importerContext.moveFile(
//                 publication.localFile, newPath);
//             _bookMediaType = await MediaType.ofFile(_bookFile!);
//           }).success;
//         }
//         return null;
//       }))
//           .then((_) => lcpService
//           .retrieveLicense(file, null, false, null)
//           .then((lcpLicense) {
//         _license = lcpLicense?.getOrNull();
//         return null;
//       }))
//           .whenComplete(super.import)
//           .catchError((ex, stacktrace) {
//         Fimber.d("ERROR opening publication file",
//             ex: ex, stacktrace: stacktrace);
//       });
//     }
//   }).catchError((ex, stacktrace) {
//     Fimber.d("ERROR creating lcpService", ex: ex, stacktrace: stacktrace);
//   });
//
// }
}
