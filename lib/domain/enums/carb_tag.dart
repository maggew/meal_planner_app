enum CarbTag {
  reis,
  pasta,
  kartoffel,
  brot,
  couscousBulgur,
  keine;

  String get displayName => switch (this) {
        CarbTag.reis => 'Reis',
        CarbTag.pasta => 'Pasta',
        CarbTag.kartoffel => 'Kartoffel',
        CarbTag.brot => 'Brot',
        CarbTag.couscousBulgur => 'Couscous/Bulgur',
        CarbTag.keine => 'Keine',
      };

  String get value => name;

  static CarbTag fromValue(String value) {
    return CarbTag.values.firstWhere(
      (t) => t.name == value,
      orElse: () => CarbTag.keine,
    );
  }
}
