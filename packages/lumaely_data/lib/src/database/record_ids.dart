import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';

/// The ids of the diary's records that are tied to a date.
///
/// The labels below are part of the stored format: NEVER change them.
final class RecordIds {
  new _(this._crypto, this._key);

  /// Derives the id key from [masterKey].
  factory forMasterKey(LmCryptoEngine crypto, SecureKey masterKey) =>
      RecordIds._(crypto, crypto.deriveKey(masterKey, KeyPurpose.recordIds));

  final LmCryptoEngine _crypto;
  final SecureKey _key;

  /// The id of the entry for [date].
  String entry(LocalDate date) => _crypto.recordId(_key, 'entry:$date');

  /// The id of the mood for [momentId] on [date], or of the whole-day mood
  /// when [momentId] is null.
  String mood(LocalDate date, {String? momentId}) => _crypto.recordId(
    _key,
    momentId == null ? 'mood:$date' : 'mood:$date:$momentId',
  );

  /// Removes the id key from memory
  void dispose() => _key.dispose();
}
