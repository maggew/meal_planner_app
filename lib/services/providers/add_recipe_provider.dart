import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_planner/model/enums/unit.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => "Suppen");

final selectedPortionsProvider = StateProvider<int>((ref) => 4);

final selectedUnitProvider = StateProvider<Unit>((ref) => Unit.GRAMM);
