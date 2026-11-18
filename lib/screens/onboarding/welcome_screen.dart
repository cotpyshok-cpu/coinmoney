import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coinmoney_logo.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';
import '../auth/registration_flow_screen.dart';
import '../main_shell.dart';

/// Welcome / Sign Up choice screen matching Sign in/Sign up.jpg & Sign up-1.jpg.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _continueWithSocial(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed in with $provider')),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const CoinmoneyLogo(iconSize: 28, fontSize: 23),
              const SizedBox(height: 44),
              Text(
                'Hello! Start your\ncrypto investment\ntoday',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 36),
              _SocialRowButton(
                label: 'Continue with Facebook',
                icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 24),
                onTap: () => _continueWithSocial(context, 'Facebook'),
              ),
              const SizedBox(height: 14),
              _SocialRowButton(
                label: 'Continue with Google',
                icon: const _GoogleBadge(),
                onTap: () => _continueWithSocial(context, 'Google'),
              ),
              const SizedBox(height: 14),
              _SocialRowButton(
                label: 'Continue with Apple',
                icon: Icon(Icons.apple, color: c.textPrimary, size: 24),
                onTap: () => _continueWithSocial(context, 'Apple'),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Sign up with email',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegistrationFlowScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(child: Divider(color: c.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: c.border)),
                ],
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Sign In',
                outlined: true,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialRowButton extends StatelessWidget {
  const _SocialRowButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              SizedBox(width: 28, child: Center(child: icon)),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFFEA4335),
        fontSize: 21,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
