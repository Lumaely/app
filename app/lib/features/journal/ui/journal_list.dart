import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumaely/data/entries/entry_providers.dart';
import 'package:lumaely/features/journal/application/journal_items.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// the written days by month, newest first
/// it uses lazy loading so that resources are not wasted and fps stays high
class JournalList extends StatefulWidget {
  const new({required this.items, required this.onDayTap, super.key});

  final List<JournalItem> items;
  final ValueChanged<LocalDate> onDayTap;

  static const readAhead = ScrollCacheExtent.pixels(600);

  @override
  State<JournalList> createState() => _JournalListState();
}

class _JournalListState extends State<JournalList> {
  final GlobalKey _lines = GlobalKey();
  final ValueNotifier<double> _offset = ValueNotifier(0);

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        _offset.value = scroll.metrics.pixels;
        return false;
      },
      child: Stack(
        children: [
          CustomScrollView(
            scrollCacheExtent: JournalList.readAhead,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(bottom: LmSpace.s5),
                sliver: SliverList.builder(
                  key: _lines,
                  itemCount: items.length,
                  itemBuilder: (context, index) => switch (items[index]) {
                    JournalMonth(:final month) => _MonthTitle(month),
                    final JournalDay day => _Day(
                      day,
                      divider: day.last && index < items.length - 1,
                      onTap: () => widget.onDayTap(day.date),
                    ),
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder(
              valueListenable: _offset,
              builder: (context, offset, _) => _stickyMonth(offset),
            ),
          ),
        ],
      ),
    );
  }

  /// the title of the month on screen, pushed up by the next one
  Widget _stickyMonth(double offset) {
    // the title of the list itself is there
    if (offset <= 0) {
      return const SizedBox.shrink();
    }

    final (month, push) = _monthAt(offset);

    return ClipRect(
      child: Transform.translate(
        offset: Offset(0, push),
        child: ExcludeSemantics(
          child: IgnorePointer(
            child: ColoredBox(
              color: context.colors.background,
              child: _MonthTitle(month),
            ),
          ),
        ),
      ),
    );
  }

  /// the month at the top of the screen, and how far the next one pushes it
  (LocalDate, double) _monthAt(double offset) {
    final lines = _lines.currentContext?.findRenderObject();
    var month = widget.items.first.month;

    if (lines is RenderSliverMultiBoxAdaptor) {
      for (
        var line = lines.firstChild;
        line != null;
        line = lines.childAfter(line)
      ) {
        final item = widget.items.elementAtOrNull(lines.indexOf(line));
        final top = (lines.childScrollOffset(line) ?? 0) - offset;

        if (top <= 0) {
          month = item?.month ?? month;
        } else if (item is JournalMonth) {
          return (month, math.min(0, top - line.size.height));
        }
      }
    }

    return (month, 0);
  }
}

class _MonthTitle extends StatelessWidget {
  const new(this.month);

  final LocalDate month;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LmSpace.s5),
      child: LmTileGroupTitle(
        // FIXME: english for now, the locale comes with translations
        DateFormat('MMMM y').format(month.toDateTime()),
        variant: LmTileGroupTitleVariant.heading,
      ),
    );
  }
}

/// one day, with the [divider] before the next month
class _Day extends StatelessWidget {
  const new(this.day, {required this.divider, required this.onTap});

  final JournalDay day;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LmSpace.s5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LmTileSlice(
            first: day.first,
            last: day.last,
            child: _DayRow(day.date, onTap: onTap),
          ),
          if (divider)
            Divider(
              height: LmSpace.s8,
              thickness: 1,
              color: context.colors.border,
            ),
        ],
      ),
    );
  }
}

class _DayRow extends ConsumerWidget {
  const new(this.date, {required this.onTap});

  final LocalDate date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = date.firstOfMonth;
    // built again only when this very day changes
    final (:loaded, :entry) = ref.watch(
      entriesBetweenProvider(
        month,
        month.lastOfMonth,
      ).select((days) => (loaded: days.hasValue, entry: days.value?[date])),
    );

    if (entry != null) {
      return LmDayRow(entry: entry, onTap: onTap);
    }

    // as high as a day without journal, so that the list doesn't jump
    return loaded
        ? const SizedBox.shrink()
        : const ExcludeSemantics(
            child: LmTileRow(title: '', subtitle: ''),
          );
  }
}
