import 'package:lumaely/core/time/clock_provider.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_provider.g.dart';

@riverpod
LocalDate today(Ref ref) {
  final listener = AppLifecycleListener(onResume: ref.invalidateSelf);
  ref.onDispose(listener.dispose);

  return LocalDate.today(ref.watch(clockProvider));
}
