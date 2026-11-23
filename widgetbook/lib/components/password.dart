import 'package:lumaely_core/lumaely_core.dart';
import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// type a password, the strength follows
@widgetbook.UseCase(
  name: 'Playground',
  type: LmPasswordStrength,
  path: '[Components]',
)
Widget passwordStrength(BuildContext context) => const _PasswordDemo();

class _PasswordDemo extends StatefulWidget {
  const new();

  @override
  State<_PasswordDemo> createState() => _PasswordDemoState();
}

class _PasswordDemoState extends State<_PasswordDemo> {
  var _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LmSpace.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: LmSpace.s2,
            children: [
              LmTextField(
                label: 'Password',
                password: true,
                onChanged: (password) => setState(() => _password = password),
              ),
              LmPasswordStrength(PasswordStrength.of(_password)),
            ],
          ),
        ),
      ),
    );
  }
}
