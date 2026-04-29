import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/common/sync_status_indicator.dart';
import 'package:meal_planner/services/providers/sync/sync_status_provider.dart';

class _FixedNotifier extends SyncStatusNotifier {
  _FixedNotifier(SyncStatus initial)
      : super(const Stream<Never>.empty()) {
    state = initial;
  }
}

Widget _wrap(SyncStatus status, {Widget? child}) {
  return ProviderScope(
    overrides: [
      syncStatusProvider
          .overrideWith((ref) => _FixedNotifier(status)),
    ],
    child: MaterialApp(
      home: Scaffold(
        appBar: CommonAppbar(title: 'Test'),
        body: child ?? const SizedBox.shrink(),
      ),
    ),
  );
}

SyncStatus _status(SyncHealth h, {int failed = 0, Object? fatal}) => SyncStatus(
      health: h,
      failedItemCount: failed,
      lastSuccessAt: DateTime(2026, 4, 8, 12, 0),
      lastFatalError: fatal,
      lastEventAt: DateTime(2026, 4, 8, 12, 0),
    );

void main() {
  group('SyncStatusIndicator', () {
    testWidgets('renders nothing for idle', (tester) async {
      await tester.pumpWidget(_wrap(_status(SyncHealth.idle)));
      expect(find.byType(IconButton),
          findsNothing,
          reason: 'idle must not render any icon');
    });

    testWidgets('renders nothing for ok', (tester) async {
      await tester.pumpWidget(_wrap(_status(SyncHealth.ok)));
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('syncing → renders nothing (silent poll)', (tester) async {
      await tester.pumpWidget(_wrap(_status(SyncHealth.syncing)));
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('degraded → tertiary cloud_queue icon', (tester) async {
      await tester.pumpWidget(_wrap(_status(SyncHealth.degraded, failed: 2)));
      expect(find.byIcon(Icons.cloud_queue), findsOneWidget);
    });

    testWidgets('failing → error cloud_off icon', (tester) async {
      await tester
          .pumpWidget(_wrap(_status(SyncHealth.failing, fatal: 'rls denied')));
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('tap opens details sheet with retry button', (tester) async {
      await tester.pumpWidget(_wrap(_status(SyncHealth.degraded, failed: 3)));
      await tester.tap(find.byIcon(Icons.cloud_queue));
      await tester.pumpAndSettle();

      expect(find.byType(SyncStatusSheet), findsOneWidget);
      expect(find.text('Synchronisation'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // failedItemCount
      expect(find.text('Jetzt erneut versuchen'), findsOneWidget);
    });
  });
}
