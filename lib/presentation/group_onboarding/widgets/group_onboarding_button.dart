import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';

class GroupOnboardingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const GroupOnboardingButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusAll,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
