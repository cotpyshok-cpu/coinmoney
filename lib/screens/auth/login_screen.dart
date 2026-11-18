import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coinmoney_logo.dart';
import '../../widgets/primary_button.dart';
import '../main_shell.dart';
import 'password_reset_screen.dart';

/// Login screen matching Login.jpg & Login completed.jpg.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl =
      TextEditingController(text: 'tomashuk.dima.1992@gmail.com');
  final TextEditingController _passwordCtrl =
      TextEditingController(text: 'Coinmoney2026!');
  bool _obscure = false;
  bool _touchId = false;

  bool get _emailValid =>
      _emailCtrl.text.contains('@') && _emailCtrl.text.contains('.');
  bool get _passwordValid => _passwordCtrl.text.length >= 8;
  bool get _canSubmit => _emailValid && _passwordValid;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_canSubmit) return;
    final state = AppStateScope.of(context);
    state.updateProfile(email: _emailCtrl.text, touchId: _touchId);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(child: CoinmoneyLogo(iconSize: 26, fontSize: 22)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Login to your\nAccount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 28),
              _LabeledAuthField(
                label: 'Email address',
                controller: _emailCtrl,
                icon: Icons.mail_outline,
                isValid: _emailValid,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),
              _LabeledAuthField(
                label: 'Password',
                controller: _passwordCtrl,
                icon: Icons.lock_outline,
                isValid: _passwordValid,
                obscureText: _obscure,
                onToggleObscure: () => setState(() => _obscure = !_obscure),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forgot your password? ',
                    style: TextStyle(color: c.textPrimary, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PasswordResetScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Click here',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      'Unlock with Touch ID?',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: _touchId,
                    activeTrackColor: AppColors.primaryBlue,
                    onChanged: (v) => setState(() => _touchId = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Sign in',
                enabled: _canSubmit,
                onPressed: _signIn,
              ),
              const SizedBox(height: 54),
              Row(
                children: [
                  Expanded(child: Divider(color: c.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'or continue with',
                      style: TextStyle(color: c.textPrimary, fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: c.border)),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SquareSocialButton(
                    icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 26),
                    onTap: _signIn,
                  ),
                  const SizedBox(width: 24),
                  _SquareSocialButton(
                    icon: Icon(Icons.apple, color: c.textPrimary, size: 26),
                    onTap: _signIn,
                  ),
                  const SizedBox(width: 24),
                  _SquareSocialButton(
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFFEA4335),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onTap: _signIn,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledAuthField extends StatelessWidget {
  const _LabeledAuthField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.isValid,
    required this.onChanged,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isValid;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: c.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: c.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onToggleObscure != null)
              IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: c.textSecondary,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
            if (isValid)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.positiveTextGreen,
                  size: 22,
                ),
              ),
          ],
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isValid ? AppColors.primaryBlue : c.border,
          ),
        ),
      ),
    );
  }
}

class _SquareSocialButton extends StatelessWidget {
  const _SquareSocialButton({required this.icon, required this.onTap});

  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Center(child: icon),
      ),
    );
  }
}
