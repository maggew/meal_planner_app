import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/native_ad_widget.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_day_card.dart';

class WeekplanWeekList extends StatelessWidget {
  final DateTime weekStart;
  final List<GlobalKey> dayKeys;

  const WeekplanWeekList({
    super.key,
    required this.weekStart,
    required this.dayKeys,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    return Column(
      children: [
        for (int i = 0; i < days.length; i++) ...[
          WeekplanDayCard(
            key: dayKeys[i],
            date: days[i],
          ),
          // Ad after every 2nd day (after Tue, Thu, Sat → index 1, 3, 5)
          if (i % 2 == 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: NativeAdWidget(),
            ),
        ],
      ],
    );
  }
}
