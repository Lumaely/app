import 'package:lumaely_core/lumaely_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

/// The device's clock (tests set their own).
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => systemClock;
