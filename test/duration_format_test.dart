import 'package:chronus/src/common/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats HH:MM:SS.D collapsing leading empty units', () {
    expect(formatHmsd(4300), '4.3'); // seconds only
    expect(formatHmsd(75200), '1:15.2'); // minutes:seconds
    expect(formatHmsd(3725400), '1:02:05.4'); // hours:minutes:seconds
    expect(formatHmsd(0), '0.0');
  });

  test('rounds to the nearest tenth of a second', () {
    expect(formatHmsd(1249), '1.2');
    expect(formatHmsd(1250), '1.3'); // .5 rounds up
    expect(formatHmsd(59960), '1:00.0'); // rolls over into the next minute
  });
}
