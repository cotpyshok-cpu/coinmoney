import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/password_reset_screen.dart';
import 'screens/auth/registration_flow_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CoinmoneyApp());
}

/// Root Coinmoney Flutter application.
class CoinmoneyApp extends StatefulWidget {
  const CoinmoneyApp({super.key});

  @override
  State<CoinmoneyApp> createState() => _CoinmoneyAppState();
}

class _CoinmoneyAppState extends State<CoinmoneyApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          return MaterialApp(
            title: 'Coinmoney',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: _appState.themeMode,
            builder: (context, child) {
              final width = MediaQuery.of(context).size.width;
              if (width > 520 && child != null) {
                return ColoredBox(
                  color: _appState.isDarkMode
                      ? const Color(0xFF0A0B0E)
                      : const Color(0xFFE7ECF5),
                  child: Center(
                    child: Container(
                      width: 412,
                      height: 860,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 32,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                );
              }
              return child ?? const SizedBox.shrink();
            },
            initialRoute: '/',
            routes: {
              '/': (_) => const OnboardingScreen(),
              '/welcome': (_) => const WelcomeScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegistrationFlowScreen(),
              '/reset': (_) => const PasswordResetScreen(),
              '/home': (_) => const MainShellScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
