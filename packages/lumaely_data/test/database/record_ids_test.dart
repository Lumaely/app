import 'dart:typed_data';

import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/src/database/record_ids.dart';
import 'package:test/test.dart';

void main() {
  late LmCryptoEngine crypto;
  late RecordIds ids;
  final day = LocalDate(2026, 10, 29);

  setUpAll(() async {
    crypto = await LmCryptoEngine.init();
  });

  setUp(() {
    // A fixed master key (bytes 0 to 31), so the expected ids never change.
    final master = crypto.masterKeyFromBytes(
      Uint8List.fromList(List.generate(32, (i) => i)),
    );
    ids = RecordIds.forMasterKey(crypto, master);
    master.dispose();
    addTearDown(ids.dispose);
  });

  // Golden values. If one changes, every diary's ids change, and sync would
  // see every day as a new record. Never update them to make a test pass.
  test('ids never change', () {
    expect(
      ids.entry(day),
      '69d8dbe7f4798e396fd4cf35e92007c5f6953024068dd2dee8ff8aebe3c4a421',
    );
    expect(
      ids.mood(day),
      '1c2426345e017153395441260b343be173fbf807cd5e91ced835e7dc938b0aa4',
    );
    expect(
      ids.mood(day, momentId: Moment.morning.id),
      'f9b76fb7b36d2fe1edec6a644eb63a37ead709a9d09afd6d0cede584ac40d883',
    );
  });

  test('each moment of a day has its own mood id', () {
    final moodIds = {
      ids.mood(day),
      for (final moment in Moment.values) ids.mood(day, momentId: moment.id),
    };

    expect(moodIds, hasLength(Moment.values.length + 1));
  });

  test('each day has its own entry id', () {
    expect(ids.entry(day), isNot(ids.entry(day.addDays(1))));
  });
}
