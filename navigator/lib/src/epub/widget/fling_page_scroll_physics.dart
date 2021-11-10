// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
import 'package:flutter/material.dart';

class FlingPageScrollPhysics extends ScrollPhysics {
  const FlingPageScrollPhysics(this.controller, {ScrollPhysics parent})
      : super(parent: parent);

  final PageController controller;

  @override
  FlingPageScrollPhysics applyTo(ScrollPhysics ancestor) =>
      FlingPageScrollPhysics(controller, parent: buildParent(ancestor));

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    final sim =
        ClampingScrollSimulation(position: position.pixels, velocity: velocity);
    final width = position.viewportDimension * controller.viewportFraction;
    double page = sim.x(1.0) / width;
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return page.floorToDouble() * width;
  }

  @override
  bool get allowImplicitScrolling => false;
}
