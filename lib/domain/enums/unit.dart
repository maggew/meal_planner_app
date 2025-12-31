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
  BUNCH("Bund");

  final String displayName;
  const Unit(this.displayName);
}
