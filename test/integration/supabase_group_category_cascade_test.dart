import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/data/repositories/supabase_group_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'test_config.dart';

void main() {
  late SupabaseClient supabase;
  late SupabaseGroupRepository repository;
  final uuid = const Uuid();

  setUpAll(() async {
    supabase = SupabaseClient(
      TestConfig.supabaseUrl,
      TestConfig.supabaseKey,
    );
    repository = SupabaseGroupRepository(supabase: supabase);
  });

  group('deleteGroup — Kategorien-Cascade', () {
    late String testGroupId;
    late String catId1;
    late String catId2;

    setUp(() async {
      testGroupId = uuid.v4();
      catId1 = uuid.v4();
      catId2 = uuid.v4();

      // Gruppe anlegen
      await supabase.from(SupabaseConstants.groupsTable).insert({
        SupabaseConstants.groupId: testGroupId,
        SupabaseConstants.groupName: 'Test Group (Cascade)',
        SupabaseConstants.groupImageUrl: 'https://example.com/img.png',
      });

      // 2 Kategorien für diese Gruppe anlegen
      await supabase.from(SupabaseConstants.categoriesTable).insert([
        {
          SupabaseConstants.categoryId: catId1,
          SupabaseConstants.categoryGroupId: testGroupId,
          SupabaseConstants.categoryName: 'Suppen',
          SupabaseConstants.categorySortOrder: 0,
        },
        {
          SupabaseConstants.categoryId: catId2,
          SupabaseConstants.categoryGroupId: testGroupId,
          SupabaseConstants.categoryName: 'Salate',
          SupabaseConstants.categorySortOrder: 1,
        },
      ]);
    });

    tearDown(() async {
      // Aufräumen falls ein Test fehlschlägt bevor deleteGroup aufgerufen wurde
      await supabase
          .from(SupabaseConstants.categoriesTable)
          .delete()
          .eq(SupabaseConstants.categoryGroupId, testGroupId);
      await supabase
          .from(SupabaseConstants.groupMembersTable)
          .delete()
          .eq(SupabaseConstants.memberGroupId, testGroupId);
      await supabase
          .from(SupabaseConstants.groupsTable)
          .delete()
          .eq(SupabaseConstants.groupId, testGroupId);
    });

    test('löscht die Gruppe selbst', () async {
      await repository.deleteGroup(testGroupId);

      final result = await supabase
          .from(SupabaseConstants.groupsTable)
          .select()
          .eq(SupabaseConstants.groupId, testGroupId);

      expect(result as List, isEmpty);
    });

    test('löscht alle Kategorien der Gruppe via ON DELETE CASCADE', () async {
      // Sicherstellen dass Kategorien vor dem Löschen existieren
      final before = await supabase
          .from(SupabaseConstants.categoriesTable)
          .select()
          .eq(SupabaseConstants.categoryGroupId, testGroupId);
      expect(before as List, hasLength(2),
          reason: 'Vorbedingung: 2 Kategorien vorhanden');

      await repository.deleteGroup(testGroupId);

      final after = await supabase
          .from(SupabaseConstants.categoriesTable)
          .select()
          .eq(SupabaseConstants.categoryGroupId, testGroupId);

      expect(after as List, isEmpty,
          reason:
              'Kategorien müssen per ON DELETE CASCADE mitgelöscht werden wenn die Gruppe gelöscht wird');
    });

    test('löscht nur Kategorien der gelöschten Gruppe, nicht anderer Gruppen',
        () async {
      // Zweite Gruppe mit eigener Kategorie
      final otherGroupId = uuid.v4();
      final otherCatId = uuid.v4();

      await supabase.from(SupabaseConstants.groupsTable).insert({
        SupabaseConstants.groupId: otherGroupId,
        SupabaseConstants.groupName: 'Andere Gruppe',
        SupabaseConstants.groupImageUrl: 'https://example.com/img.png',
      });
      await supabase.from(SupabaseConstants.categoriesTable).insert({
        SupabaseConstants.categoryId: otherCatId,
        SupabaseConstants.categoryGroupId: otherGroupId,
        SupabaseConstants.categoryName: 'Desserts',
        SupabaseConstants.categorySortOrder: 0,
      });

      // Nur die erste Gruppe löschen
      await repository.deleteGroup(testGroupId);

      // Kategorie der anderen Gruppe muss noch vorhanden sein
      final otherCats = await supabase
          .from(SupabaseConstants.categoriesTable)
          .select()
          .eq(SupabaseConstants.categoryGroupId, otherGroupId);

      expect(otherCats as List, hasLength(1),
          reason: 'Kategorien anderer Gruppen dürfen nicht betroffen sein');

      // Aufräumen
      await supabase
          .from(SupabaseConstants.categoriesTable)
          .delete()
          .eq(SupabaseConstants.categoryGroupId, otherGroupId);
      await supabase
          .from(SupabaseConstants.groupsTable)
          .delete()
          .eq(SupabaseConstants.groupId, otherGroupId);
    });
  });
}
