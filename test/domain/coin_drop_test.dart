import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/features/onboarding/presentation/widgets/coin_drop.dart';

void main() {
  const tl = CoinDropTimeline();

  test('glass starts low and ends full', () {
    expect(tl.level(0), closeTo(tl.startLevel, 1e-9));
    expect(tl.level(tl.end), closeTo(tl.endLevel, 1e-9));
  });

  test('liquid only rises, never drops, as coins land', () {
    var prev = tl.level(0);
    for (var t = 0.0; t <= tl.end; t += 0.005) {
      final l = tl.level(t);
      expect(l, greaterThanOrEqualTo(prev - 1e-12));
      prev = l;
    }
  });

  test('nothing rises before the first coin lands', () {
    expect(tl.level(tl.landOf(0) - 0.001), closeTo(tl.startLevel, 1e-9));
  });

  test('coins fall one after another', () {
    for (var i = 1; i < tl.coins; i++) {
      expect(tl.startOf(i), greaterThan(tl.startOf(i - 1)));
    }
    expect(tl.fallProgress(0, tl.landOf(0)), 1);
    expect(tl.fallProgress(1, tl.startOf(1)), 0);
  });
}
