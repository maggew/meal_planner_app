import 'package:flutter/material.dart';

class SettingsRowWidget extends StatelessWidget {
  final String label;
  final Widget controlWidget;
  const SettingsRowWidget(
      {super.key, required this.label, required this.controlWidget});

  @override
  Widget build(BuildContext context) {
    final Color color = Colors.red;
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(label),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: color),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: controlWidget),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: color),
      ],
    );
  }
}
