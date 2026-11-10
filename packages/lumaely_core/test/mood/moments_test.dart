import 'package:lumaely_core/lumaely_core.dart';
import 'package:test/test.dart';

void main() {
  test('stored ids never change', () {
    expect(
      Moment.values.map((moment) => moment.id),
      orderedEquals(['morning', 'noon', 'afternoon', 'evening', 'night']),
    );
  });

  test('every moment reads back from its id', () {
    for (final moment in Moment.values) {
      expect(Moment.fromId(moment.id), moment);
    }
  });
}
