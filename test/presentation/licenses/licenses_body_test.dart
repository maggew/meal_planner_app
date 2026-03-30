import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/presentation/licenses/widgets/licenses_body.dart';

// ── Fake Licenses ──────────────────────────────────────────────────────────
//
// LicenseRegistry.addLicense persists for the entire test run, so we add
// fake entries once in setUpAll. The entries are designed to verify:
// - alphabetical sorting (charlie before delta)
// - plural suffix ("1 Lizenz" vs "2 Lizenzen")
// - multi-license grouping (charlie_pkg has two entries)

bool _licensesRegistered = false;

void _registerFakeLicenses() {
  if (_licensesRegistered) return;
  _licensesRegistered = true;

  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
        ['delta_pkg'], 'Delta license text here');
    yield LicenseEntryWithLineBreaks(
        ['charlie_pkg'], 'Charlie license ONE');
    yield LicenseEntryWithLineBreaks(
        ['charlie_pkg'], 'Charlie license TWO');
  });
}

// ── Helper ─────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  setUpAll(_registerFakeLicenses);

  testWidgets('zeigt CircularProgressIndicator während Laden',
      (tester) async {
    await tester.pumpWidget(_wrap(const LicensesBody()));

    // Before FutureBuilder completes
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('zeigt Pakete alphabetisch sortiert', (tester) async {
    await tester.pumpWidget(_wrap(const LicensesBody()));
    await tester.pumpAndSettle();

    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .toList();

    final charlieIdx = texts.indexOf('charlie_pkg');
    final deltaIdx = texts.indexOf('delta_pkg');

    expect(charlieIdx, isNonNegative, reason: 'charlie_pkg muss angezeigt werden');
    expect(deltaIdx, isNonNegative, reason: 'delta_pkg muss angezeigt werden');
    expect(charlieIdx, lessThan(deltaIdx),
        reason: 'charlie_pkg muss vor delta_pkg stehen');
  });

  testWidgets('Pluralisierung: "1 Lizenz" vs "2 Lizenzen"', (tester) async {
    await tester.pumpWidget(_wrap(const LicensesBody()));
    await tester.pumpAndSettle();

    // delta_pkg hat 1 Lizenz
    expect(find.text('1 Lizenz'), findsOneWidget);
    // charlie_pkg hat 2 Lizenzen
    expect(find.text('2 Lizenzen'), findsOneWidget);
  });

  testWidgets('Expansion zeigt Lizenztext', (tester) async {
    await tester.pumpWidget(_wrap(const LicensesBody()));
    await tester.pumpAndSettle();

    // Lizenztext ist initial collapsed → nicht sichtbar
    expect(find.text('Delta license text here'), findsNothing);

    // Expand delta_pkg
    await tester.tap(find.text('delta_pkg'));
    await tester.pumpAndSettle();

    expect(find.text('Delta license text here'), findsOneWidget);
  });
}
