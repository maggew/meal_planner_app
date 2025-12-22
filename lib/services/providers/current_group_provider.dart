import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/database.dart';

final currentGroupProvider = FutureProvider<dynamic>((ref) async {
  return Database().getCurrentGroup();
});
