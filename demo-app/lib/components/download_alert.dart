import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:iridium_app/components/custom_alert.dart';
import 'package:iridium_app/util/consts.dart';

class DownloadAlert extends StatefulWidget {
  final String url;
  final String path;

  const DownloadAlert({Key? key, required this.url, required this.path})
      : super(key: key);

  @override
  _DownloadAlertState createState() => _DownloadAlertState();
}

class _DownloadAlertState extends State<DownloadAlert> {
  Dio dio = Dio();
  int received = 0;
  String progress = '0';
  int total = 0;

  download() async {
    Fimber.d("Downloading: ${widget.url}");
    await dio.download(
      widget.url,
      widget.path,
      deleteOnError: true,
      onReceiveProgress: (receivedBytes, totalBytes) {
        setState(() {
          received = receivedBytes;
          total = totalBytes;
          progress = (received / total * 100).toStringAsFixed(0);
        });

        //Check if download is complete and close the alert dialog
        if (receivedBytes == totalBytes) {
          Navigator.pop(context, '${Constants.formatBytes(total, 1)}');
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    download();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: CustomAlert(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Downloading...',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20.0),
              Container(
                height: 5,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: LinearProgressIndicator(
                  value: double.parse(progress) / 100.0,
                  valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.secondary),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 5.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '$progress %',
                    style: const TextStyle(
                      fontSize: 13.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${Constants.formatBytes(received, 1)} '
                    'of ${Constants.formatBytes(total, 1)}',
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
      ),
    );
  }
}
