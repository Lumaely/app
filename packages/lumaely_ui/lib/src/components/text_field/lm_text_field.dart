import 'package:lumaely_ui/src/components/text/lm_field_error.dart';
import 'package:lumaely_ui/src/icons/lm_icon.dart';
import 'package:lumaely_ui/src/icons/lm_icons.dart';
import 'package:lumaely_ui/src/theme/lm_theme.dart';
import 'package:lumaely_ui/src/tokens/lm_layout.dart';
import 'package:lumaely_ui/src/tokens/lm_typography.dart';
import 'package:material_ui/material_ui.dart';

/// text field with its label above (not inside like material does)
/// - [error] -> red border + message under the field
/// - [password] -> hidden text + button to show it
/// - [maxLines] null -> grows with the text
class LmTextField extends StatefulWidget {
  const new({
    required this.label,
    this.controller,
    this.hint,
    this.error,
    this.password = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? error;
  final bool password;
  final int? maxLines;

  /// shows a counter under the field (20/200)
  final int? maxLength;

  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<LmTextField> createState() => _LmTextFieldState();
}

class _LmTextFieldState extends State<LmTextField> {
  var _hidden = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final error = widget.error;
    final fieldTheme = Theme.of(context).inputDecorationTheme;

    // label, field and error are read together by screen readers
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: LmSpace.s2,
        children: [
          Text(
            widget.label,
            style: LmTypography.labelMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          TextField(
            controller: widget.controller,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            obscureText: widget.password && _hidden,
            // no suggestions / autocorrect for passwords
            autocorrect: !widget.password,
            enableSuggestions: !widget.password,
            // disable keyboard learning
            // FIXME: decide whether to put this or not
            enableIMEPersonalizedLearning: false,
            maxLines: widget.password ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: LmTypography.bodyMedium.copyWith(
              color: widget.enabled ? colors.textPrimary : colors.textDisabled,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              // error message is under the field (in the column), aligned on
              // its left edge. material's errorText would be indented
              enabledBorder: error == null ? null : fieldTheme.errorBorder,
              focusedBorder: error == null
                  ? null
                  : fieldTheme.focusedErrorBorder,
              suffixIcon: widget.password
                  ? IconButton(
                      tooltip: _hidden ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _hidden = !_hidden),
                      color: colors.textSecondary,
                      icon: LmIcon(_hidden ? LmIcons.eye : LmIcons.eyeSlash),
                    )
                  : null,
            ),
          ),
          if (error != null) LmFieldError(error),
        ],
      ),
    );
  }
}
