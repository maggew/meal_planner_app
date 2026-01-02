import 'package:flutter/material.dart';

class ShowUserErrorpage extends StatelessWidget {
  final Object? error;
  const ShowUserErrorpage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outlined, size: 48, color: Colors.red),
          const SizedBox(height: 26),
          Text("Fehler beim Laden der Gruppen"),
          const SizedBox(height: 8),
          Text(
            "$error",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
