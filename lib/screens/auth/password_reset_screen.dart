import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/illustrations/app_illustrations.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';

/// Password reset 2-step flow matching Password reset.jpg & Letter sent.jpg.
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  bool _letterSent = false;

  bool get _emailValid =>
      _emailCtrl.text.contains('@') && _emailCtrl.text.contains('.');

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary, size: 20),
                    onPressed: () {
                      if (_letterSent) {
                        setState(() => _letterSent = false);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: StepIndicator(
                        currentStep: 1,
                        progress: _letterSent ? 0.35 : 0.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              if (!_letterSent) ...[
                const SizedBox(height: 24),
                Text(
                  'Password reset',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please enter your registered email address to reset your password',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textSecondary, fontSize: 15),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: _emailValid ? AppColors.primaryBlue : c.textSecondary,
                    ),
                    suffixIcon: _emailValid
                        ? const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.positiveTextGreen,
                          )
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _emailValid ? AppColors.primaryBlue : c.border,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                PrimaryButton(
                  label: 'Continue',
                  enabled: _emailValid,
                  onPressed: () => setState(() => _letterSent = true),
                ),
                const SizedBox(height: 28),
                Text(
                  'By registering you accept our Terms & Conditions and Privacy Policy. Your data will be security encrypted with TLS',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textSecondary, fontSize: 13),
                ),
              ] else ...[
                const Spacer(),
                const EmailConfirmationIllustration(),
                const SizedBox(height: 26),
                Text(
                  'Confirm your email',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We just sent you an email to\n${_emailCtrl.text}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textSecondary, fontSize: 15),
                ),
                const SizedBox(height: 36),
                PrimaryButton(
                  label: 'Confirm',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset link confirmed')),
                    );
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Resent reset email to ${_emailCtrl.text}'),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: c.textPrimary, fontSize: 15),
                      children: const [
                        TextSpan(text: 'I '),
                        TextSpan(
                          text: 'didn’t receive',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' my email'),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
