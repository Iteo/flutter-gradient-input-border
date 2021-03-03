import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// Based on [OutlineInputBorder]
class GradientOutlineInputBorder extends InputBorder {
  final Gradient focusedGradient;
  final Gradient unfocusedGradient;

  final double gapPadding;
  final BorderRadius borderRadius;

  const GradientOutlineInputBorder({
    BorderSide borderSide = const BorderSide(),
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.gapPadding = 4.0,
    required this.focusedGradient,
    required this.unfocusedGradient,
  })   : assert(gapPadding >= 0.0),
        super(borderSide: borderSide);

  static bool _cornersAreCircular(BorderRadius borderRadius) {
    return borderRadius.topLeft.x == borderRadius.topLeft.y &&
        borderRadius.bottomLeft.x == borderRadius.bottomLeft.y &&
        borderRadius.topRight.x == borderRadius.topRight.y &&
        borderRadius.bottomRight.x == borderRadius.bottomRight.y;
  }

  @override
  bool get isOutline => true;

  @override
  GradientOutlineInputBorder copyWith({
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    double? gapPadding,
  }) {
    return GradientOutlineInputBorder(
        borderSide: borderSide ?? this.borderSide,
        borderRadius: borderRadius ?? this.borderRadius,
        gapPadding: gapPadding ?? this.gapPadding,
        focusedGradient: this.focusedGradient,
        unfocusedGradient: this.unfocusedGradient);
  }

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(borderSide.width);
  }

  @override
  GradientOutlineInputBorder scale(double t) {
    return GradientOutlineInputBorder(
        borderSide: borderSide.scale(t),
        borderRadius: borderRadius * t,
        gapPadding: gapPadding * t,
        focusedGradient: this.focusedGradient,
        unfocusedGradient: this.unfocusedGradient);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is GradientOutlineInputBorder) {
      final GradientOutlineInputBorder outline = a;
      return GradientOutlineInputBorder(
          borderRadius:
              BorderRadius.lerp(outline.borderRadius, borderRadius, t)!,
          borderSide: BorderSide.lerp(outline.borderSide, borderSide, t),
          gapPadding: outline.gapPadding,
          focusedGradient: this.focusedGradient,
          unfocusedGradient: this.unfocusedGradient);
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is GradientOutlineInputBorder) {
      final GradientOutlineInputBorder outline = b;
      return GradientOutlineInputBorder(
          borderRadius:
              BorderRadius.lerp(borderRadius, outline.borderRadius, t)!,
          borderSide: BorderSide.lerp(borderSide, outline.borderSide, t),
          gapPadding: outline.gapPadding,
          focusedGradient: this.focusedGradient,
          unfocusedGradient: this.unfocusedGradient);
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(borderRadius
          .resolve(textDirection)
          .toRRect(rect)
          .deflate(borderSide.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  Path _gapBorderPath(
      Canvas canvas, RRect center, double start, double extent) {
    final Rect tlCorner = Rect.fromLTWH(
      center.left,
      center.top,
      center.tlRadiusX * 2.0,
      center.tlRadiusY * 2.0,
    );
    final Rect trCorner = Rect.fromLTWH(
      center.right - center.trRadiusX * 2.0,
      center.top,
      center.trRadiusX * 2.0,
      center.trRadiusY * 2.0,
    );
    final Rect brCorner = Rect.fromLTWH(
      center.right - center.brRadiusX * 2.0,
      center.bottom - center.brRadiusY * 2.0,
      center.brRadiusX * 2.0,
      center.brRadiusY * 2.0,
    );
    final Rect blCorner = Rect.fromLTWH(
      center.left,
      center.bottom - center.brRadiusY * 2.0,
      center.blRadiusX * 2.0,
      center.blRadiusY * 2.0,
    );

    const double cornerArcSweep = math.pi / 2.0;
    final double tlCornerArcSweep = start < center.tlRadiusX
        ? math.asin(start / center.tlRadiusX)
        : math.pi / 2.0;

    final Path path = Path()
      ..addArc(tlCorner, math.pi, tlCornerArcSweep)
      ..moveTo(center.left + center.tlRadiusX, center.top);

    if (start > center.tlRadiusX) path.lineTo(center.left + start, center.top);

    const double trCornerArcStart = (3 * math.pi) / 2.0;
    const double trCornerArcSweep = cornerArcSweep;
    if (start + extent < center.width - center.trRadiusX) {
      path
        ..relativeMoveTo(extent, 0.0)
        ..lineTo(center.right - center.trRadiusX, center.top)
        ..addArc(trCorner, trCornerArcStart, trCornerArcSweep);
    } else if (start + extent < center.width) {
      final double dx = center.width - (start + extent);
      final double sweep = math.acos(dx / center.trRadiusX);
      path.addArc(trCorner, trCornerArcStart + sweep, trCornerArcSweep - sweep);
    }

    return path
      ..moveTo(center.right, center.top + center.trRadiusY)
      ..lineTo(center.right, center.bottom - center.brRadiusY)
      ..addArc(brCorner, 0.0, cornerArcSweep)
      ..lineTo(center.left + center.blRadiusX, center.bottom)
      ..addArc(blCorner, math.pi / 2.0, cornerArcSweep)
      ..lineTo(center.left, center.top + center.trRadiusY);
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    assert(gapPercentage >= 0.0 && gapPercentage <= 1.0);
    assert(_cornersAreCircular(borderRadius));

    final RRect outer = borderRadius.toRRect(rect);
    final Paint paint = borderSide.toPaint();

    final bool isFocused = borderSide.width == 2.0;

    paint.shader = isFocused
        ? focusedGradient.createShader(outer.outerRect)
        : unfocusedGradient.createShader(outer.outerRect);
    final RRect center = outer.deflate(borderSide.width / 2.0);
    if (gapStart == null || gapExtent <= 0.0 || gapPercentage == 0.0) {
      canvas.drawRRect(center, paint);
    } else {
      final double? extent =
          lerpDouble(0.0, gapExtent + gapPadding * 2.0, gapPercentage);
      switch (textDirection) {
        case TextDirection.rtl:
          final Path path = _gapBorderPath(
              canvas, center, gapStart + gapPadding - extent!, extent);
          canvas.drawPath(path, paint);
          break;

        case TextDirection.ltr:
          final Path path =
              _gapBorderPath(canvas, center, gapStart - gapPadding, extent!);
          canvas.drawPath(path, paint);
          break;

        default:
          final Path path = _gapBorderPath(
              canvas, center, gapStart + gapPadding - extent!, extent);
          canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final GradientOutlineInputBorder typedOther = other;
    return typedOther.borderSide == borderSide &&
        typedOther.borderRadius == borderRadius &&
        typedOther.gapPadding == gapPadding;
  }

  @override
  int get hashCode => hashValues(borderSide, borderRadius, gapPadding);
}
