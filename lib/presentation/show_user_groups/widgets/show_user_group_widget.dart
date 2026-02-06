import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/extensions/text_theme_extensions.dart';
import 'package:meal_planner/presentation/show_user_groups/widgets/show_user_group_avatar.dart';

class ShowUserGroupWidget extends StatelessWidget {
  final Group group;
  final bool isCurrentGroup;
  const ShowUserGroupWidget({
    super.key,
    required this.group,
    required this.isCurrentGroup,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        ShowUserGroupAvatar(group: group, isCurrentGroup: isCurrentGroup),
        Gap(10),
        GestureDetector(
          onLongPress: () async {
            await Clipboard.setData(ClipboardData(text: group.id));
            HapticFeedback.mediumImpact();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Gruppen-Id kopiert: \n${group.id}"),
                duration: Duration(seconds: 2),
              ));
            }
          },
          child: Text(group.name, style: textTheme.bodyLargeClickable),
        ),
      ],
    );
  }
}
