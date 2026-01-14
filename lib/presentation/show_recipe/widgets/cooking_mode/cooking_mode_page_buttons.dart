import 'package:flutter/material.dart';

class CookingModePageButtons extends StatelessWidget {
  final TabController tabController;
  const CookingModePageButtons({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          ElevatedButton(
              onPressed: () {
                (tabController.index > 0)
                    ? tabController.index--
                    : print("first page!");
              },
              child: Row(
                spacing: 10,
                children: [
                  Icon(Icons.arrow_back_outlined),
                  Text("Links"),
                ],
              )),
          ElevatedButton(
            onPressed: () {
              (tabController.index < tabController.length - 1)
                  ? tabController.index++
                  : print("last page!");
            },
            child: Row(
              spacing: 10,
              children: [
                Text("Rechts"),
                Icon(Icons.arrow_forward_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
