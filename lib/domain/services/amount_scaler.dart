class AmountScaler {
  static String scale(String amount, double factor) {
    // reine Zahl
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(amount)) {
      final value = double.parse(amount);
      return _fmt(value * factor);
    }

    // Bereich: 150-200 oder 150–200
    final range =
        RegExp(r'^(\d+(\.\d+)?)[-–](\d+(\.\d+)?)$').firstMatch(amount);
    if (range != null) {
      final min = double.parse(range.group(1)!);
      final max = double.parse(range.group(3)!);
      return '${_fmt(min * factor)}-${_fmt(max * factor)}';
    }

    // Bruch: 1/2
    final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(amount);
    if (frac != null) {
      final value = int.parse(frac.group(1)!) / int.parse(frac.group(2)!);
      return _fmt(value * factor);
    }

    // nicht skalierbar (nach Geschmack, etwas, etc.)
    return amount;
  }

  static String _fmt(double v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }
}
