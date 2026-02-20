import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/burger_menu/widgets/buger_menu_list.dart';
import 'package:meal_planner/presentation/common/burger_menu/widgets/burger_menu_header.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class BurgerMenu extends ConsumerWidget {
  const BurgerMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final Group? group = session.group;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Drawer(
      elevation: 20,
      width: AppDimensions.burgerMenuWidthPercentage *
          MediaQuery.of(context).size.width,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          BurgerMenuHeader(group: group),
          GestureDetector(
            onTap: () {
              context.router.push(ShowSingleGroupRoute(group: group!));
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Text(
                group == null ? 'Keine Gruppe' : group.name,
                style: textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
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
