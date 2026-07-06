import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The CareHub mark: a rounded medical cross with a gradient fill, surrounded by
/// a burst of tapered rays in cyan-to-blue tones. Drawn with a [CustomPainter]
/// so it stays crisp at any size and adds no image assets to the bundle.
class BurstLogo extends StatelessWidget {
  const BurstLogo({super.key, this.size = 150, this.showRays = true});

  final double size;

  /// When false only the cross is drawn — handy for tight headers.
  final bool showRays;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BurstPainter(showRays: showRays)),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.showRays});

  final bool showRays;

  static const _cyan = Color(0xFF3DE7FF);
  static const _lightBlue = Color(0xFF5AA9FF);
  static const _midBlue = Color(0xFF2E6BFF);
  static const _deepBlue = Color(0xFF1B37C8);

  // angle (deg), inner radius factor, outer radius factor, stroke factor
  static const List<List<double>> _rayGeometry = [
    [-90, 0.62, 0.94, 0.055],
    [-60, 0.60, 1.00, 0.050],
    [-30, 0.58, 0.84, 0.050],
    [-115, 0.60, 0.88, 0.050],
    [-150, 0.58, 1.00, 0.058],
    [180, 0.58, 0.90, 0.050],
    [150, 0.56, 0.80, 0.044],
    [120, 0.58, 0.86, 0.050],
    [90, 0.60, 0.82, 0.044],
    [60, 0.58, 0.78, 0.044],
    [30, 0.58, 0.92, 0.050],
    [0, 0.60, 0.96, 0.050],
    [-45, 0.62, 0.72, 0.040],
    [-135, 0.62, 0.74, 0.040],
  ];

  static const List<Color> _rayColors = [
    _cyan, _lightBlue, _midBlue, _lightBlue, _cyan, _midBlue, _deepBlue,
    _midBlue, _deepBlue, _deepBlue, _lightBlue, _cyan, _midBlue, _midBlue,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (showRays) {
      for (var i = 0; i < _rayGeometry.length; i++) {
        final g = _rayGeometry[i];
        final a = g[0] * math.pi / 180;
        final dir = Offset(math.cos(a), math.sin(a));
        final p1 = center + dir * radius * g[1];
        final p2 = center + dir * radius * g[2];
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = _rayColors[i]
            ..strokeWidth = size.width * g[3]
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // Rounded medical cross with a top-to-bottom cyan gradient.
    final barLength = radius * 0.98;
    final barThickness = radius * 0.30;
    final cornerRadius = Radius.circular(barThickness * 0.4);
    final crossBounds =
        Rect.fromCenter(center: center, width: barLength, height: barLength);

    final crossPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF7DF2FF), Color(0xFF2E9BFF)],
      ).createShader(crossBounds);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: barThickness, height: barLength),
        cornerRadius,
      ),
      crossPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: barLength, height: barThickness),
        cornerRadius,
      ),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) =>
      oldDelegate.showRays != showRays;
}