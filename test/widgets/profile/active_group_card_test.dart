import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/repositories/group_repository.dart';
import 'package:meal_planner/presentation/profile/widgets/active_group_card.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_groups_list.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/active_group_members_provider.dart';
import 'package:meal_planner/services/providers/user/user_groups_provider.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---

class MockGroupRepository extends Mock implements GroupRepository {}

class FakeSessionNotifier extends StateNotifier<SessionState>
    implements SessionController {
  FakeSessionNotifier(super.state);

  @override
  Future<void> loadSession(String userId) async {}

  @override
  Future<void> joinGroup(String groupId) async {}

  @override
  Future<void> setActiveGroup(String groupId) async {}

  @override
  Future<void> reloadActiveGroup() async {}

  @override
  void setActiveUserAfterRegistration(String userId) {}

  @override
  Future<void> changeSettings(UserSettings settings) async {}

  @override
  Future<void> clearSession() async {}

  @override
  // ignore: must_be_immutable
  Ref get ref => throw UnimplementedError();
}

// --- Fixtures ---

final _testGroup = Group(id: 'g1', name: 'Familiengruppe', imageUrl: '');
final _testMembers = [
  User(id: 'u1', name: 'Alice', imageUrl: null),
  User(id: 'u2', name: 'Bob', imageUrl: null),
];

// --- Tests ---

void main() {
  group('ActiveGroupCard', () {
    testWidgets('zeigt nichts wenn kein groupId in Session', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeGroupProvider.overrideWith((ref) async => null),
            activeGroupMembersProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ActiveGroupCard()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aktive Gruppe'), findsNothing);
    });

    testWidgets('zeigt Gruppe wenn activeGroupProvider Daten liefert',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeGroupProvider.overrideWith((ref) async => _testGroup),
            activeGroupMembersProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ActiveGroupCard()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aktive Gruppe'), findsOneWidget);
      expect(find.text('Familiengruppe'), findsOneWidget);
    });

    testWidgets(
        'Bug-Szenario: session.group null, groupId gesetzt → fetcht via Repo',
        (tester) async {
      final mockRepo = MockGroupRepository();
      when(() => mockRepo.getGroup('g1')).thenAnswer((_) async => _testGroup);
      when(() => mockRepo.getGroupMembers('g1'))
          .thenAnswer((_) async => _testMembers);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(
              (ref) => FakeSessionNotifier(
                const SessionState(userId: 'u1', groupId: 'g1', group: null),
              ),
            ),
            groupRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ActiveGroupCard()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aktive Gruppe'), findsOneWidget);
      expect(find.text('Familiengruppe'), findsOneWidget);
    });

    testWidgets('zeigt Mitglieder mit Namen an', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeGroupProvider.overrideWith((ref) async => _testGroup),
            activeGroupMembersProvider
                .overrideWith((ref) async => _testMembers),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ActiveGroupCard()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mitglieder'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('zeigt keinen Mitglieder-Abschnitt wenn Liste leer',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeGroupProvider.overrideWith((ref) async => _testGroup),
            activeGroupMembersProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ActiveGroupCard()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mitglieder'), findsNothing);
    });

    testWidgets('zeigt Initiale wenn Mitglied kein Bild hat', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeGroupProvider.overrideWith((ref) async => _testGroup),
            activeGroupMembersProvider.overrideWith(
              (ref) async => [User(id: 'u1', name: 'Alice')],
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ActiveGroupCard()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
    });
  });

  group('ProfileGroupsList', () {
    final groupA = Group(id: 'g1', name: 'Gruppe A', imageUrl: '');
    final groupB = Group(id: 'g2', name: 'Gruppe B', imageUrl: '');

    testWidgets('zeigt alle Gruppen an', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userGroupsProvider.overrideWith((ref) async => [groupA, groupB]),
            sessionProvider.overrideWith(
              (ref) => FakeSessionNotifier(
                const SessionState(userId: 'u1', groupId: 'g1'),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ProfileGroupsList()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gruppe A'), findsOneWidget);
      expect(find.text('Gruppe B'), findsOneWidget);
    });

    testWidgets('aktive Gruppe zeigt check_circle Icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userGroupsProvider.overrideWith((ref) async => [groupA, groupB]),
            sessionProvider.overrideWith(
              (ref) => FakeSessionNotifier(
                const SessionState(userId: 'u1', groupId: 'g1'),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ProfileGroupsList()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('zeigt nichts bei leerer Gruppenliste', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userGroupsProvider.overrideWith((ref) async => []),
            sessionProvider.overrideWith(
              (ref) => FakeSessionNotifier(const SessionState()),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ProfileGroupsList()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Meine Gruppen'), findsNothing);
    });
  });
}
