enum Unit {
  LITER("l"),
  MILLILITER("ml"),
  GRAMM("g"),
  KILOGRAMM("kg"),
  TEASPOON("TL"),
  EATINGSPOON("EL"),
  PIECE("Stk."),
  PRISE("Prise"),
  KNIFETIP("Msp."),
  CAN("Dose"),
  BUNCH("Bund");

  final String displayName;
  const Unit(this.displayName);
}

class UnitParser {
  static final Map<String, Unit> _unitMap = {
    'l': Unit.LITER,
    'liter': Unit.LITER,
    'ml': Unit.MILLILITER,
    'milliliter': Unit.MILLILITER,
    'g': Unit.GRAMM,
    'gramm': Unit.GRAMM,
    'kg': Unit.KILOGRAMM,
    'kilogramm': Unit.KILOGRAMM,
    'tl': Unit.TEASPOON,
    'teelöffel': Unit.TEASPOON,
    'teeloffel': Unit.TEASPOON,
    'el': Unit.EATINGSPOON,
    'esslöffel': Unit.EATINGSPOON,
    'essloffel': Unit.EATINGSPOON,
    'stk': Unit.PIECE,
    'stück': Unit.PIECE,
    'stuck': Unit.PIECE,
    'piece': Unit.PIECE,
    'prise': Unit.PRISE,
    'msp': Unit.KNIFETIP,
    'messerspitze': Unit.KNIFETIP,
    'bund': Unit.BUNCH,
    'bunch': Unit.BUNCH,
    'Dose': Unit.CAN,
    'dose': Unit.CAN,
  };

  static Unit? parse(String unitStr) {
    String normalized = unitStr.toLowerCase().replaceAll('.', '').trim();
    return _unitMap[normalized];
  }
}
