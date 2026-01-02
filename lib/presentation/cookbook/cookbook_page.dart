import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_appbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_body.dart';

@RoutePage()
class CookbookPage extends StatelessWidget {
  const CookbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CookbookAppbar(),
      scaffoldBody: CookbookBody(),
    );
  }
}
