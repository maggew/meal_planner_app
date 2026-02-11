import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/user/user_groups_provider.dart';

class ProfileGroupsList extends ConsumerWidget {
  const ProfileGroupsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGroupsAsync = ref.watch(userGroupsProvider);
    return Container(
      constraints: BoxConstraints(minWidth: 50, minHeight: 50, maxWidth: 300),
      child: userGroupsAsync.when(
        data: (groups) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              border: Border.all(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 15,
              children: groups
                  .map((group) => GestureDetector(
                        onTap: () {
                          print("${group.name} pressed....");
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Routing fehlt")));
                        },
                        child: SizedBox(
                          height: 50,
                          child: Card(
                            color: Colors.red,
                            child: Center(child: Text(group.name)),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Fehler: $e'),
      ),
    );
  }
}
