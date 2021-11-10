// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:convert';

class Coord {
  int _x;
  int _y;

  int get x => _x;

  int get y => _y;

  Coord.fromJson(String coord) {
    Map<String, dynamic> json = const JsonCodec().decode(coord);
    _x = json["x"];
    _y = json["y"];
  }

  @override
  String toString() => 'Coord{_x: $_x, _y: $_y}';
}
