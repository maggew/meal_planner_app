import 'package:flutter/material.dart';

/// Appbar-Titel, der bei langem Text auf bis zu [maxLines] Zeilen umbricht
/// und in diesem Fall direkt auf [wrappedFontSize] verkleinert wird.
/// Der Zeilenumbruch wird durch ein explizites '\n' erzwungen, sodass er
/// auch dann erhalten bleibt, wenn der Text bei kleiner Schrift in eine
/// Zeile passen würde.
class AdaptiveAppBarTitle extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final int maxLines;
  final double wrappedFontSize;
  final TextAlign textAlign;

  const AdaptiveAppBarTitle({
    super.key,
    required this.text,
    this.baseStyle,
    this.maxLines = 2,
    this.wrappedFontSize = 15,
    this.textAlign = TextAlign.center,
  });

  /// Fügt ein '\n' an der Wortgrenze ein, die dem Textmittelpunkt am nächsten liegt.
  static String _insertLineBreak(String text) {
    final words = text.split(' ');
    if (words.length <= 1) return text;
    final half = text.length ~/ 2;
    int best = 1;
    int bestDist = text.length;
    int pos = 0;
    for (int i = 0; i < words.length - 1; i++) {
      pos += words[i].length + 1; // +1 für das Leerzeichen
      final dist = (pos - half).abs();
      if (dist < bestDist) {
        bestDist = dist;
        best = i + 1;
      }
    }
    return '${words.take(best).join(' ')}\n${words.skip(best).join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = baseStyle ??
        theme.appBarTheme.titleTextStyle ??
        theme.textTheme.titleLarge ??
        const TextStyle(fontSize: 25, fontWeight: FontWeight.w700);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (!maxWidth.isFinite || maxWidth <= 0) {
          return Text(
            text,
            style: style,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
          );
        }

        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textAlign: textAlign,
        )..layout(maxWidth: maxWidth);

        if (!painter.didExceedMaxLines) {
          return Text(
            text,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
          );
        }

        return Text(
          _insertLineBreak(text),
          style: style.copyWith(fontSize: wrappedFontSize),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
        );
      },
    );
  }
}
