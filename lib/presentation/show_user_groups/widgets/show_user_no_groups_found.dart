import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

class ShowUserNoGroupsFound extends StatelessWidget {
  const ShowUserNoGroupsFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Keine Gruppen vorhanden',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Erstelle oder trete einer Gruppe bei',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.router.push(const GroupsRoute());
            },
            icon: const Icon(AppIcons.plus_1),
            label: const Text('Gruppe erstellen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
