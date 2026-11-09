import 'dart:io';

import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// The files of one diary, inside its folder.
@immutable
final class DiaryFiles {
  /// Points at the diary stored in [folder].
  const new(this.folder);

  /// The folder holding the diary.
  final Directory folder;

  /// The encrypted database.
  File get database => File(p.join(folder.path, 'diary.db'));

  /// The locked master key.
  File get keyFile => File(p.join(folder.path, 'diary.lmkey'));

  /// Whether a diary was created in [folder].
  bool exists() => keyFile.existsSync();

  /// Reads and decodes `diary.lmkey`.
  Future<KeyFile> readKeyFile() async =>
      KeyFile.decode(await keyFile.readAsString());

  /// Writes `diary.lmkey` so that it is never left half-written.
  Future<void> writeKeyFile(KeyFile file) async {
    await folder.create(recursive: true);

    final temporary = File('${keyFile.path}.tmp');

    await temporary.writeAsString(file.encode(), flush: true);
    await temporary.rename(keyFile.path);
  }

  /// Deletes the whole diary folder. Close the database first.
  Future<void> delete() async {
    if (folder.existsSync()) {
      await folder.delete(recursive: true);
    }
  }
}
