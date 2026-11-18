import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Interactive smooth area spline chart matching Home and Coin Graph screens.
class AreaChartWidget extends StatefulWidget {
  const AreaChartWidget({
    super.key,
    required this.points,
    this.xLabels = const ['10:00', '12:00', '14:00', '16:00', '18:00'],
    this.yLabels = const [],
    this.showYAxis = false,
    this.showHorizontalGrid = false,
    this.height = 175,
    this.onPointSelected,
  });

  final List<double> points;
  final List<String> xLabels;
  final List<String> yLabels;
  final bool showYAxis;
  final bool showHorizontalGrid;
  final double height;
  final ValueChanged<int>? onPointSelected;

  @override
  State<AreaChartWidget> createState() => _AreaChartWidgetState();
}

class _AreaChartWidgetState extends State<AreaChartWidget> {
  int? _selectedIndex;

  void _handleTouch(Offset localPos, double width) {
    if (widget.points.isEmpty) return;
    final leftPad = widget.showYAxis ? 38.0 : 0.0;
    final chartW = math.max(1.0, width - leftPad - 12);
    final relX = (localPos.dx - leftPad).clamp(0.0, chartW);
    final idx = ((relX / chartW) * (widget.points.length - 1)).round();
    setState(() => _selectedIndex = idx.clamp(0, widget.points.length - 1));
    widget.onPointSelected?.call(_selectedIndex!);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final activeIdx = (_selectedIndex ?? widget.points.length - 1)
        .clamp(0, math.max(0, widget.points.length - 1))
        .toInt();

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _handleTouch(d.localPosition, constraints.maxWidth),
          onHorizontalDragUpdate: (d) =>
              _handleTouch(d.localPosition, constraints.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: widget.height,
                child: CustomPaint(
                  painter: _AreaChartPainter(
                    points: widget.points,
                    selectedIndex: activeIdx,
                    xLabelCount: widget.xLabels.length,
                    yLabels: widget.yLabels,
                    showYAxis: widget.showYAxis,
                    showHorizontalGrid: widget.showHorizontalGrid,
                    gridTextColor: c.textSecondary,
                    gridLineColor: c.border,
                    surfaceColor: c.surface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(
                  left: widget.showYAxis ? 44 : 26,
                  right: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.xLabels
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
          ),
        );
      },
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({
    required this.points,
    required this.selectedIndex,
    required this.xLabelCount,
    required this.yLabels,
    required this.showYAxis,
    required this.showHorizontalGrid,
    required this.gridTextColor,
    required this.gridLineColor,
    required this.surfaceColor,
  });

  final List<double> points;
  final int selectedIndex;
  final int xLabelCount;
  final List<String> yLabels;
  final bool showYAxis;
  final bool showHorizontalGrid;
  final Color gridTextColor;
  final Color gridLineColor;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final leftPad = showYAxis ? 40.0 : 0.0;
    final rightPad = showYAxis ? 14.0 : 0.0;
    const topPad = 14.0;
    const bottomPad = 2.0;

    final chartRect = Rect.fromLTRB(
      leftPad,
      topPad,
      size.width - rightPad,
      size.height - bottomPad,
    );

    if (showYAxis && yLabels.isNotEmpty) {
      for (var i = 0; i < yLabels.length; i++) {
        final t = yLabels.length == 1 ? 0.5 : i / (yLabels.length - 1);
        final y = chartRect.top + 8 + t * (chartRect.height - 20);
        if (showHorizontalGrid) {
          canvas.drawLine(
            Offset(chartRect.left, y),
            Offset(chartRect.right, y),
            Paint()
              ..color = gridLineColor.withValues(alpha: 0.7)
              ..strokeWidth = 0.8,
          );
        }
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
        tp.paint(canvas, Offset(4, y - tp.height / 2));
      }
    }

    final minVal = points.reduce(math.min);
    final maxVal = points.reduce(math.max);
    final span = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final pts = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = chartRect.left +
          (i / (points.length - 1)) * (chartRect.width - (showYAxis ? 6 : 20));
      final norm = (points[i] - minVal) / span;
      final y = chartRect.bottom - 18 - norm * (chartRect.height - 32);
      pts.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(pts.last.dx, chartRect.bottom)
      ..lineTo(pts.first.dx, chartRect.bottom)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryBlue.withValues(alpha: 0.25),
          AppColors.primaryBlue.withValues(alpha: 0.02),
        ],
      ).createShader(chartRect);

    canvas.drawPath(areaPath, areaPaint);

    // Draw vertical guide lines matching Figma's 10:00..18:00 ticks
    final guidePaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.45)
      ..strokeWidth = 0.9;
    for (var i = 0; i < xLabelCount; i++) {
      final ratio = xLabelCount == 1 ? 0.5 : (i + 0.5) / xLabelCount;
      final gx = chartRect.left + ratio * (chartRect.width - 12);
      final idx =
          ((ratio * (pts.length - 1)).round()).clamp(0, pts.length - 1);
      canvas.drawLine(
        Offset(gx, pts[idx].dy),
        Offset(gx, chartRect.bottom),
        guidePaint,
      );
    }

    // Main spline line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.primaryBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9
        ..strokeCap = StrokeCap.round,
    );

    // Axis baseline
    final axisPaint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 1.1;
    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      axisPaint,
    );
    if (showYAxis) {
      canvas.drawLine(
        Offset(chartRect.left, chartRect.top),
        Offset(chartRect.left, chartRect.bottom),
        axisPaint,
      );
    }

    // Selected indicator dot with blue halo & center dot
    final focusPt = pts[selectedIndex];
    canvas.drawLine(
      Offset(focusPt.dx, focusPt.dy),
      Offset(focusPt.dx, chartRect.bottom),
      Paint()
        ..color = AppColors.primaryBlue.withValues(alpha: 0.85)
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(
      focusPt,
      11,
      Paint()..color = AppColors.primaryBlue.withValues(alpha: 0.20),
    );
    canvas.drawCircle(
      focusPt,
      8.5,
      Paint()..color = AppColors.primaryBlue,
    );
    canvas.drawCircle(
      focusPt,
      3.5,
      Paint()..color = surfaceColor,
    );
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.surfaceColor != surfaceColor;
}
