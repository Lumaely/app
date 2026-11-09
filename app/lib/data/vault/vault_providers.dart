import 'package:lumaely/data/vault/secure_storage_master_key_cache.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_providers.g.dart';

/// Lumaely's cryptographic engine, loaded once at startup by the bootstrap.
@Riverpod(keepAlive: true)
LmCryptoEngine cryptoEngine(Ref ref) =>
    throw UnimplementedError('Provided by bootstrap()');

/// Where the diary lives on this device, found once at startup by the
/// bootstrap.
@Riverpod(keepAlive: true)
DiaryFiles diaryFiles(Ref ref) =>
    throw UnimplementedError('Provided by bootstrap()');

/// The Keychain/Keystore holding the master key.
@Riverpod(keepAlive: true)
MasterKeyCache masterKeyCache(Ref ref) => SecureStorageMasterKeyCache();
