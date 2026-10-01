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

  group('edge cases (pass 3)', () {
    test('ratio labels never round up across a WCAG threshold', () {
      // 2.9982:1 used to display as "3.00:1" next to a "Fail" rating.
      final nearThree = contrastRatio(parseHex('#003AFB')!, Rgb.black);
      expect(nearThree, lessThan(3));
      expect(wcagRating(nearThree), 'Fail');
      expect(formatRatio(nearThree), '2.99:1');
      final nearSeven = contrastRatio(parseHex('#004ED0')!, Rgb.white);
      expect(wcagRating(nearSeven), 'AA');
      expect(formatRatio(nearSeven), '6.99:1');
      // Exact and binary-inexact values stay intact.
      expect(formatRatio(21), '21.00:1');
      expect(formatRatio(4.5), '4.50:1');
      expect(formatRatio(4.57), '4.57:1');
      expect(formatRatio(1), '1.00:1');
    });

    test('rating boundaries are inclusive', () {
      expect(wcagRating(7), 'AAA');
      expect(wcagRating(6.9999), 'AA');
      expect(wcagRating(3), 'AA Large');
      expect(wcagRating(2.9999), 'Fail');
    });

    test('contrast is symmetric and within 1..21', () {
      for (var v = 0; v < 0x1000000; v += 0x0F1F2F) {
        final c = Rgb((v >> 16) & 255, (v >> 8) & 255, v & 255);
        final w = contrastRatio(c, Rgb.white);
        expect(w, closeTo(contrastRatio(Rgb.white, c), 1e-12));
        expect(w, inInclusiveRange(1, 21));
      }
    });

    test('best text colour always reaches AA Large (and >= 4.5 in practice)',
        () {
      for (var v = 0; v < 0x1000000; v += 0x010307) {
        final c = Rgb((v >> 16) & 255, (v >> 8) & 255, v & 255);
        expect(contrastRatio(c, bestTextOn(c)), greaterThanOrEqualTo(4.5),
            reason: c.hex);
      }
    });

    test('parseHex rejects near-misses', () {
      for (final bad in [
        '#',
        '##fff',
        '#ffff',
        '#12345678',
        'fff ff',
        '＃fff',
        '#ｆｆｆ',
        '0xFFFFFF'
      ]) {
        expect(parseHex(bad), isNull, reason: bad);
      }
      expect(parseHex('ABC'), const Rgb(0xAA, 0xBB, 0xCC));
    });

    test('scale of pure white and black stays in range', () {
      final white = scaleFor(Rgb.white);
      expect(white.take(5).every((s) => s.color == Rgb.white), isTrue);
      expect(white.last.color, const Rgb(51, 51, 51));
      final black = scaleFor(Rgb.black);
      expect(black.first.color, const Rgb(204, 204, 204));
      expect(black.skip(4).every((s) => s.color == Rgb.black), isTrue);
    });

    test('mix endpoints', () {
      const c = Rgb(10, 20, 30);
      expect(mix(c, Rgb.white, 0), c);
      expect(mix(c, Rgb.white, 1), Rgb.white);
    });
  });
}
