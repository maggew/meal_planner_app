import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/enums/carb_tag.dart';

void main() {
  group('CarbTag enum', () {
    test('fromValue round-trip für alle Werte', () {
      for (final tag in CarbTag.values) {
        expect(CarbTag.fromValue(tag.value), tag);
      }
    });

    test('fromValue unbekannter Wert → keine', () {
      expect(CarbTag.fromValue('xyz'), CarbTag.keine);
    });

    test('displayName ist für alle Tags nicht leer', () {
      for (final tag in CarbTag.values) {
        expect(tag.displayName.isNotEmpty, true);
      }
    });

    test('alle erwarteten Werte vorhanden', () {
      expect(
          CarbTag.values,
          containsAll([
            CarbTag.reis,
            CarbTag.pasta,
            CarbTag.kartoffel,
            CarbTag.brot,
            CarbTag.couscousBulgur,
            CarbTag.keine,
          ]));
    });
  });
}
