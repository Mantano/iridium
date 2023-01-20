import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartx/dartx_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:iridium_app/components/loading_widget.dart';
import 'package:iridium_app/database/download_helper.dart';
import 'package:iridium_app/models/locator_reader_annotation_repository.dart';
import 'package:iridium_app/util/router.dart';
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
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Row(
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: dl['image'],
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
    db.remove(dl['id']).then((v) async {
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
      allowedExtensions: ['epub', 'lcpl'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      print("Filename: ${file.name}");
      print("Bytes.length: ${file.bytes?.length}");
      print("Size: ${file.size}");
      print("Path: ${file.path}");

      copyFile(context, this, file);
    } else {
      Fimber.d("Import cancelled");
    }
  }

  Future copyFile(
      BuildContext context, State state, PlatformFile file) async {
    PermissionStatus permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) {
      await Permission.storage.request();
      // access media location needed for android 10/Q
      await Permission.accessMediaLocation.request();
      // manage external storage needed for android 11/R
      await Permission.manageExternalStorage.request();
      if (!state.mounted) {
        return;
      }
      doCopyFile(context, file);
    } else {
      if (!state.mounted) {
        return;
      }
      doCopyFile(context, file);
    }
  }

  Future doCopyFile(
      BuildContext context, PlatformFile file) async {
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      // Directory(appDocDir.path.split('Android')[0] + '${Constants.appName}')
      //     .createSync();
      Directory(appDocDir!.path).createSync();
    }

    // String path = Platform.isIOS
    //     ? appDocDir.path + '/$filename.epub'
    //     : appDocDir.path.split('Android')[0] +
    //         '${Constants.appName}/$filename.epub';
    String path = Platform.isIOS
        ? '${appDocDir!.path}/${file.name}'
        : '${appDocDir!.path}/${file.name}';
    Fimber.d("Orig path: ${file.path}");
    Fimber.d("Dest path: $path");
    File destFile = File(path);
    if (!await destFile.exists()) {
      await destFile.create();
    } else {
      await destFile.delete();
      await destFile.create();
    }

    // copy file to destFile
    await destFile.writeAsBytes(file.bytes!);

    addDownload(
      {
        'id': file.identifier,
        'path': path,
        'image': "https://bookstoreromanceday.org/wp-content/uploads/2020/08/book-cover-placeholder.png",
        'size': fileSizeAsString(file),
        'name': file.name,
      },
    );
  }

  String fileSizeAsString(PlatformFile file) {
    String size = (file.size / 1024).toStringAsFixed(2);
    if (file.size > 1024 * 1024) {
      size = '${(file.size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      size = '${size} KB';
    }
    return size;
  }

  Future addDownload(Map body) async {
    Fimber.d("Adding download: $body");
    await db.removeAllWithId({'id': body['id']});
    await db.add(body);
    // checkDownload();
  }

}
