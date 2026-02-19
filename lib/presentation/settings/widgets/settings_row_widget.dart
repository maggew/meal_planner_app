import 'package:flutter/material.dart';

class SettingsRowWidget extends StatelessWidget {
  final String label;
  final Widget controlWidget;
  const SettingsRowWidget(
      {super.key, required this.label, required this.controlWidget});

  @override
  Widget build(BuildContext context) {
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
              VerticalDivider(thickness: 1.5),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: Center(child: controlWidget),
                ),
              ),
            ],
          ),
        ),
        Divider(thickness: 1.5),
      ],
    );
  }
}
