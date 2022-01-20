import 'package:dio/dio.dart';
import 'package:mno_opds/mno_opds.dart';
import 'package:mno_shared/opds.dart';

class Api {
  Dio dio = Dio();
  static String baseURL = 'https://catalog.feedbooks.com';
  static String publicDomainURL = '$baseURL/publicdomain/browse';
  static String popular = '$publicDomainURL/top.atom';
  static String recent = '$publicDomainURL/recent.atom';
  static String awards = '$publicDomainURL/awards.atom';
  static String noteworthy = '$publicDomainURL/homepage_selection.atom';
  static String shortStory = '$publicDomainURL/top.atom?cat=FBFIC029000';
  static String sciFi = '$publicDomainURL/top.atom?cat=FBFIC028000';
  static String actionAdventure = '$publicDomainURL/top.atom?cat=FBFIC002000';
  static String mystery = '$publicDomainURL/top.atom?cat=FBFIC022000';
  static String romance = '$publicDomainURL/top.atom?cat=FBFIC027000';
  static String horror = '$publicDomainURL/top.atom?cat=FBFIC015000';

  Future<ParseData> getCategory(String url) async {
    var res = await dio.get(url).catchError((e) {
      throw (e);
    });
    ParseData category;
    if (res.statusCode == 200) {
      ParseData parseData = Opds1Parser.parse(res.data, Uri.parse(url));
      category = parseData;
    } else {
      throw ('Error ${res.statusCode}');
    }
    return category;
  }
}
