// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared_dart/mediatype.dart';

import '../../../lcp.dart';

class Links {
  final List<Link> links;

  Links._(this.links);

  static Links parse(List json) =>
      Links._(json.map((l) => Link.parse(l)).toList());

  Link firstWithRel(String rel, {MediaType type}) =>
      links.firstWhere((it) => it.matches(rel, type), orElse: () => null);

  Link firstWithRelAndNoType(String rel) =>
      links.firstWhere((it) => it.rel.contains(rel) && it.type == null,
          orElse: () => null);

  List<Link> allWithRel(String rel, {MediaType type}) =>
      links.where((element) => element.matches(rel, type)).toList();

  List<Link> get(String rel) => allWithRel(rel);

  @override
  String toString() => '$links';
}

extension _LinkExt on Link {
  bool matches(String rel, MediaType type) =>
      this.rel.contains(rel) &&
      (type == null || type.matchesFromName(this.type));
}
