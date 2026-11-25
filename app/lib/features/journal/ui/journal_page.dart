import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumaely/core/router/router_paths.dart';
import 'package:lumaely/core/time/today_provider.dart';
import 'package:lumaely/core/ui/load_error.dart';
import 'package:lumaely/data/entries/entry_providers.dart';
import 'package:lumaely/features/journal/application/journal_items.dart';
import 'package:lumaely/features/journal/ui/journal_empty.dart';
import 'package:lumaely/features/journal/ui/journal_list.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

class JournalPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void open(LocalDate date) => context.push(RouterPaths.entryOn(date));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                LmSpace.s5,
                LmSpace.s2,
                LmSpace.s5,
                0,
              ),
              child: LmTopBar.tab(title: 'Journal'),
            ),
            Expanded(
              child: switch (ref.watch(writtenDatesProvider)) {
                AsyncValue(hasError: true) => LoadError(
                  message: 'Your diary could not be read.',
                  onRetry: () => ref.invalidate(writtenDatesProvider),
                ),
                AsyncData(value: Set(isEmpty: true)) => JournalEmpty(
                  onWrite: () => open(ref.read(todayProvider)),
                ),
                AsyncData(:final value) => JournalList(
                  items: journalItemsOf(value),
                  // FIXME: open the day itself, once its page exists
                  onDayTap: open,
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
