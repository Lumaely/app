import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumaely/app.dart';
import 'package:lumaely/data/vault/vault_providers.dart';
import 'package:lumaely_crypto/lumaely_crypto.dart';
import 'package:lumaely_data/lumaely_data.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// App bootstrap
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final crypto = await LmCryptoEngine.init();
  final supportFolder = await getApplicationSupportDirectory();
  final diaryFiles =
  DiaryFiles(Directory(p.join(supportFolder.path, 'diary')));

  runApp(
    ProviderScope(
      overrides: [
        cryptoEngineProvider.overrideWithValue(crypto),
        diaryFilesProvider.overrideWithValue(diaryFiles),
      ],
      child: const App(),
    ),
  );
}
