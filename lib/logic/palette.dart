/// Pure colour maths: hex parsing, tint/shade scale and WCAG contrast.
library;

import 'dart:math' as math;

class Rgb {
  const Rgb(this.r, this.g, this.b)
      : assert(r >= 0 && r <= 255),
        assert(g >= 0 && g <= 255),
        assert(b >= 0 && b <= 255);

  final int r;
  final int g;
  final int b;

  static const white = Rgb(255, 255, 255);
  static const black = Rgb(0, 0, 0);

  /// 0xAARRGGBB with full opacity, handy for `Color(value)`.
  int get argb => 0xFF000000 | (r << 16) | (g << 8) | b;

  String get hex => '#${[
        r,
        g,
        b
      ].map((c) => c.toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';

  @override
  bool operator ==(Object other) =>
      other is Rgb && other.r == r && other.g == g && other.b == b;

  @override
  int get hashCode => Object.hash(r, g, b);

  @override
  String toString() => hex;
}

final _hexPattern = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');

/// Parses `#RGB`, `#RRGGBB` (hash optional). Returns null when invalid.
Rgb? parseHex(String input) {
  final m = _hexPattern.firstMatch(input.trim());
  if (m == null) return null;
  var h = m.group(1)!;
  if (h.length == 3) h = h.split('').map((c) => '$c$c').join();
  final v = int.parse(h, radix: 16);
  return Rgb((v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF);
}

Rgb mix(Rgb a, Rgb b, double t) {
  int lerp(int x, int y) => (x + (y - x) * t).round().clamp(0, 255);
  return Rgb(lerp(a.r, b.r), lerp(a.g, b.g), lerp(a.b, b.b));
}

class Swatch {
  const Swatch(this.label, this.color);

  final String label;
  final Rgb color;
}

/// Nine steps: 100-400 are tints (mixed with white), 500 is the base,
/// 600-900 are shades (mixed with black).
List<Swatch> scaleFor(Rgb base) {
  const tints = [0.8, 0.6, 0.4, 0.2];
  const shades = [0.2, 0.4, 0.6, 0.8];
  return [
    for (var i = 0; i < 4; i++)
      Swatch('${(i + 1) * 100}', mix(base, Rgb.white, tints[i])),
    Swatch('500', base),
    for (var i = 0; i < 4; i++)
      Swatch('${(i + 6) * 100}', mix(base, Rgb.black, shades[i])),
  ];
}

/// WCAG 2.x relative luminance.
double relativeLuminance(Rgb c) {
  double channel(int v) {
    final s = v / 255;
    return s <= 0.04045
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4) as double;
  }

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// Contrast ratio between 1 and 21.
double contrastRatio(Rgb a, Rgb b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Formats a contrast ratio as `4.49:1`, truncating (never rounding up) so the
/// label cannot show a passing threshold the ratio does not reach: 2.9998
/// would round to `3.00` while [wcagRating] (correctly) says "Fail".
String formatRatio(double ratio) {
  // The epsilon keeps exact values such as 4.57 (456.9999... * 100) intact.
  final truncated = (ratio * 100 + 1e-9).floor() / 100;
  return '${truncated.toStringAsFixed(2)}:1';
}

/// WCAG rating for normal-size text.
String wcagRating(double ratio) {
  if (ratio >= 7) return 'AAA';
  if (ratio >= 4.5) return 'AA';
  if (ratio >= 3) return 'AA Large';
  return 'Fail';
}

/// Black or white, whichever contrasts more with [background].
Rgb bestTextOn(Rgb background) =>
    contrastRatio(background, Rgb.white) >= contrastRatio(background, Rgb.black)
        ? Rgb.white
        : Rgb.black;
