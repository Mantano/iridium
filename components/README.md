# mno_navigator_flutter

A Flutter "publication navigator" freely inspired by
the [Readium 2 Navigator](https://readium.org/technical/r2-navigator-architecture/).

## Current technical choices

### WebViews used to display Epub spine items

For now, we are using [webview_flutter](https://pub.dev/packages/webview_flutter) 3.x, which relies on Android WebView
and iOS WkWebView. In the current version, we use Hybrid Composition on iOS, which is the only option available. But **on
Android, while Hybrid Composition is now the default, we still use Virtual Display, because there are a few unresolved
issues when using Hybrid Composition**:

1. The webviews aren't prerendered when preloaded by the PreloadPageView. In the Chrome inspector, they appear as "
   empty - never attached". This causes many subsequent issues;
2. When displaying the book navigation page (including Table of Contents, Bookmarks etc.), which is pushed on top thanks
   to "pushPage", the webview briefly reappears and flashes on top, before leaving the navigation panel visible.

As a consequence, the display isn't completely smooth on Android when swiping between pages.

To switch to Hybrid Composition and get smooth sswiping, simply uncomment in `WebViewScreenState.initState` the
following line:

```
if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
```

At some point we'll try to replace [webview_flutter](https://pub.dev/packages/webview_flutter)
by [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview), that we already use for other purposes.

### Epub reflow pagination strategy

For the current implementation, we have chosen to follow a different route, compared to R2:

- 1 webview per spine item
- webviews embedded in a PreloadPageView
- we simply fix the height of the containing div, which causes the contents to overflow in columns, horizontally
- one a spine item is rendered, we overlay divs on top of each page
- CSS scroll-snap on each of these overlay divs provides straightforward page alignment after swiping
- intersection observers allow tracking the current page and allows routing swipe gestures either to the webview or
  to the PageView

There are pros and cons to this approach. But the main UX advantage is that swiping between spine items is smooth (
both spine items are visible at the same time, exactly like when swiping between pages inside a spine item).

At this point a few visual glitches still remain to be fixed.

## Note

While it is inspired by the platform-specific implementations provided by Readium 2, this Flutter implementation makes a
few different choices. One of the main differences is the pagination and page-turn implementation strategies. 