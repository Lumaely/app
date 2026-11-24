import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaely/core/time/clock_provider.dart';
import 'package:lumaely/core/time/today_provider.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('follows the day when the app comes back', (tester) async {
    var now = DateTime(2026, 10, 29, 23);
    final container = ProviderContainer.test(
      overrides: [clockProvider.overrideWithValue(() => now)],
    );
    final today = container.listen(todayProvider, (_, _) {});
    expect(today.read(), LocalDate(2026, 10, 29));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    now = DateTime(2026, 10, 30, 8);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(today.read(), LocalDate(2026, 10, 30));
  });
}
