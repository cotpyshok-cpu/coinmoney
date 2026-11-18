import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../coin_badge.dart';

/// Flowing subtle wave lines drawn across the Onboarding screens.
class WaveBackgroundPainter extends CustomPainter {
  WaveBackgroundPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const lineCount = 12;
    for (var l = 0; l < lineCount; l++) {
      final path = Path();
      final yOffset = size.height * 0.56 + l * 4.5;
      for (var x = 0.0; x <= size.width; x += 6) {
        final wave = math.sin((x / size.width) * math.pi * 3.2 + l * 0.14) * 26 +
            math.cos((x / size.width) * math.pi * 1.6) * 14;
        if (x == 0) {
          path.moveTo(x, yOffset + wave);
        } else {
          path.lineTo(x, yOffset + wave);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveBackgroundPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Isometric vector illustrations for Onboarding slides 1, 2, and 3.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key, required this.pageIndex});

  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(290, 260),
            painter: _OnboardingScenePainter(pageIndex: pageIndex),
          ),
          if (pageIndex == 0) ...[
            const Positioned(top: 12, child: CoinBadge(symbol: 'ETH', size: 28)),
            const Positioned(left: 24, top: 108, child: CoinBadge(symbol: 'BTC', size: 28)),
            const Positioned(right: 24, top: 108, child: CoinBadge(symbol: 'SOL', size: 28)),
          ] else if (pageIndex == 1) ...[
            const Positioned(left: 72, top: 32, child: CoinBadge(symbol: 'BTC', size: 28)),
            const Positioned(left: 132, top: 12, child: CoinBadge(symbol: 'SOL', size: 28)),
            const Positioned(right: 76, top: 18, child: CoinBadge(symbol: 'ETH', size: 28)),
          ] else ...[
            const Positioned(left: 52, top: 26, child: CoinBadge(symbol: 'SOL', size: 28)),
            const Positioned(right: 46, top: 44, child: CoinBadge(symbol: 'BTC', size: 28)),
            const Positioned(left: 64, bottom: 44, child: CoinBadge(symbol: 'ETH', size: 28)),
          ],
        ],
      ),
    );
  }
}

class _OnboardingScenePainter extends CustomPainter {
  _OnboardingScenePainter({required this.pageIndex});

  final int pageIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final softBlue = Paint()..color = const Color(0xFF9AC4FF).withValues(alpha: 0.42);
    final midBlue = Paint()..color = const Color(0xFF4C89FA).withValues(alpha: 0.55);
    final slate = Paint()..color = const Color(0xFF3E465E);

    // Base isometric diamond platforms
    void drawIsoDiamond(Offset center, double rx, double ry, Paint fill) {
      final path = Path()
        ..moveTo(center.dx, center.dy - ry)
        ..lineTo(center.dx + rx, center.dy)
        ..lineTo(center.dx, center.dy + ry)
        ..lineTo(center.dx - rx, center.dy)
        ..close();
      canvas.drawPath(path, fill);
    }

    if (pageIndex == 0) {
      drawIsoDiamond(Offset(cx, cy + 54), 80, 44, softBlue);
      drawIsoDiamond(Offset(cx - 58, cy + 28), 38, 22, softBlue);
      drawIsoDiamond(Offset(cx + 58, cy + 28), 38, 22, softBlue);
      drawIsoDiamond(Offset(cx, cy - 10), 46, 26, midBlue);

      // Holographic curved screen arcs
      final arcPaint = Paint()
        ..color = const Color(0xFF60A5FA).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy - 35), width: 170, height: 80),
        math.pi * 1.15,
        math.pi * 0.7,
        false,
        arcPaint,
      );

      // Trader figure silhouette
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy - 12), width: 28, height: 14),
        Paint()..color = const Color(0xFF1E3A8A).withValues(alpha: 0.25),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy - 42), width: 20, height: 34),
          const Radius.circular(6),
        ),
        slate,
      );
      canvas.drawRect(Rect.fromLTWH(cx - 7, cy - 26, 6, 18), slate);
      canvas.drawRect(Rect.fromLTWH(cx + 1, cy - 26, 6, 18), slate);
      canvas.drawCircle(
        Offset(cx, cy - 66),
        8.5,
        Paint()..color = const Color(0xFFE0B49E),
      );
    } else if (pageIndex == 1) {
      // Tilted isometric phone + glowing charts
      canvas.save();
      canvas.translate(cx, cy + 20);
      canvas.rotate(-0.48);
      final phoneRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-76, -34, 152, 74),
        const Radius.circular(14),
      );
      canvas.drawRRect(phoneRect, slate);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-64, -26, 128, 58),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.35),
      );
      canvas.restore();

      // Glowing orange & blue area charts rising out of phone
      final orangeChart = Path()
        ..moveTo(cx - 56, cy + 12)
        ..lineTo(cx - 32, cy - 44)
        ..lineTo(cx - 12, cy - 18)
        ..lineTo(cx + 8, cy - 58)
        ..lineTo(cx + 22, cy + 12)
        ..close();
      canvas.drawPath(
        orangeChart,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF5931E).withValues(alpha: 0.85),
              const Color(0xFFF5931E).withValues(alpha: 0.10),
            ],
          ).createShader(Rect.fromLTWH(cx - 56, cy - 58, 80, 72)),
      );

      final blueChart = Path()
        ..moveTo(cx - 8, cy + 20)
        ..lineTo(cx + 18, cy - 40)
        ..lineTo(cx + 42, cy - 12)
        ..lineTo(cx + 60, cy - 28)
        ..lineTo(cx + 72, cy + 20)
        ..close();
      canvas.drawPath(
        blueChart,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue.withValues(alpha: 0.85),
              AppColors.primaryBlue.withValues(alpha: 0.08),
            ],
          ).createShader(Rect.fromLTWH(cx - 8, cy - 40, 80, 60)),
      );
    } else {
      // Laptop + 4 surrounding isometric blockchain nodes
      final nodes = [
        Offset(cx, cy - 62),
        Offset(cx - 82, cy),
        Offset(cx + 82, cy),
        Offset(cx, cy + 62),
      ];
      final linePaint = Paint()
        ..color = AppColors.primaryBlue.withValues(alpha: 0.45)
        ..strokeWidth = 1.4;
      for (final n in nodes) {
        canvas.drawLine(Offset(cx, cy), n, linePaint);
        drawIsoDiamond(n, 24, 14, softBlue);
        drawIsoDiamond(Offset(n.dx, n.dy - 14), 24, 14, midBlue);
      }

      // Isometric laptop center
      drawIsoDiamond(Offset(cx, cy + 12), 48, 26, slate);
      final screen = Path()
        ..moveTo(cx - 24, cy - 42)
        ..lineTo(cx + 28, cy - 14)
        ..lineTo(cx + 28, cy + 12)
        ..lineTo(cx - 24, cy - 16)
        ..close();
      canvas.drawPath(screen, Paint()..color = const Color(0xFF4F8DFD));
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingScenePainter oldDelegate) =>
      oldDelegate.pageIndex != pageIndex;
}

/// Shield/Orbital illustration used in "Get started in 3 easy steps",
/// "Verification Success", and "Transaction Success" screens.
class OrbitalBadgeIllustration extends StatelessWidget {
  const OrbitalBadgeIllustration({
    super.key,
    required this.isSuccess,
    this.size = 185,
  });

  final bool isSuccess;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OrbitalIllustrationPainter(isSuccess: isSuccess),
      ),
    );
  }
}

class _OrbitalIllustrationPainter extends CustomPainter {
  _OrbitalIllustrationPainter({required this.isSuccess});

  final bool isSuccess;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    if (!isSuccess) {
      // Soft shield backing
      final shield = Path()
        ..moveTo(cx, size.height * 0.08)
        ..lineTo(size.width * 0.82, size.height * 0.22)
        ..quadraticBezierTo(
          size.width * 0.80,
          size.height * 0.72,
          cx,
          size.height * 0.90,
        )
        ..quadraticBezierTo(
          size.width * 0.20,
          size.height * 0.72,
          size.width * 0.18,
          size.height * 0.22,
        )
        ..close();
      canvas.drawPath(
        shield,
        Paint()..color = const Color(0xFFB5BECE).withValues(alpha: 0.35),
      );
    }

    // Elliptical orbits
    final orbitPaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final angle in [-0.45, 0.45, 1.35]) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * 0.88,
          height: size.height * 0.36,
        ),
        orbitPaint,
      );
      canvas.restore();
    }

    // Accent orbital dots
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.26),
      4.5,
      Paint()..color = AppColors.primaryBlue,
    );
    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.76),
      4.5,
      Paint()..color = AppColors.primaryBlue,
    );

    if (isSuccess) {
      // Checkmark circle
      canvas.drawCircle(
        center,
        size.width * 0.22,
        Paint()
          ..color = const Color(0xFF8FD1EC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
      final check = Path()
        ..moveTo(cx - size.width * 0.09, cy + 2)
        ..lineTo(cx - size.width * 0.02, cy + size.height * 0.09)
        ..lineTo(cx + size.width * 0.11, cy - size.height * 0.08);
      canvas.drawPath(
        check,
        Paint()
          ..color = const Color(0xFF428BF9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    } else {
      // Padlock icon
      final shackle = Rect.fromCircle(
        center: Offset(cx, cy - 16),
        radius: 22,
      );
      canvas.drawArc(
        shackle,
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFF428BF9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy + 12), width: 64, height: 50),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFF9CD8F2),
      );
      canvas.drawCircle(
        Offset(cx, cy + 8),
        7,
        Paint()..color = const Color(0xFF428BF9),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 3.5, cy + 10, 7, 16),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF428BF9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalIllustrationPainter oldDelegate) =>
      oldDelegate.isSuccess != isSuccess;
}

/// Isometric phone + envelope illustration for "Confirm your email" screen.
class EmailConfirmationIllustration extends StatelessWidget {
  const EmailConfirmationIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(240, 210),
      painter: _EmailIllustrationPainter(),
    );
  }
}

class _EmailIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Tilted phone at bottom
    canvas.save();
    canvas.translate(cx + 8, cy + 36);
    canvas.rotate(-0.42);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-72, -36, 144, 72),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF4C556E),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-62, -28, 124, 56),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFEFF3FA),
    );
    canvas.restore();

    // Floating light-blue envelope
    final envPath = Path()
      ..moveTo(cx - 72, cy - 42)
      ..lineTo(cx + 22, cy - 86)
      ..lineTo(cx + 22, cy - 18)
      ..lineTo(cx - 72, cy + 26)
      ..close();
    canvas.drawPath(envPath, Paint()..color = const Color(0xFFAADDF4));
    canvas.drawPath(
      envPath,
      Paint()
        ..color = const Color(0xFF5FAEE3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    final flap = Path()
      ..moveTo(cx - 72, cy - 42)
      ..lineTo(cx - 24, cy - 22)
      ..lineTo(cx + 22, cy - 86);
    canvas.drawPath(
      flap,
      Paint()
        ..color = const Color(0xFF5FAEE3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Notification badge "1"
    final badgeCenter = Offset(cx - 64, cy - 44);
    canvas.drawCircle(badgeCenter, 16, Paint()..color = const Color(0xFF697288));
    final tp = TextPainter(
      text: const TextSpan(
        text: '1',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(badgeCenter.dx - tp.width / 2, badgeCenter.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wireframe polygonal face mesh inside blue corner brackets for Selfie Verification.
class SelfieMeshIllustration extends StatelessWidget {
  const SelfieMeshIllustration({super.key, this.size = 220});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(painter: _SelfieMeshPainter()),
    );
  }
}

class _SelfieMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Corner brackets
    final bracketPaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const b = 26.0;
    const pad = 10.0;
    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(pad, pad + b)
        ..lineTo(pad, pad)
        ..lineTo(pad + b, pad),
      bracketPaint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - pad - b, pad)
        ..lineTo(size.width - pad, pad)
        ..lineTo(size.width - pad, pad + b),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(pad, size.height - pad - b)
        ..lineTo(pad, size.height - pad)
        ..lineTo(pad + b, size.height - pad),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - pad - b, size.height - pad)
        ..lineTo(size.width - pad, size.height - pad)
        ..lineTo(size.width - pad, size.height - pad - b),
      bracketPaint,
    );

    // Polygonal face outline + mesh lines
    final meshPaint = Paint()
      ..color = const Color(0xFF8AC7EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final pts = <Offset>[
      Offset(cx, cy - 88), // 0 top
      Offset(cx - 46, cy - 68), // 1 forehead L
      Offset(cx + 46, cy - 68), // 2 forehead R
      Offset(cx - 54, cy - 22), // 3 temple L
      Offset(cx + 54, cy - 22), // 4 temple R
      Offset(cx - 24, cy - 26), // 5 eye L
      Offset(cx + 24, cy - 26), // 6 eye R
      Offset(cx, cy - 12), // 7 nose bridge
      Offset(cx, cy + 14), // 8 nose tip
      Offset(cx - 42, cy + 28), // 9 cheek L
      Offset(cx + 42, cy + 28), // 10 cheek R
      Offset(cx - 20, cy + 44), // 11 mouth L
      Offset(cx + 20, cy + 44), // 12 mouth R
      Offset(cx, cy + 84), // 13 chin
    ];

    const edges = [
      [0, 1], [0, 2], [1, 3], [2, 4], [3, 9], [4, 10], [9, 13], [10, 13],
      [0, 7], [1, 5], [2, 6], [1, 7], [2, 7], [3, 5], [4, 6], [5, 7], [6, 7],
      [7, 8], [5, 8], [6, 8], [3, 8], [4, 8], [8, 9], [8, 10], [8, 11], [8, 12],
      [9, 11], [10, 12], [11, 12], [11, 13], [12, 13], [9, 12], [10, 11],
    ];

    for (final e in edges) {
      canvas.drawLine(pts[e[0]], pts[e[1]], meshPaint);
    }
    for (final p in pts) {
      canvas.drawCircle(p, 2.2, Paint()..color = const Color(0xFF72BAE6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ukraine circle flag icon used in Submit Documents KYC step.
class UkraineFlagCircle extends StatelessWidget {
  const UkraineFlagCircle({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          children: [
            Expanded(child: Container(color: const Color(0xFF0057B7))),
            Expanded(child: Container(color: const Color(0xFFFFD700))),
          ],
        ),
      ),
    );
  }
}
