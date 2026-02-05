import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class GroupsListviewItem extends ConsumerWidget {
  final Group group;
  final Color color;
  final ValueChanged<bool> onLoadingChanged;
  const GroupsListviewItem({
    super.key,
    required this.group,
    required this.color,
    required this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final imageWidget = (group.imageUrl.isEmpty ||
            group.imageUrl == 'assets/images/group_pic.jpg')
        ? Image.asset('assets/images/group_pic.jpg', fit: BoxFit.cover)
        : Image.network(group.imageUrl, fit: BoxFit.cover);
    return GestureDetector(
      onTap: () async {
        onLoadingChanged(true);

        final session = ref.read(sessionProvider.notifier);
        await session.joinGroup(group.id);
        context.router.push(const CookbookRoute());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageWidget,
                ),
                Gap(10),
                Text(
                  group.name,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.chevron_right),
            )
          ],
        ),
      ),
    );
  }
}
