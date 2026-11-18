import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/illustrations/app_illustrations.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';
import '../main_shell.dart';
import 'login_screen.dart';

/// Complete 9-step Registration & KYC verification wizard matching Figma:
/// Intro -> Email -> OTP -> Password -> Submit Documents -> Scan -> Capture -> Selfie -> Success.
class RegistrationFlowScreen extends StatefulWidget {
  const RegistrationFlowScreen({super.key});

  @override
  State<RegistrationFlowScreen> createState() => _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState extends State<RegistrationFlowScreen> {
  int _step = 0;

  final TextEditingController _emailCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _touchId = false;

  String _location = 'Ukraine';
  int _docMethod = 0; // 0: National ID Card, 1: Passport, 2: Driver license

  bool get _emailValid =>
      _emailCtrl.text.contains('@') && _emailCtrl.text.contains('.');
  bool get _otpComplete => _otpCtrls.every((c) => c.text.trim().length == 1);
  bool get _passValid =>
      _passCtrl.text.length >= 8 && _passCtrl.text == _confirmCtrl.text;

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _fillDemoOtp() {
    const code = ['7', '6', '1', '8', '9', '8'];
    for (var i = 0; i < 6; i++) {
      _otpCtrls[i].text = code[i];
    }
    setState(() {});
  }

  void _finishToApp() {
    final state = AppStateScope.of(context);
    state.updateProfile(
      email: _emailValid ? _emailCtrl.text : state.userEmail,
      verified: true,
      touchId: _touchId,
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
      (route) => false,
    );
  }

  int get _indicatorStep {
    if (_step <= 3) return 1;
    if (_step <= 6) return 2;
    return 3;
  }

  double get _indicatorProgress {
    switch (_step) {
      case 2:
        return 0.35;
      case 3:
        return 0.7;
      case 5:
      case 6:
        return 0.5;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: _step == 6 ? const Color(0xFF2B2F3A) : c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: _step == 6 ? Colors.white70 : c.textSecondary,
                      size: 20,
                    ),
                    onPressed: _back,
                  ),
                  Expanded(
                    child: _step == 0
                        ? const SizedBox.shrink()
                        : Center(
                            child: StepIndicator(
                              currentStep: _step == 8 ? 4 : _indicatorStep,
                              progress: _indicatorProgress,
                            ),
                          ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(child: _buildStepBody(c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBody(AppColors c) {
    switch (_step) {
      case 0:
        return _buildIntro(c);
      case 1:
        return _buildEmailStep(c);
      case 2:
        return _buildOtpStep(c);
      case 3:
        return _buildPasswordStep(c);
      case 4:
        return _buildSubmitDocsStep(c);
      case 5:
        return _buildScanIntroStep(c);
      case 6:
        return _buildCameraCaptureStep();
      case 7:
        return _buildSelfieStep(c);
      default:
        return _buildSuccessStep(c);
    }
  }

  Widget _buildIntro(AppColors c) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Get started in 3 easy\nsteps',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 24),
        const OrbitalBadgeIllustration(isSuccess: false, size: 195),
        const SizedBox(height: 28),
        _timelineRow(1, 'Create your account', showLine: true, c: c),
        _timelineRow(2, 'Submit document', showLine: true, c: c),
        _timelineRow(3, 'Selfie verification', showLine: false, c: c),
        const Spacer(),
        PrimaryButton(
          label: 'Continue',
          onPressed: () => setState(() => _step = 1),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _timelineRow(int num, String label,
      {required bool showLine, required AppColors c}) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$num',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (showLine)
                Container(width: 2, height: 26, color: AppColors.primaryBlue),
            ],
          ),
          const SizedBox(width: 14),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStep(AppColors c) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'What’s your email?',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enter the email address you want to use to register with coinmoney',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 26),
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
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Have an account? ',
                  style: TextStyle(color: c.textPrimary, fontSize: 15)),
              GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text(
                  'Log in here',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 44),
          PrimaryButton(
            label: 'Continue',
            enabled: _emailValid,
            onPressed: () => setState(() => _step = 2),
          ),
          const SizedBox(height: 28),
          Text(
            'By registering you accept our Terms & Conditions and Privacy Policy. Your data will be security encrypted with TLS',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(AppColors c) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Please enter the code',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent email to ${_emailCtrl.text.isEmpty ? "tomashuk.dima.1992@gmail.com" : _emailCtrl.text}',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _fillDemoOtp,
            child: Tooltip(
              message: 'Tap to fill demo OTP',
              child: Icon(
                _otpComplete ? Icons.drafts_outlined : Icons.mail_outlined,
                size: 54,
                color: const Color(0xFF5FAEE3),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              final hasVal = _otpCtrls[i].text.isNotEmpty;
              return SizedBox(
                width: 48,
                height: 54,
                child: TextField(
                  controller: _otpCtrls[i],
                  focusNode: _otpFocus[i],
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: hasVal ? AppColors.primaryBlue : c.border,
                        width: 1.4,
                      ),
                    ),
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) {
                      _otpFocus[i + 1].requestFocus();
                    } else if (v.isEmpty && i > 0) {
                      _otpFocus[i - 1].requestFocus();
                    }
                    setState(() {});
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Didn’t get a mail? ',
                  style: TextStyle(color: c.textPrimary, fontSize: 15)),
              GestureDetector(
                onTap: _fillDemoOtp,
                child: const Text(
                  'Send again',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Entered',
            enabled: _otpComplete,
            onPressed: () => setState(() => _step = 3),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep(AppColors c) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Create a password',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The password must be 8 characters, including 1 uppercase letter, 1 number and 1 special character.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Confirm password',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unlock with Touch ID?',
                style: TextStyle(color: c.textPrimary, fontSize: 15),
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
            label: 'Continue',
            enabled: _passValid,
            onPressed: () => setState(() => _step = 4),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitDocsStep(AppColors c) {
    final methods = [
      (Icons.badge_outlined, 'National ID Card'),
      (Icons.book_outlined, 'Passport'),
      (Icons.credit_card_outlined, 'Driver license'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          'Submit documents',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We are required by law to verify your identity by collecting your ID and selfie',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Text(
          'Enter your location',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: c.cardDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _location,
              isExpanded: true,
              dropdownColor: c.surface,
              items: const [
                DropdownMenuItem(value: 'Ukraine', child: Text('Ukraine')),
                DropdownMenuItem(value: 'Poland', child: Text('Poland')),
                DropdownMenuItem(value: 'United States', child: Text('United States')),
              ],
              selectedItemBuilder: (context) => ['Ukraine', 'Poland', 'United States']
                  .map(
                    (country) => Row(
                      children: [
                        const UkraineFlagCircle(size: 30),
                        const SizedBox(width: 14),
                        Text(
                          country,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _location = v);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Choose verification method',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(methods.length, (i) {
          final selected = _docMethod == i;
          return GestureDetector(
            onTap: () => setState(() => _docMethod = i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: c.cardDecoration(),
              child: Row(
                children: [
                  Icon(
                    methods[i].$1,
                    color: selected ? AppColors.primaryBlue : c.textSecondary,
                    size: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      methods[i].$2,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryBlue, width: 2),
                    ),
                    child: selected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
        const Spacer(),
        PrimaryButton(
          label: 'Continue',
          onPressed: () => setState(() => _step = 5),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildScanIntroStep(AppColors c) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Scan document',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Place the document in the frame until all 4 edges align around the document and turn blue',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 14),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          height: 195,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFB5E0F5).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primaryBlue, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 82,
                height: 108,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DCE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, size: 58, color: Color(0xFF6B7285)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    3,
                    (_) => Container(
                      height: 16,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6DCE5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        _encryptionNotice(c),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Open camera',
          onPressed: () => setState(() => _step = 6),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCameraCaptureStep() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Scan document',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Now hold the phone directly over the passport, when the frame turns blue, take the picture.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFA7CBF0),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primaryBlue, width: 2.5),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.badge, color: Color(0xFF566179), size: 30),
                  Text(
                    _location,
                    style: const TextStyle(
                      color: Color(0xFF0D1426),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const UkraineFlagCircle(size: 32),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 86,
                    height: 104,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.face, size: 54, color: Color(0xFF475569)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Surname', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                        Text('Tomashuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0D1426))),
                        SizedBox(height: 6),
                        Text('Name', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                        Text('Dmutro', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0D1426))),
                        SizedBox(height: 6),
                        Text('Patronymic', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                        Text('Olecksandrovuch', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0D1426))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _step = 7),
          child: Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSelfieStep(AppColors c) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Selfie verification',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We will compare the photo in your document with your selfie to confirm your identity',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 14),
        ),
        const Spacer(),
        const SelfieMeshIllustration(size: 210),
        const Spacer(),
        _encryptionNotice(c),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Open camera',
          onPressed: () => setState(() => _step = 8),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSuccessStep(AppColors c) {
    return Column(
      children: [
        const Spacer(),
        const OrbitalBadgeIllustration(isSuccess: true, size: 210),
        const SizedBox(height: 24),
        Text(
          'Verification Success',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Congratulations your account is ready to use, now you can start trading cryptocurrency',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 15),
        ),
        const SizedBox(height: 36),
        PrimaryButton(
          label: 'Start Now',
          onPressed: _finishToApp,
        ),
        const Spacer(),
      ],
    );
  }

  Widget _encryptionNotice(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.secondarySurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: c.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'The data you share will be encrypted, stored securely, and only used to verify your identity',
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
