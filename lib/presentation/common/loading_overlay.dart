import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final double height;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
