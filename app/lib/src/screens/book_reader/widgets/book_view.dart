import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as IWV;
import 'package:mno_shared/publication.dart';

IWV.InAppWebViewGroupOptions webOptions = IWV.InAppWebViewGroupOptions(
    crossPlatform: IWV.InAppWebViewOptions(
        preferredContentMode: IWV.UserPreferredContentMode.MOBILE,
        useShouldOverrideUrlLoading: false,
        mediaPlaybackRequiresUserGesture: false,
        verticalScrollBarEnabled: false,
        horizontalScrollBarEnabled: false),
    android: IWV.AndroidInAppWebViewOptions(
      useHybridComposition: true,
      useWideViewPort: true,
      overScrollMode: IWV.AndroidOverScrollMode.OVER_SCROLL_ALWAYS,
    ),
    ios: IWV.IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ));

class BookView extends StatefulWidget {
  final List<Link> spines;
  final String host;
  final PageController pageController;

  const BookView(this.host, this.spines, this.pageController, {Key? key})
      : super(key: key);
  @override
  _BookViewState createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: widget.pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.spines.length,
        itemBuilder: (context, index) {
          return createInAppWebView(
              '${widget.host}${widget.spines[index].href}',
              widget.pageController,
              widget.spines.length);
        },
      ),
    );
  }

  Widget createInAppWebView(
      String url, PageController pageController, int totalPages) {
    return IWV.InAppWebView(
      key: ValueKey(url),
      initialUrlRequest: IWV.URLRequest(url: Uri.parse(url)),
      initialOptions: webOptions,
      onLoadStart: (controller, url) {},
      androidOnPermissionRequest: (controller, origin, resources) async {
        return IWV.PermissionRequestResponse(
            resources: resources,
            action: IWV.PermissionRequestResponseAction.GRANT);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url!;

        if (!["http", "https", "file", "chrome", "data", "javascript", "about"]
            .contains(uri.scheme)) {}

        return IWV.NavigationActionPolicy.ALLOW;
      },
      onLoadStop: (controller, url) async {},
      onLoadError: (controller, url, code, message) {},
      onProgressChanged: (controller, progress) {},
      onUpdateVisitedHistory: (controller, url, androidIsReload) {},
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint(consoleMessage.message);
      },
    );
  }
}
