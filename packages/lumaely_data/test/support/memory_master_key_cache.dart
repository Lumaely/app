import 'dart:typed_data';

import 'package:lumaely_data/lumaely_data.dart';

/// A [MasterKeyCache] kept in memory, standing in for the Keychain in tests.
class MemoryMasterKeyCache implements MasterKeyCache {
  Uint8List? _stored;

  @override
  Future<Uint8List?> read() async =>
      _stored == null ? null : Uint8List.fromList(_stored!);

  @override
  Future<void> write(Uint8List masterKey) async {
    _stored = Uint8List.fromList(masterKey);
  }

  @override
  Future<void> clear() async {
    _stored = null;
  }
}
