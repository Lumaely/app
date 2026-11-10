import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:test/test.dart';

void main() {
  late LmCryptoEngine crypto;

  setUpAll(() async {
    crypto = await LmCryptoEngine.init();
  });

  SecureKey newIdKey() {
    final master = crypto.generateMasterKey();
    final idKey = crypto.deriveKey(master, KeyPurpose.recordIds);
    master.dispose();
    addTearDown(idKey.dispose);
    return idKey;
  }

  test('the same label always gives the same id', () {
    final idKey = newIdKey();

    expect(
      crypto.recordId(idKey, 'entry:2026-10-29'),
      crypto.recordId(idKey, 'entry:2026-10-29'),
    );
  });

  test('another label gives another id', () {
    final idKey = newIdKey();

    expect(
      crypto.recordId(idKey, 'entry:2026-10-29'),
      isNot(crypto.recordId(idKey, 'entry:2026-10-30')),
    );
  });

  test('another key gives another id', () {
    expect(
      crypto.recordId(newIdKey(), 'entry:2026-10-29'),
      isNot(crypto.recordId(newIdKey(), 'entry:2026-10-29')),
    );
  });

  test('an id is 64 hexadecimal characters', () {
    expect(
      crypto.recordId(newIdKey(), 'entry:2026-10-29'),
      matches(RegExp(r'^[0-9a-f]{64}$')),
    );
  });
}
