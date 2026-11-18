import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/coin_model.dart';
import '../../theme/app_theme.dart';

/// OHLC Candlestick chart supporting both compact card mode and full
/// technical indicator mode (MA5/MA10/MA30 + Volume sub-pane).
class CandlestickChartWidget extends StatelessWidget {
  const CandlestickChartWidget({
    super.key,
    required this.candles,
    this.xLabels = const ['10:00', '12:00', '14:00', '16:00', '18:00'],
    this.yLabels = const ['32k', '31k', '30k', '29k', '28k', '27k'],
    this.showMovingAverages = false,
    this.showBollinger = false,
    this.showVolumePane = false,
    this.height = 175,
  });

  final List<CandlePoint> candles;
  final List<String> xLabels;
  final List<String> yLabels;
  final bool showMovingAverages;
  final bool showBollinger;
  final bool showVolumePane;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: height,
          child: CustomPaint(
            painter: _CandlestickPainter(
              candles: candles,
              xLabelCount: xLabels.length,
              yLabels: yLabels,
              showMovingAverages: showMovingAverages,
              showBollinger: showBollinger,
              showVolumePane: showVolumePane,
              gridTextColor: c.textSecondary,
              gridLineColor: c.border,
              surfaceColor: c.surface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 44, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: xLabels
                .map(
                  (label) => Text(
                    label,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter({
    required this.candles,
    required this.xLabelCount,
    required this.yLabels,
    required this.showMovingAverages,
    required this.showBollinger,
    required this.showVolumePane,
    required this.gridTextColor,
    required this.gridLineColor,
    required this.surfaceColor,
  });

  final List<CandlePoint> candles;
  final int xLabelCount;
  final List<String> yLabels;
  final bool showMovingAverages;
  final bool showBollinger;
  final bool showVolumePane;
  final Color gridTextColor;
  final Color gridLineColor;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final leftPad = showVolumePane ? 8.0 : 40.0;
    final rightPad = showVolumePane ? 56.0 : 12.0;
    const topPad = 10.0;
    final volumeH = showVolumePane ? size.height * 0.28 : 0.0;
    final priceBottom = size.height - (showVolumePane ? volumeH + 18 : 2.0);

    final chartRect =
        Rect.fromLTRB(leftPad, topPad, size.width - rightPad, priceBottom);

    var minP = double.infinity;
    var maxP = -double.infinity;
    var maxV = 1.0;
    for (final c in candles) {
      if (c.low < minP) minP = c.low;
      if (c.high > maxP) maxP = c.high;
      if (c.volume > maxV) maxV = c.volume;
    }
    final span = (maxP - minP) == 0 ? 1.0 : (maxP - minP);

    double yForPrice(double price) {
      final norm = (price - minP) / span;
      return chartRect.bottom - 8 - norm * (chartRect.height - 18);
    }

    // Y-axis grid lines & labels
    for (var i = 0; i < yLabels.length; i++) {
      final t = yLabels.length == 1 ? 0.5 : i / (yLabels.length - 1);
      final y = chartRect.top + 8 + t * (chartRect.height - 18);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()
          ..color = gridLineColor.withValues(alpha: 0.7)
          ..strokeWidth = 0.8,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: yLabels[i],
          style: TextStyle(
            color: gridTextColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (showVolumePane) {
        tp.paint(canvas, Offset(chartRect.right + 6, y - tp.height / 2));
      } else {
        tp.paint(canvas, Offset(4, y - tp.height / 2));
      }
    }

    // Candles
    final stepW = chartRect.width / candles.length;
    final bodyW = math.max(3.0, stepW * 0.58);

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final cx = chartRect.left + (i + 0.5) * stepW;
      final color = c.isBullish ? AppColors.positiveGreen : AppColors.negativeRed;

      final highY = yForPrice(c.high);
      final lowY = yForPrice(c.low);
      final openY = yForPrice(c.open);
      final closeY = yForPrice(c.close);

      canvas.drawLine(
        Offset(cx, highY),
        Offset(cx, lowY),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      );

      final topBody = math.min(openY, closeY);
      final botBody = math.max(openY, closeY);
      final bodyRect = Rect.fromLTWH(
        cx - bodyW / 2,
        topBody,
        bodyW,
        math.max(2.5, botBody - topBody),
      );
      canvas.drawRect(bodyRect, Paint()..color = color);
    }

    // Moving averages (MA5 / MA10 / MA30) or Bollinger bands
    if (showMovingAverages || showBollinger) {
      _drawMaLine(canvas, chartRect, stepW, yForPrice, 3, const Color(0xFFF5A623));
      _drawMaLine(canvas, chartRect, stepW, yForPrice, 6, const Color(0xFF16B14B));
      _drawMaLine(canvas, chartRect, stepW, yForPrice, 10, const Color(0xFF7B61FF));
    }

    // Volume sub-pane
    if (showVolumePane) {
      final volTop = priceBottom + 16;
      final volBot = size.height;
      canvas.drawLine(
        Offset(chartRect.left, volTop - 4),
        Offset(chartRect.right, volTop - 4),
        Paint()
          ..color = gridLineColor
          ..strokeWidth = 1,
      );
      for (var i = 0; i < candles.length; i++) {
        final c = candles[i];
        final cx = chartRect.left + (i + 0.5) * stepW;
        final barH = (c.volume / maxV) * (volBot - volTop - 6);
        final color = c.isBullish ? AppColors.positiveGreen : AppColors.negativeRed;
        canvas.drawRect(
          Rect.fromLTWH(cx - bodyW / 2, volBot - barH, bodyW, barH),
          Paint()..color = color,
        );
      }
    } else {
      // Axis outline and focus dot matching compact card mode
      final axisPaint = Paint()
        ..color = AppColors.primaryBlue
        ..strokeWidth = 1.1;
      canvas.drawLine(
        Offset(chartRect.left, chartRect.top),
        Offset(chartRect.left, chartRect.bottom),
        axisPaint,
      );
      canvas.drawLine(
        Offset(chartRect.left, chartRect.bottom),
        Offset(chartRect.right, chartRect.bottom),
        axisPaint,
      );

      final lastIdx = candles.length - 1;
      final lastX = chartRect.left + (lastIdx + 0.5) * stepW;
      final lastY = yForPrice(candles.last.high);
      canvas.drawLine(
        Offset(lastX, lastY),
        Offset(lastX, chartRect.bottom),
        Paint()
          ..color = AppColors.primaryBlue.withValues(alpha: 0.7)
          ..strokeWidth = 1.0,
      );
      canvas.drawCircle(Offset(lastX, lastY - 8), 8.5, Paint()..color = AppColors.primaryBlue);
      canvas.drawCircle(Offset(lastX, lastY - 8), 3.5, Paint()..color = surfaceColor);
    }
  }

  void _drawMaLine(
    Canvas canvas,
    Rect chartRect,
    double stepW,
    double Function(double) yForPrice,
    int period,
    Color color,
  ) {
    final pts = <Offset>[];
    for (var i = 0; i < candles.length; i++) {
      final start = math.max(0, i - period + 1);
      var sum = 0.0;
      for (var j = start; j <= i; j++) {
        sum += candles[j].close;
      }
      final avg = sum / (i - start + 1);
      pts.add(Offset(chartRect.left + (i + 0.5) * stepW, yForPrice(avg)));
    }
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final midX = (pts[i].dx + pts[i + 1].dx) / 2;
      path.cubicTo(midX, pts[i].dy, midX, pts[i + 1].dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25,
    );
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) =>
      oldDelegate.candles != candles ||
      oldDelegate.showMovingAverages != showMovingAverages ||
      oldDelegate.showBollinger != showBollinger;
}
