# mno_navigator_flutter

A Flutter "publication navigator" freely inspired by
the [Readium 2 Naavigator](https://readium.org/technical/r2-navigator-architecture/).

## Current technical choices related to the WebViews used to display Epub spine items

For now, we are using [webview_flutter](https://pub.dev/packages/webview_flutter) 3.x, which relies on Android WebView and iOS WkWebView. In the current version, we
use Hybrid Composition on iOS, which is the only option available. But on Android, while Hybrid Composition is now the default, we still use Virtual Display, because
there are a few unresolved issues when using Hybrid Composition:

1. The webviews aren't prerendered when preloaded by the PreloadPageView. In the Chrome inspector, they appear as "
   empty - never attached". This causes many subsequent issues;
2. When displaying the book navigation page (including Table of Contents, Bookmarks etc.), which is pushed on top thanks to "pushPage", the webview briefly reappears and
   flashes on top, before leaving the navigation panel visible.

As a consequence, the display isn't completely smooth on Android when swiping between pages. 

To switch to Hybrid Composition and get smooth sswiping, simply uncomment in `WebViewScreenState.initState` the following line:
```
if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
```
At some point we'll try to replace [webview_flutter](https://pub.dev/packages/webview_flutter) by [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview), that we already use for other purposes.

## Note

While it is inspired by the platform-specific implementations provided by Readium 2, this Flutter implementation makes a
few different choices. One of the main differences is the pagination and page-turn implementation strategies. 