import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/constants/categories.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/data/repositories/supabase_group_category_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'test_config.dart';

void main() {
  late SupabaseClient supabase;
  late SupabaseGroupCategoryRepository categoryRepo;
  final uuid = const Uuid();

  setUpAll(() async {
    supabase = SupabaseClient(
      TestConfig.supabaseUrl,
      TestConfig.supabaseKey,
    );
    categoryRepo = SupabaseGroupCategoryRepository(supabase: supabase);
  });

  group('Default-Kategorien beim Erstellen einer Gruppe', () {
    late String testGroupId;

    setUp(() async {
      testGroupId = uuid.v4();
      // Testgruppe direkt anlegen (ohne Member, da nur Kategorie-Logik getestet wird)
      await supabase.from(SupabaseConstants.groupsTable).insert({
        SupabaseConstants.groupId: testGroupId,
        SupabaseConstants.groupName: 'Testgruppe (Kategorien)',
        SupabaseConstants.groupImageUrl: '',
      });
    });

    tearDown(() async {
      await supabase
          .from(SupabaseConstants.categoriesTable)
          .delete()
          .eq(SupabaseConstants.categoryGroupId, testGroupId);
      await supabase
          .from(SupabaseConstants.groupsTable)
          .delete()
          .eq(SupabaseConstants.groupId, testGroupId);
    });

    /// Hilfsfunktion: simuliert den Loop aus CreateGroupCreateButton
    Future<void> _createDefaultCategories(String groupId) async {
      for (final name in defaultCategoryNames) {
        await categoryRepo.addCategory(
          groupId,
          name,
          iconName: defaultCategoryIcons[name],
        );
      }
    }

    test('erstellt genau ${defaultCategoryNames.length} Default-Kategorien',
        () async {
      await _createDefaultCategories(testGroupId);

      final categories = await categoryRepo.getCategories(testGroupId);

      expect(categories, hasLength(defaultCategoryNames.length));
    });

    test('Kategorien haben korrekte Namen aus defaultCategoryNames', () async {
      await _createDefaultCategories(testGroupId);

      final categories = await categoryRepo.getCategories(testGroupId);
      final names = categories.map((c) => c.name).toList();

      expect(names, equals(defaultCategoryNames));
    });

    test('sort_order wird korrekt inkrementiert (0 bis ${defaultCategoryNames.length - 1})',
        () async {
      await _createDefaultCategories(testGroupId);

      final categories = await categoryRepo.getCategories(testGroupId);
      final sortOrders = categories.map((c) => c.sortOrder).toList();

      expect(
        sortOrders,
        equals(List.generate(defaultCategoryNames.length, (i) => i)),
      );
    });

    test('jede Default-Kategorie hat den korrekten iconName gespeichert',
        () async {
      await _createDefaultCategories(testGroupId);

      final categories = await categoryRepo.getCategories(testGroupId);

      for (final cat in categories) {
        final expectedIcon = defaultCategoryIcons[cat.name];
        expect(
          cat.iconName,
          equals(expectedIcon),
          reason:
              'Kategorie "${cat.name}" sollte iconName "$expectedIcon" haben',
        );
      }
    });

    test('alle Kategorien sind der korrekten Gruppe zugeordnet', () async {
      await _createDefaultCategories(testGroupId);

      final categories = await categoryRepo.getCategories(testGroupId);

      expect(
        categories.every((c) => c.groupId == testGroupId),
        isTrue,
      );
    });

    test('getCategories gibt Kategorien aufsteigend nach sort_order zurück',
        () async {
      await _createDefaultCategories(testGroupId);

      final categories = await categoryRepo.getCategories(testGroupId);

      for (int i = 0; i < categories.length - 1; i++) {
        expect(
          categories[i].sortOrder,
          lessThan(categories[i + 1].sortOrder),
          reason:
              'Kategorie ${categories[i].name} (sort_order=${categories[i].sortOrder}) '
              'muss vor ${categories[i + 1].name} (sort_order=${categories[i + 1].sortOrder}) stehen',
        );
      }
    });

    test('jede Kategorie hat eine eindeutige nicht-leere ID', () async {
      await _createDefaultCategories(testGroupId);

      final categories = await categoryRepo.getCategories(testGroupId);
      final ids = categories.map((c) => c.id).toList();

      expect(ids.every((id) => id.isNotEmpty), isTrue);
      expect(ids.toSet().length, equals(ids.length),
          reason: 'Alle Kategorie-IDs müssen eindeutig sein');
    });

    test('addCategory gibt Entity mit korrekten Feldern zurück', () async {
      final result = await categoryRepo.addCategory(testGroupId, 'suppen');

      expect(result.groupId, equals(testGroupId));
      expect(result.name, equals('suppen'));
      expect(result.sortOrder, equals(0));
      expect(result.iconName, isNull);
      expect(result.id, isNotEmpty);
    });

    test('addCategory mit iconName speichert iconName korrekt', () async {
      const iconName = 'ice_cream_cone';
      await categoryRepo.addCategory(testGroupId, 'desserts',
          iconName: iconName);

      final categories = await categoryRepo.getCategories(testGroupId);
      expect(categories.single.iconName, equals(iconName));
    });

    test('Kategorien anderer Gruppen werden nicht beeinflusst', () async {
      final otherGroupId = uuid.v4();
      await supabase.from(SupabaseConstants.groupsTable).insert({
        SupabaseConstants.groupId: otherGroupId,
        SupabaseConstants.groupName: 'Andere Gruppe',
        SupabaseConstants.groupImageUrl: '',
      });

      try {
        await _createDefaultCategories(testGroupId);

        final otherCategories =
            await categoryRepo.getCategories(otherGroupId);
        expect(otherCategories, isEmpty,
            reason:
                'Andere Gruppe darf keine Kategorien von testGroupId erhalten');
      } finally {
        await supabase
            .from(SupabaseConstants.categoriesTable)
            .delete()
            .eq(SupabaseConstants.categoryGroupId, otherGroupId);
        await supabase
            .from(SupabaseConstants.groupsTable)
            .delete()
            .eq(SupabaseConstants.groupId, otherGroupId);
      }
    });

    test(
        'sort_order der nächsten Kategorie entspricht der aktuellen Anzahl vorhandener Kategorien',
        () async {
      // Erste Kategorie → sort_order = 0
      final first = await categoryRepo.addCategory(testGroupId, 'suppen');
      expect(first.sortOrder, equals(0));

      // Zweite Kategorie → sort_order = 1
      final second = await categoryRepo.addCategory(testGroupId, 'salate');
      expect(second.sortOrder, equals(1));

      // Dritte Kategorie → sort_order = 2
      final third = await categoryRepo.addCategory(testGroupId, 'desserts');
      expect(third.sortOrder, equals(2));
    });
  });
}
