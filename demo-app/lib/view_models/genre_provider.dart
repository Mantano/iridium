import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:iridium_app/util/api.dart';
import 'package:iridium_app/util/enum/api_request_status.dart';
import 'package:iridium_app/util/functions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mno_shared/opds.dart';
import 'package:mno_shared/publication.dart';

class GenreProvider extends ChangeNotifier {
  ScrollController controller = ScrollController();
  List<Publication> items = [];
  int page = 1;
  bool loadingMore = false;
  bool loadMore = true;
  APIRequestStatus apiRequestStatus = APIRequestStatus.loading;
  Api api = Api();

  listener(url) {
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (!loadingMore) {
          paginate(url);
          // Animate to bottom of list
          Timer(const Duration(milliseconds: 100), () {
            controller.animateTo(
              controller.position.maxScrollExtent,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeIn,
            );
          });
        }
      }
    });
  }

  getFeed(String url) async {
    setApiRequestStatus(APIRequestStatus.loading);
    Fimber.d("getFeed: $url");
    try {
      ParseData parseData = await api.getCategory(url);
      var pubs = parseData.feed?.publications;
      if (pubs != null) {
        items = pubs;
      }
      setApiRequestStatus(APIRequestStatus.loaded);
      listener(url);
    } catch (e) {
      checkError(e);
      rethrow;
    }
  }

  paginate(String url) async {
    if (apiRequestStatus != APIRequestStatus.loading &&
        !loadingMore &&
        loadMore) {
      Timer(const Duration(milliseconds: 100), () {
        controller.jumpTo(controller.position.maxScrollExtent);
      });
      loadingMore = true;
      page = page + 1;
      notifyListeners();
      try {
        ParseData parseData = await api.getCategory(url + '&page=$page');
        var pubs = parseData.feed?.publications;
        if (pubs != null) {
          items.addAll(pubs);
        }
        loadingMore = false;
        notifyListeners();
      } catch (e) {
        loadMore = false;
        loadingMore = false;
        notifyListeners();
        rethrow;
      }
    }
  }

  void checkError(e) {
    if (Functions.checkConnectionError(e)) {
      setApiRequestStatus(APIRequestStatus.connectionError);
      showToast('Connection error');
    } else {
      setApiRequestStatus(APIRequestStatus.error);
      showToast('Something went wrong, please try again');
    }
  }

  showToast(msg) {
    Fluttertoast.showToast(
      msg: '$msg',
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
    );
  }

  void setApiRequestStatus(APIRequestStatus value) {
    apiRequestStatus = value;
    notifyListeners();
  }
}
