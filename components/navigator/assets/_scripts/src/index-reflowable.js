//
//  Copyright 2021 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

// Script used for reflowable resources.

import "./index";
import flutter from "./flutter";
import "tocca";

document.scrollingElement.addEventListener("swipeup", function (event) {
  event.stopPropagation();
  flutter.onSwipeUp();
});

document.scrollingElement.addEventListener("swipedown", function (event) {
  event.stopPropagation();
  flutter.onSwipeDown();
});

/**
 * Remove all child nodes from an element
 * @param {Object} element The element to empty
 */
function empty(element) {
  // Get the element's children as an array
  var children = Array.prototype.slice.call(element.childNodes);

  // Remove each child node
  children.forEach(function (child) {
    element.removeChild(child);
  });
}

function getDirection() {
  return window.getComputedStyle(document.body).getPropertyValue("direction");
}

var observers = [];

readium.initPagination = function () {
  document.fonts.ready.then(async function () {
    if (observers !== undefined) {
      for (let i = 0; i < observers.length; i++) {
        observers[i].disconnect();
      }
    }
    observers = [];

    let paginator = document.getElementById("readium_paginator");
    empty(paginator);
    const isRtl = getDirection() === "rtl";

    var documentWidth = document.scrollingElement.scrollWidth;
    var width = await flutter.getViewportWidth();
    var pageWidth = width / window.devicePixelRatio;
    let nbCols = Math.round(documentWidth / pageWidth);
    console.log(
      "documentWidth: " +
        documentWidth +
        ", width: " +
        width +
        ", pageWidth: " +
        pageWidth +
        ", nbCols: " +
        nbCols
    );
    // console.log("=========== " + window.location.href + ", nbCols: " + nbCols);

    // xpub.paginationInfo.columnCount = nbCols;
    paginator.style.width = documentWidth;
    paginator.style.maxWidth = documentWidth;

    //    if (xpub.screenshotConfig) {
    //      let spineItemPageThumbnailsCount = $(
    //        "#xpub_contenuSpineItem"
    //      ).howMuchCols(xpub.screenshotConfig.nbThumbnails);
    //      xpub.paginationInfo.nbThumbnailsCount = spineItemPageThumbnailsCount;
    //    }

    for (let i = 0; i < nbCols; i++) {
      let divText =
        '<div id="readium_page_' +
        i +
        '" data-page="' +
        i +
        '" class="readium_page_overlay">' +
        '   <div class="readium_page_bookmark" data-page="' +
        i +
        '" data-prevent-tap="true">' +
        '      <img src="/readium/assets/bookmark.svg" />' +
        "   </div>" +
        "</div>";
      paginator.appendChild(
        new DOMParser().parseFromString(divText, "text/html").body
          .firstElementChild
      );
    }
    //    paginator.show();

    let lowestPageNumberDivSelector = "#readium_page_0";
    let highestPageNumberDivSelector = "#readium_page_" + (nbCols - 1);
    let leftDivSelector = isRtl
      ? highestPageNumberDivSelector
      : lowestPageNumberDivSelector;
    let rightDivSelector = isRtl
      ? lowestPageNumberDivSelector
      : highestPageNumberDivSelector;

    for (let i = 0; i < nbCols; i++) {
      let observer = new IntersectionObserver(
        function (entries) {
          if (entries[0].isIntersecting) {
            // TODO implement triggerOnPaginationChanged
            // let index = entries[0].target.getAttribute("page");
            // xpub.paginationInfo.currentSpreadIndex = index;
            // xpub.triggerOnPaginationChanged();
          }
        },
        { threshold: [0.99] }
      );
      let querySelector = document.querySelector("#readium_page_" + i);
      if (querySelector != null) {
        observer.observe(querySelector);
        observers.push(observer);
      }
    }

    let queryBookmarks = document.querySelector(".readium_page_bookmark");
    for (let i = 0; i < queryBookmarks.length; i++) {
      queryBookmarks[i].addEventListener(
        "click",
        function (event) {
          flutter.log(event);
          // TODO implement toggleBookmark
          // xpub.navigation.toggleBookmark();
        },
        false
      );
    }

    let observerLeft = new IntersectionObserver(
      function (entries) {
        // isIntersecting is true when element and viewport are overlapping
        // isIntersecting is false when element and viewport don't overlap
        // console.log("=========== observerLeft, entry dimensions: " + entries[0].boundingClientRect.width + "x" + + entries[0].boundingClientRect.height + ", intersectionRatio: " + entries[0].intersectionRatio + ", isIntersecting? " + entries[0].isIntersecting);
        flutter.onLeftOverlayVisibilityChanged(
          entries[0].intersectionRatio >= 0.99
        );
      },
      { threshold: [0.0, 0.1, 0.2, 0.9, 0.95, 0.99, 1.0] }
    );
    let observerRight = new IntersectionObserver(
      function (entries) {
        // isIntersecting is true when element and viewport are overlapping
        // isIntersecting is false when element and viewport don't overlap
        //                console.log("=========== observerRight, entry dimensions: " + entries[0].boundingClientRect.width + "x" + + entries[0].boundingClientRect.height + ", intersectionRatio: " + entries[0].intersectionRatio + ", isIntersecting? " + entries[0].isIntersecting);
        flutter.onRightOverlayVisibilityChanged(
          entries[0].intersectionRatio >= 0.99
        );
      },
      { threshold: [0.0, 0.1, 0.2, 0.9, 0.95, 0.99, 1.0] }
    );
    observers.push(observerLeft);
    observers.push(observerRight);
    let firstDivQuerySelector = document.querySelector(leftDivSelector);
    //             console.log("=========== firstDivQuerySelector: " + firstDivQuerySelector);
    if (firstDivQuerySelector != null) {
      observerLeft.observe(firstDivQuerySelector);
    }
    let lastDivQuerySelector = document.querySelector(rightDivSelector);
    //             console.log("=========== lastDivQuerySelector: " + lastDivQuerySelector);
    if (lastDivQuerySelector != null) {
      observerRight.observe(lastDivQuerySelector);
    }
    //    xpub.bookmarks.generatePageNumberForCfi();
    //    xpub.elementIdsWithPageIndex = new Map();
    //    for (let i in xpub.elementIds) {
    //      let elementId = xpub.elementIds[i];
    //      let pageIndex = cfiNavigationLogic.getPageForElementId(elementId);
    //      xpub.elementIdsWithPageIndex.set(elementId, pageIndex);
    //    }

    //    if (xpub.screenshotConfig) {
    //      document.fonts.ready.then(function () {
    //        let nbThumbnails = xpub.screenshotConfig.nbThumbnails;
    //        let xpubContainer = $(".xpub_container");
    //        let containerHeight = xpubContainer[0].clientHeight;
    //        let containerWidth = xpubContainer[0].clientWidth;
    //        let translateLeft = -(
    //          (containerWidth / nbThumbnails) *
    //          ((nbThumbnails - 1) / 2)
    //        );
    //        let translateTop = -(
    //          (containerHeight / nbThumbnails) *
    //          ((nbThumbnails - 1) / 2)
    //        );
    //        let scale = 1 / nbThumbnails;
    //        $("#xpub_spineItemContents")[0].style.transform =
    //          "translate(" +
    //          translateLeft +
    //          "px, " +
    //          translateTop +
    //          "px) scale(" +
    //          scale +
    //          ")";
    //        if (paginator.length === 0) {
    //          document.fonts.ready.then(function () {
    //            xpub.triggerOnPaginationChanged();
    //          });
    //        }
    //      });
    //    }
    //     $('#xpub_spineItemContents')[0].style.transform = "scale(" + 0.1 + ")";
  });
};

document.addEventListener("DOMContentLoaded", function () {
  // Setups the `viewport` meta tag to disable zooming.
  let meta = document.createElement("meta");
  meta.setAttribute("name", "viewport");
  meta.setAttribute(
    "content",
    "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, shrink-to-fit=no"
  );
  document.head.appendChild(meta);
});
