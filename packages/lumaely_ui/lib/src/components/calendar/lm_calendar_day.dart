import 'package:intl/intl.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_dot.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_labels.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// one day of a calendar (month, scrolling calendar)
/// - mood dot, the date under it, then the journal mark
/// - [entry] null -> dashed circle ("no entry"), past or future alike
/// - [isToday] -> ring around the dot, darker number
/// - [onTap] null -> not tappable (future days)
/// - the centre of the dot is kept for the mascot face, later
class LmCalendarDay extends StatefulWidget {
  const new({
    required this.date,
    required this.entry,
    this.isToday = false,
    this.onTap,
    super.key,
  });

  final LocalDate date;
  final DayEntry? entry;
  final bool isToday;
  final VoidCallback? onTap;

  static const dotSize = 34.0;

  /// dot + today ring (2 px, 1 px away from the dot)
  static const slotSize = 40.0;

  static const markHeight = 8.0;

  /// tap target: the cell fills its column, at least this wide alone
  static const minWidth = 48.0;

  @override
  State<LmCalendarDay> createState() => _LmCalendarDayState();
}

class _LmCalendarDayState extends State<LmCalendarDay> {
  var _focused = false;

  @override
  void didUpdateWidget(LmCalendarDay old) {
    super.didUpdateWidget(old);
    if (widget.onTap == null) {
      _focused = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final entry = widget.entry;
    final hasJournal = entry != null && entry.journal.trim().isNotEmpty;
    final onTap = widget.onTap;

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        SizedBox.square(
          dimension: LmCalendarDay.slotSize,
          child: DecoratedBox(
            decoration: widget.isToday
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.textPrimary, width: 2),
                  )
                : const BoxDecoration(),
            child: Center(
              child: LmMoodDot(
                average: entry?.moods.average,
                size: LmCalendarDay.dotSize,
              ),
            ),
          ),
        ),
        Text(
          '${widget.date.day}',
          textAlign: TextAlign.center,
          style: LmTypography.labelSmall.copyWith(
            color: widget.isToday ? colors.textPrimary : colors.textSecondary,
          ),
        ),
        SizedBox(
          width: LmCalendarDay.slotSize,
          height: LmCalendarDay.markHeight,
          child: hasJournal
              ? Center(
                  child: Container(
                    key: const ValueKey('journal mark'),
                    width: 8,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: colors.actionPrimary,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(1.25),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ],
    );

    // fills the column of the calendar (48 px wide from 336 px of calendar,
    // every current phone with 16 px margins)
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: LmCalendarDay.minWidth),
      child: Center(widthFactor: 1, child: column),
    );

    final label = _semanticLabel(entry, hasJournal);

    if (onTap == null) {
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: LmSpace.s1),
          child: content,
        ),
      );
    }

    return Semantics(
      label: label,
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        onFocusChange: (focused) => setState(() => _focused = focused),
        borderRadius: const BorderRadius.all(Radius.circular(LmRadius.small)),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colors.textPrimary.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.textPrimary.withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),
        child: DecoratedBox(
          // keyboard focus: a rounded ring around the whole cell, so it is
          // never mistaken for the today ring
          position: DecorationPosition.foreground,
          decoration: _focused
              ? BoxDecoration(
                  border: Border.all(color: colors.focus, width: 2),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(LmRadius.small),
                  ),
                )
              : const BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: LmSpace.s1),
            child: content,
          ),
        ),
      ),
    );
  }

  // "Thursday, October 1, today. Good, 4 of 5. Journal."
  String _semanticLabel(DayEntry? entry, bool hasJournal) {
    final date = DateTime(widget.date.year, widget.date.month, widget.date.day);
    // FIXME: english for now, the locale comes with translations
    final day = DateFormat('EEEE, MMMM d').format(date);
    final parts = [
      if (widget.isToday) '$day, today' else day,
      if (entry != null) moodSemantics(entry.moods),
      if (hasJournal) 'Journal',
      if (entry == null && widget.onTap == null) 'Not yet',
      if (entry == null && widget.onTap != null) 'No entry',
    ];
    return '${parts.join('. ')}.';
  }
}
