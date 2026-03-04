import 'package:flutter/material.dart';

class CookingModeStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  static const int _maxVisibleSteps = 5;
  static const double _overflowLineWidth = 20.0;

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

    final useWindow = totalSteps > _maxVisibleSteps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          // For ≤5 steps: simple row, no sliding needed
          if (!useWindow) {
            return _buildSimpleRow(
              availableWidth: availableWidth,
              colorScheme: colorScheme,
              textTheme: textTheme,
            );
          }

          // For >5 steps: sliding window
          return _buildSlidingRow(
            availableWidth: availableWidth,
            colorScheme: colorScheme,
            textTheme: textTheme,
          );
        },
      ),
    );
  }

  /// Original layout for ≤5 steps
  Widget _buildSimpleRow({
    required double availableWidth,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    const maxCircleSize = 36.0;
    const minLineWidth = 12.0;
    final neededWidth =
        totalSteps * maxCircleSize + (totalSteps - 1) * minLineWidth;
    final circleSize = neededWidth > availableWidth
        ? ((availableWidth - (totalSteps - 1) * minLineWidth) / totalSteps)
            .clamp(28.0, maxCircleSize)
        : maxCircleSize;

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            return _buildStepCircle(
              stepIndex: stepIndex,
              circleSize: circleSize,
              colorScheme: colorScheme,
              textTheme: textTheme,
            );
          } else {
            final leftStepIndex = index ~/ 2;
            return Expanded(
              child: _buildLine(
                isCompleted: leftStepIndex < currentStep,
                colorScheme: colorScheme,
              ),
            );
          }
        }),
      ),
    );
  }

  /// Sliding window layout for >5 steps
  Widget _buildSlidingRow({
    required double availableWidth,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final windowStart = (currentStep - 2)
        .clamp(0, totalSteps - _maxVisibleSteps);
    final hasMoreLeft = windowStart > 0;
    final hasMoreRight = windowStart + _maxVisibleSteps < totalSteps;

    // Always reserve space for both overflow lines so layout doesn't shift
    final scrollAreaWidth = availableWidth - 2 * _overflowLineWidth;
    const maxCircleSize = 36.0;
    final circleWidth = maxCircleSize + 4; // fixed SizedBox per circle
    final lineWidth =
        (scrollAreaWidth - _maxVisibleSteps * circleWidth) /
        (_maxVisibleSteps - 1);

    // One "step unit" = circle + line (except last circle)
    final stepUnit = circleWidth + lineWidth;
    final scrollOffset = windowStart * stepUnit;

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          // Left overflow indicator
          SizedBox(
            width: _overflowLineWidth,
            child: AnimatedOpacity(
              opacity: hasMoreLeft ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: _buildLine(
                isCompleted: true,
                colorScheme: colorScheme,
              ),
            ),
          ),

          // Clipped sliding area
          Expanded(
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: scrollOffset),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: Offset(-offset, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < totalSteps; i++) ...[
                        if (i > 0)
                          SizedBox(
                            width: lineWidth,
                            child: _buildLine(
                              isCompleted: i - 1 < currentStep,
                              colorScheme: colorScheme,
                            ),
                          ),
                        _buildStepCircle(
                          stepIndex: i,
                          circleSize: maxCircleSize,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          fixedWidth: circleWidth,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right overflow indicator
          SizedBox(
            width: _overflowLineWidth,
            child: AnimatedOpacity(
              opacity: hasMoreRight ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: _buildLine(
                isCompleted: false,
                colorScheme: colorScheme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle({
    required int stepIndex,
    required double circleSize,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    double? fixedWidth,
  }) {
    final isActive = stepIndex == currentStep;
    final isCompleted = stepIndex < currentStep;

    final circle = AnimatedContainer(
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
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
    );

    final child = fixedWidth != null
        ? SizedBox(
            width: fixedWidth,
            height: circleSize + 4,
            child: Center(child: circle),
          )
        : circle;

    return GestureDetector(
      onTap: onStepTapped != null ? () => onStepTapped!(stepIndex) : null,
      child: child,
    );
  }

  Widget _buildLine({
    required bool isCompleted,
    required ColorScheme colorScheme,
  }) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: isCompleted ? 3 : 2,
        decoration: BoxDecoration(
          color: isCompleted
              ? colorScheme.primary.withAlpha(180)
              : colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
