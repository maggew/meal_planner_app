import 'package:flutter/material.dart';

class CookingModeStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  const CookingModeStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxCircleSize = 36.0;
          final minCircleSize = 28.0;
          final minLineWidth = 12.0;
          final availableWidth = constraints.maxWidth;
          final neededWidth =
              totalSteps * maxCircleSize + (totalSteps - 1) * minLineWidth;
          final circleSize = neededWidth > availableWidth
              ? (availableWidth - (totalSteps - 1) * minLineWidth) /
                  totalSteps.clamp(minCircleSize, maxCircleSize)
              : maxCircleSize;

          return SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalSteps * 2 - 1, (index) {
                // Even indices = circles, odd indices = lines
                if (index.isEven) {
                  final stepIndex = index ~/ 2;
                  final isActive = stepIndex == currentStep;
                  final isCompleted = stepIndex < currentStep;

                  return GestureDetector(
                    onTap: onStepTapped != null
                        ? () => onStepTapped!(stepIndex)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: isActive ? circleSize + 4 : circleSize,
                      height: isActive ? circleSize + 4 : circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? colorScheme.primary
                            : isCompleted
                                ? colorScheme.primary.withAlpha(180)
                                : colorScheme.surfaceContainerHighest,
                        border: isActive
                            ? Border.all(
                                color: colorScheme.primary.withAlpha(80),
                                width: 3,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              size: circleSize * 0.5,
                              color: colorScheme.onPrimary,
                            )
                          : Text(
                              '${stepIndex + 1}',
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isActive
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  );
                } else {
                  // Connecting line
                  final leftStepIndex = index ~/ 2;
                  final isCompletedLine = leftStepIndex < currentStep;

                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: isCompletedLine ? 3 : 2,
                      decoration: BoxDecoration(
                        color: isCompletedLine
                            ? colorScheme.primary.withAlpha(180)
                            : colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  );
                }
              }),
            ),
          );
        },
      ),
    );
  }
}
