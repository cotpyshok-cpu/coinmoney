import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coinmoney_logo.dart';
import '../../widgets/illustrations/app_illustrations.dart';
import '../../widgets/primary_button.dart';
import 'welcome_screen.dart';

/// 3-page Onboarding flow matching Onboarding 1, 2, and 3 Figma screens.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Take hold of your\nfinances',
      subtitle:
          'Track your portfolio in real time, monitor market movers, and grow your crypto wealth effortlessly.',
      showHeaderLogo: false,
    ),
    _OnboardingSlide(
      title: 'Smart trading tools',
      subtitle:
          'Analyze candlestick trends, technical indicators, and live order books with fast spot execution.',
      showHeaderLogo: true,
    ),
    _OnboardingSlide(
      title: 'Invest in the future',
      subtitle:
          'Buy, sell, exchange, and withdraw digital assets securely from one unified Coinmoney wallet.',
      showHeaderLogo: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _openWelcome();
    }
  }

  void _openWelcome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: WaveBackgroundPainter(
                color: AppColors.primaryBlue.withValues(alpha: c.isDark ? 0.14 : 0.10),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_slides[_currentPage].showHeaderLogo)
                        const CoinmoneyLogo(iconSize: 24, fontSize: 20),
                      Positioned(
                        right: 16,
                        child: TextButton(
                          onPressed: _openWelcome,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OnboardingIllustration(pageIndex: index),
                            const SizedBox(height: 24),
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              slide.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final active = i == _currentPage;
                    return GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 12,
                        height: 4,
                        decoration: BoxDecoration(
                          color: active ? AppColors.primaryBlue : c.textMuted,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  child: PrimaryButton(
                    label: _currentPage == _slides.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _goNext,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.showHeaderLogo,
  });

  final String title;
  final String subtitle;
  final bool showHeaderLogo;
}
