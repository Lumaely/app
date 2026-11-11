import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumaely/core/constants.dart';
import 'package:lumaely/core/router.dart';
import 'package:lumaely_ui/lumaely_ui.dart';

class App extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: Constants.appName,
      theme: LmThemeData.dawn,
      darkTheme: LmThemeData.firefly,
    );
  }
}
