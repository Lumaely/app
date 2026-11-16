import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/src/components/mood/lm_mood_labels.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';

/// the touch / keyboard / screen reader part of one mood (a column of the
/// curve, or the whole-day slider). draws nothing except the focus ring
/// - tap or drag -> score under the finger
/// - screen readers: a slider ("Morning, Good, 4 of 5"), swipe up / down
/// - keyboard: arrows (up/down, or left/right for a horizontal one)
/// - empty mood: first step goes to okay
class MoodTarget extends StatefulWidget {
  const new({
    required this.label,
    required this.score,
    required this.onChanged,
    required this.scoreAt,
    required this.axis,
    super.key,
  });

  final String label;
  final MoodScore? score;
  final ValueChanged<MoodScore> onChanged;

  /// score under a position inside the target
  final MoodScore Function(Offset position) scoreAt;

  final Axis axis;

  @override
  State<MoodTarget> createState() => _MoodTargetState();
}

class _MoodTargetState extends State<MoodTarget> {
  var _focused = false;

  bool get _vertical => widget.axis == Axis.vertical;

  void _set(MoodScore score) {
    if (score == widget.score) {
      return;
    }
    unawaited(HapticFeedback.selectionClick());
    widget.onChanged(score);
  }

  MoodScore _step(int delta) {
    final score = widget.score;
    if (score == null) {
      return MoodScore.okay;
    }
    return MoodScore.fromValue((score.value + delta).clamp(1, 5));
  }

  String _describe(MoodScore? score) {
    if (score == null) {
      return 'Not set';
    }
    return '${moodLabel(score)}, ${score.value} of 5';
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final up = _vertical
        ? key == LogicalKeyboardKey.arrowUp
        : key == LogicalKeyboardKey.arrowRight;
    final down = _vertical
        ? key == LogicalKeyboardKey.arrowDown
        : key == LogicalKeyboardKey.arrowLeft;

    if (up || down) {
      _set(_step(up ? 1 : -1));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    void drag(DragUpdateDetails details) {
      _set(widget.scoreAt(details.localPosition));
    }

    void start(DragStartDetails details) {
      _set(widget.scoreAt(details.localPosition));
    }

    // container: one node per target, so two columns never merge
    return Semantics(
      container: true,
      slider: true,
      label: widget.label,
      value: _describe(widget.score),
      increasedValue: _describe(_step(1)),
      decreasedValue: _describe(_step(-1)),
      onIncrease: () => _set(_step(1)),
      onDecrease: () => _set(_step(-1)),
      child: Focus(
        onFocusChange: (focused) => setState(() => _focused = focused),
        onKeyEvent: _onKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _set(widget.scoreAt(details.localPosition)),
          onVerticalDragStart: _vertical ? start : null,
          onVerticalDragUpdate: _vertical ? drag : null,
          onHorizontalDragStart: _vertical ? null : start,
          onHorizontalDragUpdate: _vertical ? null : drag,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LmRadius.small),
              border: _focused
                  ? Border.all(color: context.colors.focus, width: 2)
                  : null,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
