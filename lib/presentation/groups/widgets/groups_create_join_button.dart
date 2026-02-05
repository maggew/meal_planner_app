import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/presentation/common/extensions/text_theme_extensions.dart';

class GroupsCreateJoinButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  final String buttonText;
  final Color boxColor;
  const GroupsCreateJoinButton(
      {super.key,
      required this.onPressed,
      required this.iconData,
      required this.buttonText,
      required this.boxColor});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        height: 60,
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  color: Colors.black,
                  size: 40,
                ),
                Gap(10),
                Text(
                  buttonText,
                  style: textTheme.bodyMediumEmphasis,
                  overflow: TextOverflow.ellipsis,
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

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[100],
        disabledForegroundColor: Colors.green[100]!.withOpacity(0.38),
        disabledBackgroundColor: Colors.green[100]!.withOpacity(0.12),
        elevation: 10,
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [],
      ),
    );
  }
}
