import 'package:flutter/material.dart';

/// Brand and semantic color tokens extracted from the Coinmoney Figma design.
class AppColors {
  AppColors._({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.secondarySurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.disabledButton,
    required this.disabledButtonText,
    required this.cardShadow,
    required this.navBarBackground,
  });

  static const Color primaryBlue = Color(0xFF2F66F6);
  static const Color primaryBlueSoft = Color(0xFF5383FF);
  static const Color positiveGreen = Color(0xFF007F23);
  static const Color positiveTextGreen = Color(0xFF16B14B);
  static const Color positiveBadgeBg = Color(0xFFDFFAD8);
  static const Color negativeRed = Color(0xFFCC0000);
  static const Color negativeTextRed = Color(0xFFE53935);
  static const Color favoriteOrange = Color(0xFFF5931E);

  final bool isDark;
  final Color background;
  final Color surface;
  final Color secondarySurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color disabledButton;
  final Color disabledButtonText;
  final Color cardShadow;
  final Color navBarBackground;

  static final AppColors light = AppColors._(
    isDark: false,
    background: const Color(0xFFF7F8FC),
    surface: const Color(0xFFFFFFFF),
    secondarySurface: const Color(0xFFEBEEF5),
    textPrimary: const Color(0xFF0D1426),
    textSecondary: const Color(0xFF6C7589),
    textMuted: const Color(0xFF9AA3B5),
    border: const Color(0xFFE3E7F0),
    disabledButton: const Color(0xFFD8DCE6),
    disabledButtonText: const Color(0xFF7B8499),
    cardShadow: const Color(0x121B254A),
    navBarBackground: const Color(0xFFFFFFFF),
  );

  static final AppColors dark = AppColors._(
    isDark: true,
    background: const Color(0xFF121318),
    surface: const Color(0xFF222531),
    secondarySurface: const Color(0xFF1B1E28),
    textPrimary: const Color(0xFFFFFFFF),
    textSecondary: const Color(0xFF8E97A8),
    textMuted: const Color(0xFF667085),
    border: const Color(0xFF2E3344),
    disabledButton: const Color(0xFF2A2F3F),
    disabledButtonText: const Color(0xFF727C94),
    cardShadow: const Color(0x33000000),
    navBarBackground: const Color(0xFF181A22),
  );

  /// Resolves adaptive color tokens from the current [BuildContext].
  static AppColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }

  /// Standard elevated card decoration used across Coinmoney screens.
  BoxDecoration cardDecoration({
    double radius = 14,
    Color? color,
    bool withBorder = false,
  }) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius),
      border: withBorder ? Border.all(color: border, width: 1) : null,
      boxShadow: [
        BoxShadow(
          color: cardShadow,
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

/// Builds Flutter [ThemeData] for Coinmoney light and dark modes.
class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() => _buildTheme(AppColors.light, Brightness.light);

  static ThemeData darkTheme() => _buildTheme(AppColors.dark, Brightness.dark);

  static ThemeData _buildTheme(AppColors c, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      primaryColor: AppColors.primaryBlue,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        secondary: AppColors.primaryBlueSoft,
        onSecondary: Colors.white,
        error: AppColors.negativeRed,
        onError: Colors.white,
        surface: c.surface,
        onSurface: c.textPrimary,
      ),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: c.textMuted, fontSize: 15),
      ),
      dividerColor: c.border,
    );
  }
}
