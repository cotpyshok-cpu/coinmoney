import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Segment descriptor for [PortfolioDonutChart].
class PortfolioSlice {
  const PortfolioSlice({
    required this.symbol,
    required this.percent,
    required this.color,
  });

  final String symbol;
  final int percent;
  final Color color;
}

/// Glowing multi-segment donut ring matching Wallet Portfolio Figma screens.
class PortfolioDonutChart extends StatelessWidget {
  const PortfolioDonutChart({
    super.key,
    required this.balanceText,
    required this.changeText,
    required this.balanceVisible,
    required this.onToggleVisibility,
    this.slices = defaultSlices,
    this.size = 200,
  });

  final String balanceText;
  final String changeText;
  final bool balanceVisible;
  final VoidCallback onToggleVisibility;
  final List<PortfolioSlice> slices;
  final double size;

  static const List<PortfolioSlice> defaultSlices = [
    PortfolioSlice(symbol: 'ATOM', percent: 35, color: Color(0xFF1BC88A)),
    PortfolioSlice(symbol: 'ETH', percent: 10, color: Color(0xFF0088C6)),
    PortfolioSlice(symbol: 'CRO', percent: 7, color: Color(0xFF7D5AEF)),
    PortfolioSlice(symbol: 'ADA', percent: 2, color: Color(0xFFF44E95)),
    PortfolioSlice(symbol: 'BTC', percent: 46, color: Color(0xFFFFC155)),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(slices: slices),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'My Balance',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                balanceVisible ? balanceText : '••••••',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                changeText,
                style: const TextStyle(
                  color: AppColors.positiveTextGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices});

  final List<PortfolioSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<int>(0, (acc, s) => acc + s.percent);
    if (total <= 0) return;

    final strokeW = size.width * 0.115;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width / 2) - strokeW,
    );

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.percent / total) * math.pi * 2;

      // Soft outer glow matching Figma
      final glowPaint = Paint()
        ..color = slice.color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(rect, startAngle, sweep, false, glowPaint);

      final arcPaint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, arcPaint);

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.slices != slices;
}
