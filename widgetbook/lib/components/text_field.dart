import 'package:flutter/material.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: LmTextField, path: '[Components]')
Widget textFieldPlayground(BuildContext context) {
  final knobs = context.knobs;
  final multiline = knobs.boolean(label: 'Multiline');
  final showError = knobs.boolean(label: 'Error');
  final error = knobs.string(
    label: 'Error message',
    initialValue: 'Wrong email or password.',
  );

  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(LmSpace.s5),
        child: LmTextField(
          label: knobs.string(label: 'Label', initialValue: 'Email'),
          hint: knobs.string(label: 'Hint', initialValue: 'name@example.com'),
          error: showError ? error : null,
          password: knobs.boolean(label: 'Password'),
          maxLines: multiline ? 4 : 1,
          maxLength: multiline ? 200 : null,
          enabled: knobs.boolean(label: 'Enabled', initialValue: true),
        ),
      ),
    ),
  );
}

// same as the "Error · sign in" screen in figma
@widgetbook.UseCase(
  name: 'Sign in form',
  type: LmTextField,
  path: '[Components]',
)
Widget signInForm(BuildContext context) {
  return const Scaffold(
    body: Padding(
      padding: EdgeInsets.all(LmSpace.s5),
      child: Column(
        spacing: LmSpace.s4,
        children: [
          LmTextField(
            label: 'Email',
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            autofillHints: [AutofillHints.email],
          ),
          LmTextField(
            label: 'Password',
            hint: '••••••••••',
            password: true,
            error: 'Wrong email or password.',
            autofillHints: [AutofillHints.password],
          ),
        ],
      ),
    ),
  );
}
