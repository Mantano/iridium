import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iridium_app/util/api.dart';
import 'package:iridium_app/util/enum/api_request_status.dart';
import 'package:iridium_app/util/functions.dart';
import 'package:mno_shared/opds.dart';

class HomeProvider with ChangeNotifier {
  ParseData? top;
  ParseData? recent;
  APIRequestStatus apiRequestStatus = APIRequestStatus.loading;
  Api api = Api();

  getFeeds() async {
    setApiRequestStatus(APIRequestStatus.loading);
    try {
      ParseData popular = await api.getCategory(Api.popular);
      setTop(popular);
      ParseData newReleases = await api.getCategory(Api.recent);
      setRecent(newReleases);
      setApiRequestStatus(APIRequestStatus.loaded);
    } catch (e) {
      checkError(e);
    }
  }

  void checkError(e) {
    if (Functions.checkConnectionError(e)) {
      setApiRequestStatus(APIRequestStatus.connectionError);
    } else {
      setApiRequestStatus(APIRequestStatus.error);
    }
  }

  void setApiRequestStatus(APIRequestStatus value) {
    apiRequestStatus = value;
    notifyListeners();
  }

  void setTop(value) {
    top = value;
    notifyListeners();
  }

  ParseData? getTop() {
    return top;
  }

  void setRecent(value) {
    recent = value;
    notifyListeners();
  }

  ParseData? getRecent() {
    return recent;
  }
}
