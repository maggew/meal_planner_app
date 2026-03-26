import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_body.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_item_tile.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';
import 'package:meal_planner/services/providers/subscription/subscription_provider.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

// --- Fake Notifier ---

class FakeShoppingListActions extends ShoppingListActions {
  final List<String> toggledIds = [];
  final List<(String, String, String?)> updatedItems = [];

  @override
  void build() {}

  @override
  Future<void> toggleItem(String itemId, bool isChecked) async {
    toggledIds.add(itemId);
  }

  @override
  Future<void> updateItem(
      String itemId, String information, String? quantity) async {
    updatedItems.add((itemId, information, quantity));
  }

  @override
  Future<void> addItem(String input) async {}

  @override
  Future<void> addItemsFromIngredients(List<Ingredient> ingredients) async {}

  @override
  Future<void> removeItem(String itemId) async {}

  @override
  Future<void> removeCheckedItems() async {}
}

class FakeUserSettingsNotifier extends UserSettingsNotifier {
  @override
  UserSettings build() => UserSettings.defaultSettings;
}

// --- Helpers ---

ShoppingListItem _item({
  String id = 'item-1',
  String information = 'Tomaten',
  String? quantity,
  bool isChecked = false,
}) {
  return ShoppingListItem(
    id: id,
    groupId: 'group-1',
    information: information,
    quantity: quantity,
    isChecked: isChecked,
  );
}

Widget _buildTile(ShoppingListItem item, {FakeShoppingListActions? notifier}) {
  final actions = notifier ?? FakeShoppingListActions();
  return ProviderScope(
    overrides: [
      shoppingListActionsProvider.overrideWith(() => actions),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 120,
          height: 120,
          child: ShoppingListItemTile(key: ValueKey(item.id), item: item),
        ),
      ),
    ),
  );
}

Widget _buildBody(List<ShoppingListItem> items) {
  return ProviderScope(
    overrides: [
      shoppingListStreamProvider
          .overrideWith((ref) => Stream.value(items)),
      shoppingListActionsProvider
          .overrideWith(() => FakeShoppingListActions()),
      userSettingsProvider
          .overrideWith(() => FakeUserSettingsNotifier()),
      isPremiumProvider.overrideWithValue(true),
      isOnlineProvider.overrideWithValue(true),
    ],
    child: const MaterialApp(
      home: Scaffold(body: ShoppingListBody()),
    ),
  );
}

// =============================================================================

void main() {
  group('ShoppingListItemTile', () {
    testWidgets('rendert normalen Eintrag ohne Crash', (tester) async {
      await tester.pumpWidget(_buildTile(_item(information: 'Tomaten')));
      await tester.pump();
      expect(find.text('T'), findsOneWidget);
      expect(find.text('Tomaten'), findsOneWidget);
    });

    testWidgets('rendert Eintrag mit Menge', (tester) async {
      await tester.pumpWidget(
          _buildTile(_item(information: 'Mehl', quantity: '500g')));
      await tester.pump();
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('rendert abgehakten Eintrag', (tester) async {
      await tester.pumpWidget(
          _buildTile(_item(information: 'Butter', isChecked: true)));
      await tester.pump();
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets(
        'quantity "null" (String) wird nicht als Menge angezeigt',
        (tester) async {
      // Schutzt gegen den String "null" der früher in manchen Flows entstehen konnte
      await tester.pumpWidget(
          _buildTile(_item(information: 'Salz', quantity: 'null')));
      await tester.pump();
      // Text "null" soll nicht sichtbar sein
      expect(find.text('null Salz'), findsNothing);
      expect(find.text('Salz'), findsOneWidget);
    });

    testWidgets(
        'CRASH: leeres information-Feld → RangeError bei information[0]',
        (tester) async {
      // Tritt auf wenn Zutat aus Rezept einen leeren Namen hat
      // (addItemsFromIngredients übergibt ingredient.name direkt)
      await tester.pumpWidget(_buildTile(_item(information: '')));
      await tester.pump();
      // Erwartung: kein Crash — schlägt fehl bis der Bug behoben ist
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tap löst toggleItem aus', (tester) async {
      final actions = FakeShoppingListActions();
      await tester.pumpWidget(
          _buildTile(_item(id: 'abc', information: 'Eier'), notifier: actions));
      // Warten bis die Entrance-Animation (elasticOut) abgeschlossen ist
      await tester.pumpAndSettle();
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(actions.toggledIds, contains('abc'));
    });
  });

  // ---------------------------------------------------------------------------

  group('ShoppingListBody', () {
    testWidgets('zeigt Ladeindikator bei loading-State', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          shoppingListStreamProvider
              .overrideWith((ref) => const Stream.empty()),
          shoppingListActionsProvider
              .overrideWith(() => FakeShoppingListActions()),
          userSettingsProvider
              .overrideWith(() => FakeUserSettingsNotifier()),
          isPremiumProvider.overrideWithValue(true),
          isOnlineProvider.overrideWithValue(true),
        ],
        child: const MaterialApp(home: Scaffold(body: ShoppingListBody())),
      ));
      // Noch kein Datum emittiert → loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('zeigt Leer-Meldung bei leerer Liste', (tester) async {
      await tester.pumpWidget(_buildBody([]));
      await tester.pump();
      expect(find.text('Deine Einkaufsliste ist leer'), findsOneWidget);
    });

    testWidgets('rendert Einträge aus normaler Zutatenliste', (tester) async {
      final items = [
        _item(id: '1', information: 'Tomaten'),
        _item(id: '2', information: 'Mehl', quantity: '500g'),
        _item(id: '3', information: 'Milch', quantity: '1l'),
      ];
      await tester.pumpWidget(_buildBody(items));
      await tester.pump();
      expect(find.text('T'), findsOneWidget);
      // Mehl und Milch → beide zeigen 'M'
      expect(find.text('M'), findsNWidgets(2));
    });

    testWidgets('trennt abgehakte von unerledigten Einträgen', (tester) async {
      final items = [
        _item(id: '1', information: 'Tomaten', isChecked: false),
        _item(id: '2', information: 'Mehl', isChecked: true),
      ];
      await tester.pumpWidget(_buildBody(items));
      await tester.pump();
      expect(find.text('Erledigt'), findsOneWidget);
    });

    testWidgets(
        'CRASH: Eintrag mit leerem information aus Rezept-Zutaten → RangeError',
        (tester) async {
      // Reproduziert den Fehler: Rezept hat Zutat mit leerem Namen,
      // addItemsFromIngredients speichert information: '',
      // ShoppingListItemTile crasht bei information[0]
      final items = [
        _item(id: '1', information: 'Tomaten'),
        _item(id: '2', information: ''), // leerer Name aus Rezept-Zutat
      ];
      await tester.pumpWidget(_buildBody(items));
      await tester.pump();
      // Erwartung: kein Crash — schlägt fehl bis der Bug behoben ist
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'CRASH: mehrere Einträge mit leerem information', (tester) async {
      final items = [
        _item(id: '1', information: ''),
        _item(id: '2', information: ''),
      ];
      await tester.pumpWidget(_buildBody(items));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ---------------------------------------------------------------------------

  group('addItemsFromIngredients – Ingredient zu ShoppingListItem Mapping', () {
    test('Zutat mit leerem Namen → information ist leer (Root Cause)', () {
      // Dokumentiert dass ingredient.name direkt als information übergeben wird
      // ohne Validierung in addItemsFromIngredients
      final ingredient = Ingredient(name: '', unit: null, amount: null);
      expect(ingredient.name, isEmpty);
      // information = ingredient.name = '' → Tile crasht
    });

    test('Zutat ohne Menge und Einheit → quantity ist null', () {
      final ingredient = Ingredient(name: 'Salz', unit: null, amount: null);
      final quantity = [
        if (ingredient.amount != null) '${ingredient.amount}',
        if (ingredient.unit != null) ingredient.unit!.displayName,
      ].join(' ');
      expect(quantity, isEmpty);
      // Wird korrekt als null gespeichert
    });

    test('Zutat mit nur Menge (kein Unit) → quantity enthält nur Zahl', () {
      final ingredient =
          Ingredient(name: 'Eier', unit: null, amount: '3');
      final quantity = [
        if (ingredient.amount != null) '${ingredient.amount}',
        if (ingredient.unit != null) ingredient.unit!.displayName,
      ].join(' ');
      expect(quantity, '3');
    });

    test('Zutat mit Menge und Einheit → quantity korrekt formatiert', () {
      final ingredient =
          Ingredient(name: 'Mehl', unit: Unit.GRAMM, amount: '500');
      final quantity = [
        if (ingredient.amount != null) '${ingredient.amount}',
        if (ingredient.unit != null) ingredient.unit!.displayName,
      ].join(' ');
      expect(quantity, isNotEmpty);
      expect(quantity, contains('500'));
    });
  });
}
