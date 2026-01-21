extension DoubleFormatting on double {
  String toDisplayString() {
    if (this == toInt()) {
      return toInt().toString();
    }
    return toString();
  }
}
