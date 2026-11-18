import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Renders the Coinmoney geometric cube hexagon logo + wordmark matching Coinmoney.svg.
class CoinmoneyLogo extends StatelessWidget {
  const CoinmoneyLogo({
    super.key,
    this.iconSize = 26,
    this.fontSize = 22,
    this.showWordmark = true,
    this.color,
  });

  final double iconSize;
  final double fontSize;
  final bool showWordmark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final brandColor = color ?? AppColors.primaryBlue;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(iconSize, iconSize * 1.12),
          painter: _CoinmoneyMarkPainter(color: brandColor),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 8),
          Text(
            'coinmoney',
            style: TextStyle(
              color: brandColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}

class _CoinmoneyMarkPainter extends CustomPainter {
  _CoinmoneyMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * 0.48;
    final innerR = size.width * 0.27;

    final outerStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.105
      ..strokeJoin = StrokeJoin.round;

    final innerStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer hexagon
    final outerPath = _hexagonPath(cx, cy, outerR);
    canvas.drawPath(outerPath, outerStroke);

    // Inner open C-hexagon + vertical spine from Coinmoney.svg
    final pts = _hexagonPoints(cx, cy, innerR);
    final innerC = Path()
      ..moveTo(pts[1].dx, pts[1].dy) // top-right
      ..lineTo(pts[0].dx, pts[0].dy) // top
      ..lineTo(pts[5].dx, pts[5].dy) // top-left
      ..lineTo(pts[4].dx, pts[4].dy) // bottom-left
      ..lineTo(pts[3].dx, pts[3].dy) // bottom
      ..lineTo(pts[2].dx, pts[2].dy); // bottom-right
    canvas.drawPath(innerC, innerStroke);

    // Vertical isometric pillars at top and bottom vertices
    canvas.drawLine(
      Offset(cx, cy - outerR),
      Offset(cx, cy - innerR),
      innerStroke,
    );
    canvas.drawLine(
      Offset(cx, cy + innerR),
      Offset(cx, cy + outerR),
      innerStroke,
    );
  }

  List<Offset> _hexagonPoints(double cx, double cy, double r) {
    return List.generate(6, (i) {
      final angle = (-math.pi / 2) + i * (math.pi / 3);
      return Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
    });
  }

  Path _hexagonPath(double cx, double cy, double r) {
    final pts = _hexagonPoints(cx, cy, r);
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _CoinmoneyMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
