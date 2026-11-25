import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely/core/time/today_provider.dart';
import 'package:lumaely/core/ui/load_error.dart';
import 'package:lumaely/data/entries/entry_providers.dart';
import 'package:lumaely/features/today/ui/this_week.dart';
import 'package:lumaely/features/today/ui/today_card.dart';
import 'package:lumaely/features/today/ui/today_header.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// home of the app: today's entry and this week at a glance
class TodayPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final written = ref.watch(writtenDatesProvider);
    final monday = today.firstOfWeek;
    final weekProvider = entriesBetweenProvider(monday, monday.addDays(6));
    final week = ref.watch(weekProvider);

    void write(LocalDate date) => context.push(RouterPaths.entryOn(date));

    return Scaffold(
      body: switch ((written, week)) {
        (AsyncValue(hasError: true), _) ||
        (_, AsyncValue(hasError: true)) => LoadError(
          message: 'Your diary could not be read.',
          onRetry: () => ref
            ..invalidate(writtenDatesProvider)
            ..invalidate(weekProvider),
        ),
        (AsyncData(value: final written), AsyncData(value: final week)) =>
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
                    entry: week[today],
                    firstDay: written.isEmpty,
                    onWrite: () => write(today),
                  ),
                  ThisWeek(
                    today: today,
                    entries: week,
                    isFirstDay: written.isEmpty,
                    // FIXME: a written day opens its page, once it exists
                    onDayTap: write,
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
