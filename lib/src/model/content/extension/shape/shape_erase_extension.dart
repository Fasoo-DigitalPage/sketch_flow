import 'dart:ui';

import 'package:sketch_flow/sketch_model.dart';

extension ShapeEraseExtension on SketchContent {
  /// Checks whether the eraser touches this sketch content based on rectangular boundary logic.
  ///
  /// This method assumes the sketch content represents a rectangle defined by at least two offsets:
  /// the first and the last points are used to determine the rectangle's corners.
  /// It then checks if the eraser's circular area (center and radius) intersects with any edge of the rectangle.
  ///
  /// Returns `true` if the eraser overlaps or touches any edge of the rectangle, otherwise `false`.
  ///
  /// Note:
  /// - The rectangle is defined by the first and last offsets, assuming these form diagonal corners.
  /// - The function calculates the shortest distance from the eraser center to each edge segment,
  ///   and if this distance is less than or equal to the eraser radius, the eraser is considered to be touching.
  /// - If the sketch content has fewer than 2 offsets, it cannot form a rectangle, so returns false immediately.
  ///
  /// This method is suitable for rectangular shapes and may not work correctly for arbitrary or complex paths.
  bool isErasedRectangleByEraser({
    required List<Offset> offsets,
    required Offset eraserCenter,
    required double eraserRadius
  }) {
    if (offsets.length < 2) return false;

    final start = offsets.first;
    final end = this.offsets.last;

    final topLeft = Offset(
      start.dx < end.dx ? start.dx : end.dx,
      start.dy < end.dy ? start.dy : end.dy,
    );
    final topRight = Offset(
      start.dx > end.dx ? start.dx : end.dx,
      start.dy < end.dy ? start.dy : end.dy,
    );
    final bottomRight = Offset(
      start.dx > end.dx ? start.dx : end.dx,
      start.dy > end.dy ? start.dy : end.dy,
    );
    final bottomLeft = Offset(
      start.dx < end.dx ? start.dx : end.dx,
      start.dy > end.dy ? start.dy : end.dy,
    );

    final edges = [
      [topLeft, topRight],
      [topRight, bottomRight],
      [bottomRight, bottomLeft],
      [bottomLeft, topLeft],
    ];

    for (final edge in edges) {
      final dist = _distanceToSegment(edge[0], edge[1], eraserCenter);
      if (dist <= eraserRadius) return true;
    }

    return false;
  }

  /// Checks whether the eraser circle touches the line defined by the first and last offsets.
  ///
  /// Returns true if the shortest distance between the eraser center and the line segment
  /// connecting the first and last offsets is less than or equal to the eraser radius.
  /// Returns false if fewer than 2 offsets exist (no line).
  bool isErasedLineByEraser({
    required List<Offset> offsets,
    required Offset eraserCenter,
    required double eraserRadius
  }) {
    if (offsets.length < 2) return false;

    final start = offsets.first;
    final end = offsets.last;

    final distance = _distanceToSegment(start, end, eraserCenter);
    return distance <= eraserRadius;
  }

  /// Checks whether the eraser circle touches the circular SketchContent (like a circle shape).
  ///
  /// It assumes that the shape is a circle defined by two offsets: the start and end points
  /// used to calculate the center and radius of the drawn circle.
  ///
  /// Returns true if the distance between the centers is less than or equal to the sum of
  /// the two radii (drawn circle and eraser).
  bool isErasedCircleByEraser({
    required List<Offset> offsets,
    required Offset eraserCenter,
    required double eraserRadius,
  }) {
    if (offsets.length < 2) return false;

    final start = offsets.first;
    final end = offsets.last;

    final circleCenter = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );

    final radius = ((end.dx - start.dx).abs() / 2)
        .clamp(0, double.infinity)
        .toDouble();

    final distance = (circleCenter - eraserCenter).distance;

    return distance <= radius + eraserRadius;
  }

  /// Calculates the shortest distance from point `p` to the line segment defined by points `a` and `b`.
  ///
  /// This helper function projects point `p` onto the segment `ab` and returns the distance
  /// to the closest point on the segment.
  double _distanceToSegment(Offset a, Offset b, Offset p) {
    final ab = b - a;
    final ap = p - a;
    final abLengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;

    double t = (ap.dx * ab.dx + ap.dy * ab.dy) / abLengthSquared;
    t = t.clamp(0.0, 1.0);

    final closest = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return (p - closest).distance;
  }
}
