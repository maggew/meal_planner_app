import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/constants.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/burger_menu/widgets/buger_menu_list.dart';
import 'package:meal_planner/presentation/common/burger_menu/widgets/burger_menu_header.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class BurgerMenu extends ConsumerWidget {
  const BurgerMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final Group? group = session.group;

    return Drawer(
      backgroundColor: Colors.lightGreen[100],
      elevation: 20,
      width: burgerMenuWidthPercentage * MediaQuery.of(context).size.width,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          BurgerMenuHeader(group: group),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                group == null ? 'Keine Gruppe' : group.name,
                style: const TextStyle(fontSize: 27.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ...getBurgerMenuItems(context, ref),
        ],
      ),
    );
  }
}
