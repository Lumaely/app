import 'package:lumaely_data/lumaely_data.dart';

/// Where the diary stands on this device.
sealed class VaultState {
  const new();
}

/// No diary on this device yet: offer to create or import one.
final class VaultEmpty extends VaultState {
  const new();
}

/// A diary exists, but this device holds no usable key: ask for the password
/// or the recovery key.
final class VaultLocked extends VaultState {
  const new();
}

/// The diary is open and ready to use.
final class VaultOpen extends VaultState {
  const new(this.diary);

  final LocalDiary diary;
}
