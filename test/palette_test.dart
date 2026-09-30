import 'package:design/logic/palette.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseHex accepts 3/6 digits with or without hash', () {
    expect(parseHex('#fff'), Rgb.white);
    expect(parseHex('000000'), Rgb.black);
    expect(parseHex(' #1e88e5 '), const Rgb(0x1E, 0x88, 0xE5));
    expect(parseHex('#12345'), isNull);
    expect(parseHex('#GGGGGG'), isNull);
    expect(parseHex(''), isNull);
  });

  test('hex and argb formatting', () {
    expect(const Rgb(30, 136, 229).hex, '#1E88E5');
    expect(const Rgb(1, 2, 3).argb, 0xFF010203);
  });

  test('scale has nine steps with the base in the middle', () {
    final base = parseHex('#808080')!;
    final scale = scaleFor(base);
    expect(scale.map((s) => s.label).toList(), [
      '100', '200', '300', '400', '500', '600', '700', '800', '900', //
    ]);
    expect(scale[4].color, base);
    expect(scale.first.color, const Rgb(230, 230, 230));
    expect(scale.last.color, const Rgb(26, 26, 26));
    final lum = scale.map((s) => relativeLuminance(s.color)).toList();
    for (var i = 1; i < lum.length; i++) {
      expect(lum[i], lessThan(lum[i - 1]));
    }
  });

  test('contrast ratio matches WCAG reference values', () {
    expect(contrastRatio(Rgb.white, Rgb.black), closeTo(21, 1e-9));
    expect(contrastRatio(Rgb.white, Rgb.white), closeTo(1, 1e-9));
    // #767676 on white is the classic 4.54:1 AA threshold colour.
    expect(contrastRatio(parseHex('#767676')!, Rgb.white), closeTo(4.54, 0.01));
  });

  test('ratings and best text colour', () {
    expect(wcagRating(7.1), 'AAA');
    expect(wcagRating(4.5), 'AA');
    expect(wcagRating(3.2), 'AA Large');
    expect(wcagRating(2.9), 'Fail');
    expect(bestTextOn(parseHex('#FFEB3B')!), Rgb.black);
    expect(bestTextOn(parseHex('#0D47A1')!), Rgb.white);
  });
}
