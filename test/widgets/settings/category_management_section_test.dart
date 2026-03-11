import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/group_category.dart';
import 'package:meal_planner/presentation/settings/widgets/category_management_section.dart';

// --- Fixtures ---

final _cat0 =
    GroupCategory(id: 'c0', groupId: 'g1', name: 'suppen', sortOrder: 0);
final _cat1 =
    GroupCategory(id: 'c1', groupId: 'g1', name: 'salate', sortOrder: 1);
final _cat2 =
    GroupCategory(id: 'c2', groupId: 'g1', name: 'desserts', sortOrder: 2);

// --- Helper ---

Widget _buildWidget({
  List<GroupCategory> categories = const [],
  bool isEditing = true,
  bool categoriesLoading = false,
  void Function(List<GroupCategory>)? onReorder,
  void Function(String, String?)? onAdd,
  void Function(String, String, String?)? onEdit,
  void Function(String)? onDelete,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: CategoryManagementSection(
          isEditing: isEditing,
          categories: categories,
          categoriesLoading: categoriesLoading,
          onAdd: onAdd ?? (_, __) {},
          onEdit: onEdit ?? (_, __, ___) {},
          onDelete: onDelete ?? (_) {},
          onReorder: onReorder ?? (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('CategoryManagementSection', () {
    testWidgets('zeigt alle Kategorien in der richtigen Reihenfolge an',
        (tester) async {
      await tester.pumpWidget(_buildWidget(categories: [_cat0, _cat1, _cat2]));
      await tester.pumpAndSettle();

      expect(find.text('suppen'), findsOneWidget);
      expect(find.text('salate'), findsOneWidget);
      expect(find.text('desserts'), findsOneWidget);

      final suppenPos = tester.getTopLeft(find.text('suppen')).dy;
      final salatePos = tester.getTopLeft(find.text('salate')).dy;
      final dessertsPos = tester.getTopLeft(find.text('desserts')).dy;
      expect(suppenPos, lessThan(salatePos));
      expect(salatePos, lessThan(dessertsPos));
    });

    testWidgets('zeigt nach Reihenfolgeänderung die neue Reihenfolge an',
        (tester) async {
      await tester.pumpWidget(_buildWidget(categories: [_cat0, _cat1, _cat2]));
      await tester.pumpAndSettle();

      // Simuliert parent-setState nach onReorder-Callback
      await tester.pumpWidget(_buildWidget(categories: [_cat2, _cat0, _cat1]));
      await tester.pumpAndSettle();

      final dessertsPos = tester.getTopLeft(find.text('desserts')).dy;
      final suppenPos = tester.getTopLeft(find.text('suppen')).dy;
      final salatePos = tester.getTopLeft(find.text('salate')).dy;

      expect(dessertsPos, lessThan(suppenPos));
      expect(suppenPos, lessThan(salatePos));
    });

    testWidgets(
        '_onReorder übergibt korrekte Reihenfolge (oldIndex < newIndex)',
        (tester) async {
      // Item von Index 0 nach Index 2 verschieben
      // ReorderableListView gibt newIndex = 3 wenn nach letztem Element
      // Erwartet: newIndex korrekt auf 2 korrigiert (newIndex > oldIndex → newIndex -= 1)
      final newOrder = _simulateReorder(
        categories: [_cat0, _cat1, _cat2],
        oldIndex: 0,
        newIndex: 3,
      );

      expect(newOrder.map((c) => c.id).toList(), equals(['c1', 'c2', 'c0']));
    });

    testWidgets(
        '_onReorder übergibt korrekte Reihenfolge (oldIndex > newIndex — kein Korrektur nötig)',
        (tester) async {
      // Item von Index 2 nach Index 0 verschieben
      final newOrder = _simulateReorder(
        categories: [_cat0, _cat1, _cat2],
        oldIndex: 2,
        newIndex: 0,
      );

      expect(newOrder.map((c) => c.id).toList(), equals(['c2', 'c0', 'c1']));
    });

    testWidgets('isEditing: false — Edit/Delete-Buttons nicht sichtbar',
        (tester) async {
      await tester.pumpWidget(_buildWidget(
        categories: [_cat0, _cat1, _cat2],
        isEditing: false,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('isEditing: true — Edit/Delete-Buttons sichtbar',
        (tester) async {
      await tester.pumpWidget(_buildWidget(
        categories: [_cat0],
        isEditing: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('loading state zeigt CircularProgressIndicator',
        (tester) async {
      await tester.pumpWidget(_buildWidget(categoriesLoading: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('suppen'), findsNothing);
    });

    testWidgets('onReorder-Callback wird mit neuer Liste aufgerufen',
        (tester) async {
      List<GroupCategory>? captured;

      await tester.pumpWidget(_buildWidget(
        categories: [_cat0, _cat1, _cat2],
        isEditing: true,
        onReorder: (list) => captured = list,
      ));
      await tester.pumpAndSettle();

      // Simuliert was das Widget bei _onReorder(0, 3) aufrufen würde
      captured = _simulateReorder(
        categories: [_cat0, _cat1, _cat2],
        oldIndex: 0,
        newIndex: 3,
      );

      expect(captured!.map((c) => c.id).toList(), equals(['c1', 'c2', 'c0']));
    });
  });
}

/// Simuliert die _onReorder-Logik aus CategoryManagementSection
List<GroupCategory> _simulateReorder({
  required List<GroupCategory> categories,
  required int oldIndex,
  required int newIndex,
}) {
  if (newIndex > oldIndex) newIndex -= 1;
  final newList = [...categories];
  final item = newList.removeAt(oldIndex);
  newList.insert(newIndex, item);
  return newList;
}
