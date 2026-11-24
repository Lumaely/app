import 'package:intl/intl.dart';
import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';

/// the layout of every step of the entry input flow: top bar, date, progress,
/// question, then [child], and then the actions at the bottom
/// - screen readers hear each step as a new page
/// - the keyboard covers the actions instead of pushing them up (the page must
///   not resize for it)
class EntryStepLayout extends StatelessWidget {
  const new({
    required this.date,
    required this.isToday,
    required this.step,
    required this.title,
    required this.child,
    required this.actions,
    required this.onBack,
    this.subtitle,
    super.key,
  });

  final LocalDate date;
  final bool isToday;

  /// starts at 1
  final int step;

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget actions;

  /// null = can't leave now (used while saving)
  final VoidCallback? onBack;

  static const stepCount = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = this.subtitle;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LmSpace.s5,
            LmSpace.s2,
            LmSpace.s5,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: LmSpace.s4,
            children: [
              LmTopBar(title: isToday ? 'Today' : 'Past day', onBack: onBack),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(date.toDateTime()),
                        style: LmTypography.labelMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: LmSpace.s4),
                      LmProgressSteps(current: step, count: stepCount),
                      const SizedBox(height: LmSpace.s8),
                      Semantics(
                        header: true,
                        namesRoute: true,
                        child: Text(
                          title,
                          style: LmTypography.headlineLarge.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: LmTypography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: LmSpace.s4),
                      child,
                    ],
                  ),
                ),
              ),
              // at least as high as the keyboard, the actions at its bottom
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: keyboard),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 1,
                  child: SafeArea(
                    top: false,
                    maintainBottomViewPadding: true,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: LmSpace.s5),
                      child: actions,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
