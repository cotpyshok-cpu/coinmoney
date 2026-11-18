import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D-styled circular cryptocurrency badge matching the Figma coin icons.
class CoinBadge extends StatelessWidget {
  const CoinBadge({
    super.key,
    required this.symbol,
    this.size = 40,
  });

  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final upper = symbol.toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _gradientFor(upper),
        boxShadow: [
          BoxShadow(
            color: _primaryColorFor(upper).withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.82,
          height: size * 0.82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),
              width: 1.5,
            ),
          ),
          child: Center(child: _glyphFor(upper, size)),
        ),
      ),
    );
  }

  Color _primaryColorFor(String s) {
    switch (s) {
      case 'BTC':
        return const Color(0xFFF7931A);
      case 'ETH':
        return const Color(0xFF627EEA);
      case 'SOL':
        return const Color(0xFF28C3A9);
      case 'ATOM':
        return const Color(0xFF565E72);
      case 'CRO':
        return const Color(0xFF3E4C73);
      case 'ADA':
        return const Color(0xFF3468D1);
      case 'USDT':
        return const Color(0xFF26A17B);
      case 'BNB':
        return const Color(0xFFF3BA2F);
      case 'LTC':
        return const Color(0xFF345D9D);
      case 'LINK':
        return const Color(0xFF2A5ADA);
      case 'FARM':
        return const Color(0xFF00A86B);
      default:
        return const Color(0xFF2F66F6);
    }
  }

  Gradient _gradientFor(String s) {
    if (s == 'SOL') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9945FF), Color(0xFF14F195)],
      );
    }
    final base = _primaryColorFor(s);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(base, Colors.white, 0.25) ?? base,
        base,
      ],
    );
  }

  Widget _glyphFor(String s, double size) {
    switch (s) {
      case 'BTC':
        return Transform.rotate(
          angle: 0.18,
          child: Text(
            '₿',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.48,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
        );
      case 'ETH':
        return CustomPaint(
          size: Size(size * 0.44, size * 0.44),
          painter: _EthGlyphPainter(),
        );
      case 'SOL':
        return CustomPaint(
          size: Size(size * 0.44, size * 0.44),
          painter: _SolGlyphPainter(),
        );
      case 'ATOM':
        return CustomPaint(
          size: Size(size * 0.50, size * 0.50),
          painter: _AtomGlyphPainter(),
        );
      case 'USDT':
        return Text(
          '₮',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.48,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        );
      default:
        return Text(
          s.length >= 2 ? s.substring(0, 1) : s,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        );
    }
  }
}

class _EthGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final top = Path()
      ..moveTo(cx, 0)
      ..lineTo(size.width * 0.85, size.height * 0.52)
      ..lineTo(cx, size.height * 0.68)
      ..lineTo(size.width * 0.15, size.height * 0.52)
      ..close();
    final bottom = Path()
      ..moveTo(cx, size.height)
      ..lineTo(size.width * 0.85, size.height * 0.60)
      ..lineTo(cx, size.height * 0.76)
      ..lineTo(size.width * 0.15, size.height * 0.60)
      ..close();

    canvas.drawPath(top, Paint()..color = Colors.white);
    canvas.drawPath(bottom, Paint()..color = Colors.white.withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SolGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.20 + i * 0.25);
      final skew = i == 1 ? -size.width * 0.08 : size.width * 0.08;
      final path = Path()
        ..moveTo(size.width * 0.14 + skew, y)
        ..lineTo(size.width * 0.86 + skew, y)
        ..lineTo(size.width * 0.78 + skew, y + size.height * 0.14)
        ..lineTo(size.width * 0.06 + skew, y + size.height * 0.14)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AtomGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 3);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * 0.9,
          height: size.height * 0.34,
        ),
        stroke,
      );
      canvas.restore();
    }
    canvas.drawCircle(center, size.width * 0.08, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
