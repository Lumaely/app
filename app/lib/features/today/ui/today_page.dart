import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely/core/time/today_provider.dart';
import 'package:lumaely/core/ui/load_error.dart';
import 'package:lumaely/data/entries/entry_providers.dart';
import 'package:lumaely/features/today/ui/today_card.dart';
import 'package:lumaely/features/today/ui/today_header.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// home of the app: today's entry at a glance
class TodayPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final written = ref.watch(writtenDatesProvider);
    final entry = ref.watch(dayEntryProvider(today));

    return Scaffold(
      body: switch ((written, entry)) {
        (AsyncValue(hasError: true), _) ||
        (_, AsyncValue(hasError: true)) => LoadError(
          message: 'Your diary could not be read.',
          onRetry: () => ref
            ..invalidate(writtenDatesProvider)
            ..invalidate(dayEntryProvider(today)),
        ),
        (AsyncData(value: final written), AsyncData(value: final entry)) =>
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                LmSpace.s5,
                LmSpace.s2,
                LmSpace.s5,
                LmSpace.s5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: LmSpace.s4,
                children: [
                  TodayHeader(
                    firstDay: written.isEmpty,
                    streak: streakOf(written, today: today),
                  ),
                  TodayCard(
                    date: today,
                    entry: entry,
                    firstDay: written.isEmpty,
                    onWrite: () => context.push(RouterPaths.entryOn(today)),
                  ),
                ],
              ),
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
