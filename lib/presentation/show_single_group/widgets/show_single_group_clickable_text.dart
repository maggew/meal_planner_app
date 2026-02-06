import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/extensions/text_theme_extensions.dart';

class ShowSingleGroupClickableText extends StatelessWidget {
  final Group group;
  const ShowSingleGroupClickableText({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
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
      child: Text(
        "${group.name}\n${group.id}",
        style: textTheme.bodyLargeClickable,
        textAlign: TextAlign.center,
      ),
    );
  }
}
