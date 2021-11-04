
(function() {

    $( document ).ready(function() {
        // Add a function in jQuery to compute how many columns are created for a specific element
        $.fn.howMuchCols = function(nbThumbnails){
            var nbThumbnails = (nbThumbnails) ? nbThumbnails : 1;
            var lastElem = $(this).find(':last')[0];
            var clientRects = lastElem.getClientRects();
            var isImg = lastElem.tagName == 'img';
            var windowWidth = $(window).width();
            var columnWidth = windowWidth / nbThumbnails;
            var result = Math.ceil((0.01 + $(this).find(':last').position().left) / columnWidth);
            for (index = 0; index < clientRects.length; index++) {
                var rect = clientRects[index];
                if (isImg && rect.height < 20)  {
                    break;
                }
                result = Math.max(result, Math.ceil((0.01 + rect.left) / columnWidth));
            }
            return result;
        };
        // Needed to hide the "loading" message at the end of every chapter
        $.mobile.loading().hide();
    });

    window.xpub = {
        initialized: false,
        htmlBodyIsVerticalWritingMode: false,
        package: null,
        screenshotConfig: null,
        lastViewPortSize: {
            width: undefined,
            height: undefined
        },
        paginationInfo: {
//            "visibleColumnCount" : 1,
//            "columnGap" : 0,
//            "spreadCount" : 0,
            "currentSpreadIndex" : 0,
//            "columnWidth" : 0,
//            "pageOffset" : 0,
//            "columnCount": 1
        },
        viewerSettings: {
            "syntheticSpread": "auto",
            "scroll": "auto",
            "enableGPUHardwareAccelerationCSS3D": false,
            "columnGap": 0
        },
        currentSpineItem: null,
        previousSpineItem: null,
        nextSpineItem: null,
        elementIds: [],
        elementIdsWithPageIndex: [],
        $epubHtml: $("html", document),
        $epubBody: null,
        highlight: null,
        bookmarks: null,
        theme: null,
        tts: null,
        /**
         * Gestures to used for a given action. May be overridden in platform
         * specific scripts.
         * For a list of multi-touch gestures: https://github.com/EightMedia/hammer.js
         */
        Gestures: {
            ZoomImage: "doubleTap"
        },

        initSpineItem: function (openBookData) {
//            console.log("initSpineItem, cfiNavigationLogic", window.cfiNavigationLogic);
//            console.log("openPage, openBookData.openPageRequest", openBookData.openPageRequest);
            xpub.$epubBody = $("body", document);
            if (!xpub.initialized) {
                xpub.highlight = new MNOHighlightController();
                xpub.bookmarks = new MNOBookmarksController();
                xpub.theme = new ThemeController();
                xpub.tts = new MNOTTSController();
                xpub.package = new Package(openBookData.package);
                xpub.currentSpineItem = new SpineItem(openBookData.spineItem, xpub.package);
                if (openBookData.previousSpineItem) {
                    xpub.previousSpineItem = new SpineItem(openBookData.previousSpineItem, xpub.package);
                }
                if (openBookData.nextSpineItem) {
                    xpub.nextSpineItem = new SpineItem(openBookData.nextSpineItem, xpub.package);
                }
                xpub.screenshotConfig = openBookData.screenshotConfig;
                xpub.viewerSettings = openBookData.settings;
                xpub.elementIds = openBookData.elementIds;
                window.currentPagesInfo = new CurrentPagesInfo(xpub.package, xpub.currentSpineItem, false, undefined);
                window.cfiNavigationLogic = new CfiNavigationLogic(xpub.$epubHtml,
                            {rectangleBased: xpub.currentSpineItem.isReflowable(), paginationInfo: openBookData.paginationInfo});
                xpub.events.initEvents();

                xpub.initialized = true;
            }
            xpub.updatePagination();
            if (openBookData.openPageRequest) {
                setTimeout(function() {
                    xpub.navigation.openPage(openBookData.openPageRequest);
                }, 0);
            }
        },

        getPropertyValue: function(propertyName) {
            return parseInt(getComputedStyle(document.documentElement).getPropertyValue(propertyName).trim());
        },

        setProperty: function(propertyName, propertyValue) {
            return document.documentElement.style.setProperty(propertyName, propertyValue);
        },

        postMessage: function(name, args, callback) {
            try {
                if (!args) {
                    args = {};
                }

                if (callback) {
                    args["callback"] = this.saveCallback(callback);
                }

                webkit.messageHandlers[name].postMessage(args);

            } catch (error) {
                console.error("Failed to post message <" + name + ">");
            }
        }
    };

})();
