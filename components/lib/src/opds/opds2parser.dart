// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:http/http.dart' as http;
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/try.dart';
import 'package:mno_shared/opds.dart';
import 'package:mno_shared/publication.dart';

class OPDS2ParserError {
  static const OPDS2ParserError metadataNotFound =
      OPDS2ParserError._("metadataNotFound");
  static const OPDS2ParserError invalidLink = OPDS2ParserError._("invalidLink");
  static const OPDS2ParserError missingTitle =
      OPDS2ParserError._("missingTitle");
  static const OPDS2ParserError invalidFacet =
      OPDS2ParserError._("invalidFacet");
  static const OPDS2ParserError invalidGroup =
      OPDS2ParserError._("invalidGroup");
  final String name;
  const OPDS2ParserError._(this.name);

  @override
  String toString() => 'OPDS2ParserError{name: $name}';
}

class OPDS2Parser {
  static Future<Try<ParseData, Exception>> parseURL(Uri url,
      {Map<String, String> headers}) async {
    try {
      return http.get(url, headers: headers).then((response) {
        int status = response.statusCode;
        if (status >= 400) {
          return Try.failure(Exception("Connection error"));
        } else {
          ParseData data = parse(response.body, url);
          return Try.success(data);
        }
      }).onError((error, stackTrace) => Try.failure(error));
    } on Exception catch (e, stacktrace) {
      Fimber.e("download ERROR", ex: e, stacktrace: stacktrace);
      return Try.failure(Exception("Connection error"));
    }
  }

  static ParseData parse(String jsonData, Uri url) {
    Map<String, dynamic> json = jsonData.toJsonOrNull();
    return (isFeed(json))
        ? ParseData(feed: parseFeed(json, url), type: 2)
        : ParseData(
            publication:
                Manifest.fromJson(json)?.let((it) => Publication(manifest: it)),
            type: 2);
  }

  static bool isFeed(Map<String, dynamic> json) =>
      json?.let((it) => (it.containsKey("navigation") ||
          it.containsKey("groups") ||
          it.containsKey("publications") ||
          it.containsKey("facets")));

  static Feed parseFeed(Map<String, dynamic> topLevelDict, Uri url) {
    Map<String, dynamic> metadataDict = topLevelDict["metadata"];
    if (metadataDict == null) {
      throw Exception(OPDS2ParserError.metadataNotFound.name);
    }
    String title = metadataDict["title"] as String;
    if (title == null) {
      throw Exception(OPDS2ParserError.missingTitle.name);
    }
    Feed feed = Feed(title, 2, url);
    parseFeedMetadata(opdsMetadata: feed.metadata, metadataDict: metadataDict);
    if (topLevelDict.containsKey("@context")) {
      if (topLevelDict["@context"] is Map<String, dynamic>) {
        feed.context
            .add(json.encode(topLevelDict["@context"] as Map<String, dynamic>));
      } else if (topLevelDict["@context"] is List<String>) {
        List<String> array = topLevelDict["@context"] as List<String>;
        for (int i = 0; i < array.length; i++) {
          feed.context.add(array[i]);
        }
      }
    }

    if (topLevelDict.containsKey("links")) {
      topLevelDict["links"].let((it) {
        var links = it as List;
        if (links == null) {
          throw Exception(OPDS2ParserError.invalidLink.name);
        }
        parseLinks(feed, links);
      });
    }

    if (topLevelDict.containsKey("facets")) {
      topLevelDict["facets"].let((it) {
        List facets = it as List;
        if (facets == null) {
          throw Exception(OPDS2ParserError.invalidLink.name);
        }
        parseFacets(feed, facets);
      });
    }

    if (topLevelDict.containsKey("publications")) {
      topLevelDict["publications"].let((it) {
        var publications = it as List;
        if (publications == null) {
          throw Exception(OPDS2ParserError.invalidLink.name);
        }
        parsePublications(feed, publications);
      });
    }

    if (topLevelDict.containsKey("navigation")) {
      topLevelDict["navigation"].let((it) {
        var navigation = it as List;
        if (navigation == null) {
          throw Exception(OPDS2ParserError.invalidLink.name);
        }
        parseNavigation(feed, navigation);
      });
    }

    if (topLevelDict.containsKey("groups")) {
      topLevelDict["groups"].let((it) {
        var groups = it as List;
        if (groups == null) {
          throw Exception(OPDS2ParserError.invalidLink.name);
        }
        parseGroups(feed, groups);
      });
    }
    return feed;
  }

  static void parseFeedMetadata(
      {OpdsMetadata opdsMetadata, Map<String, dynamic> metadataDict}) {
    if (metadataDict.containsKey("title")) {
      metadataDict["title"].let((it) => opdsMetadata.title = it.toString());
    }
    if (metadataDict.containsKey("numberOfItems")) {
      metadataDict["numberOfItems"]
          .let((it) => opdsMetadata.numberOfItems = it.toString().toInt());
    }
    if (metadataDict.containsKey("itemsPerPage")) {
      metadataDict["itemsPerPage"]
          .let((it) => opdsMetadata.itemsPerPage = it.toString().toInt());
    }
    if (metadataDict.containsKey("modified")) {
      metadataDict["modified"]
          .let((it) => opdsMetadata.modified = it.toString().iso8601ToDate());
    }
    if (metadataDict.containsKey("@type")) {
      metadataDict["@type"].let((it) => opdsMetadata.rdfType = it.toString());
    }
    if (metadataDict.containsKey("currentPage")) {
      metadataDict["currentPage"]
          .let((it) => opdsMetadata.currentPage = it.toString().toInt());
    }
  }

  static void parseFacets(Feed feed, List facets) {
    for (int i = 0; i < facets.length; i++) {
      Map<String, dynamic> facetDict = facets[i];
      Map<String, dynamic> metadata = facetDict["metadata"];
      if (metadata == null) {
        throw Exception(OPDS2ParserError.invalidFacet.name);
      }
      String title = metadata["title"] as String;
      if (title == null) {
        throw Exception(OPDS2ParserError.invalidFacet.name);
      }
      Facet facet = Facet(title: title);
      parseFeedMetadata(opdsMetadata: facet.metadata, metadataDict: metadata);
      if (facetDict.containsKey("links")) {
        List links = facetDict["links"] as List;
        if (links == null) {
          throw Exception(OPDS2ParserError.invalidFacet.name);
        }
        for (int k = 0; k < links.length; k++) {
          Map<String, dynamic> linkDict = links[k];
          Link.fromJSON(linkDict)?.let((it) {
            facet.links.add(it);
          });
        }
      }
      feed.facets.add(facet);
    }
  }

  static void parseLinks(Feed feed, List links) {
    for (int i = 0; i < links.length; i++) {
      Map<String, dynamic> linkDict = links[i];
      Link.fromJSON(linkDict)?.let((it) {
        feed.links.add(it);
      });
    }
  }

  static void parsePublications(Feed feed, List publications) {
    for (int i = 0; i < publications.length; i++) {
      Map<String, dynamic> pubDict = publications[i];
      Manifest.fromJson(pubDict)?.let((manifest) {
        feed.publications.add(Publication(manifest: manifest));
      });
    }
  }

  static void parseNavigation(Feed feed, List navLinks) {
    for (int i = 0; i < navLinks.length; i++) {
      Map<String, dynamic> navDict = navLinks[i];
      Link.fromJSON(navDict)?.let((link) {
        feed.navigation.add(link);
      });
    }
  }

  static void parseGroups(Feed feed, List groups) {
    for (int i = 0; i < groups.length; i++) {
      Map<String, dynamic> groupDict = groups[i];
      Map<String, dynamic> metadata = groupDict["metadata"];
      if (metadata == null) {
        throw Exception(OPDS2ParserError.invalidGroup.name);
      }
      String title = metadata["title"] as String;
      if (title == null) {
        throw Exception(OPDS2ParserError.invalidGroup.name);
      }
      Group group = Group(title: title);
      parseFeedMetadata(opdsMetadata: group.metadata, metadataDict: metadata);

      if (groupDict.containsKey("links")) {
        List links = groupDict["links"];
        if (links == null) {
          throw Exception(OPDS2ParserError.invalidGroup.name);
        }
        for (int j = 0; j < links.length; j++) {
          Map<String, dynamic> linkDict = links[j];
          Link.fromJSON(linkDict)?.let((link) {
            group.links.add(link);
          });
        }
      }
      if (groupDict.containsKey("navigation")) {
        List links = groupDict["navigation"];
        if (links == null) {
          throw Exception(OPDS2ParserError.invalidGroup.name);
        }
        for (int j = 0; j < links.length; j++) {
          Map<String, dynamic> linkDict = links[j];
          Link.fromJSON(linkDict)?.let((link) {
            group.navigation.add(link);
          });
        }
      }
      if (groupDict.containsKey("publications")) {
        List publications = groupDict["publications"];
        if (publications == null) {
          throw Exception(OPDS2ParserError.invalidGroup.name);
        }
        for (int j = 0; j < publications.length; j++) {
          Map<String, dynamic> pubDict = publications[j];
          Manifest.fromJson(pubDict)?.let((manifest) {
            group.publications.add(Publication(manifest: manifest));
          });
        }
      }

      feed.groups.add(group);
    }
  }
}
