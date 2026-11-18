import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Horizontal 1 — 2 — 3 circular progress indicator used in auth & KYC flows.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    this.progress = 0.0,
  });

  /// Current active step (1, 2, or 3).
  final int currentStep;

  /// Optional sub-step fill (0.0 to 1.0) on the connector after [currentStep].
  final double progress;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _circle(1, c),
        _connector(
          filled: currentStep > 1 ? 1.0 : (currentStep == 1 ? progress : 0.0),
          c: c,
        ),
        _circle(2, c),
        _connector(
          filled: currentStep > 2 ? 1.0 : (currentStep == 2 ? progress : 0.0),
          c: c,
        ),
        _circle(3, c),
      ],
    );
  }

  Widget _circle(int step, AppColors c) {
    final isCompleted = step < currentStep;
    final isActive = step == currentStep;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? AppColors.primaryBlue : c.surface,
        border: Border.all(
          color: (isCompleted || isActive) ? AppColors.primaryBlue : c.border,
          width: 1.8,
        ),
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isCompleted
                ? Colors.white
                : (isActive ? AppColors.primaryBlue : c.textMuted),
          ),
        ),
      ),
    );
  }

  Widget _connector({required double filled, required AppColors c}) {
    return SizedBox(
      width: 54,
      height: 2,
      child: Stack(
        children: [
          Container(color: c.border),
          FractionallySizedBox(
            widthFactor: filled.clamp(0.0, 1.0),
            child: Container(color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }
}
