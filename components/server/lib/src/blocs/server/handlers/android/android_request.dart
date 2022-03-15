import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_server/src/blocs/server/handlers/android/android_response.dart';

class AndroidRequest extends Request<AndroidResponse> {
  WebResourceRequest request;
  AndroidResponse? _response;

  AndroidRequest(this.request);

  @override
  Uri get uri => Uri(
        path: request.url.path,
        query: request.url.query,
        fragment: request.url.fragment.isNotEmpty ? request.url.fragment : null,
      );

  @override
  AndroidResponse get response => _response ??= AndroidResponse();

  @override
  String? getHeader(String name) => request.headers![name];
}
