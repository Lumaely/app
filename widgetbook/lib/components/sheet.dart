import 'package:lumaely_ui/lumaely_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// examples from the app's screens

Widget _opener(String label, void Function(BuildContext context) open) {
  return Scaffold(
    body: Center(
      child: Builder(
        builder: (context) =>
            LmButton(label: label, onPressed: () => open(context)),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Message', type: LmSheet, path: '[Components]')
Widget messageSheet(BuildContext context) {
  return _opener(
    'Open sheet',
    (context) => showLmSheet<void>(
      context,
      builder: (context) => LmSheet(
        title: 'Your diary stays on this device',
        message:
            'Nothing is sent anywhere. That also means that if this device '
            'is lost, broken or reset, your entries are gone for good.',
        content: Text(
          'You can export an encrypted backup at any time, or switch to '
          'Lumaely Cloud later.',
          style: LmTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        actions: [
          LmButton(
            label: 'I understand',
            onPressed: () => Navigator.pop(context),
          ),
          LmButton(
            label: 'Choose another option',
            variant: LmButtonVariant.text,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Actions', type: LmSheet, path: '[Components]')
Widget actionsSheet(BuildContext context) {
  return _opener(
    'Add media',
    (context) => showLmSheet<void>(
      context,
      builder: (context) {
        void close() => Navigator.pop(context);
        return LmSheet(
          title: 'Add to this entry',
          content: LmTileGroup(
            // white on white in dawn otherwise
            color: context.colors.background,
            children: [
              LmTileRow(
                leading: const LmTileIcon(LmIcons.camera),
                title: 'Take a photo',
                onTap: close,
              ),
              LmTileRow(
                leading: const LmTileIcon(LmIcons.video),
                title: 'Record a video',
                onTap: close,
              ),
              LmTileRow(
                leading: const LmTileIcon(LmIcons.photo),
                title: 'Choose from library',
                onTap: close,
              ),
            ],
          ),
          actions: [
            LmButton(
              label: 'Cancel',
              variant: LmButtonVariant.secondary,
              onPressed: close,
            ),
          ],
        );
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Text field', type: LmSheet, path: '[Components]')
Widget fieldSheet(BuildContext context) {
  return _opener(
    'New folder',
    (context) => showLmSheet<void>(
      context,
      builder: (context) => LmSheet(
        title: 'New folder',
        content: const LmTextField(label: 'Name', autofocus: true),
        actions: [
          LmButton(label: 'Create', onPressed: () => Navigator.pop(context)),
          LmButton(
            label: 'Cancel',
            variant: LmButtonVariant.text,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Destructive', type: LmDialog, path: '[Components]')
Widget destructiveDialog(BuildContext context) {
  return _opener(
    'Remove device',
    (context) => showLmDialog<void>(
      context,
      builder: (context) => LmDialog(
        title: 'Remove MacBook Pro?',
        message:
            'It will stop syncing. The entries already stored on it stay '
            'there until the app is reset on that device.',
        actions: [
          LmButton(
            label: 'Remove from sync',
            variant: LmButtonVariant.danger,
            leading: const LmIcon(LmIcons.trash),
            onPressed: () => Navigator.pop(context),
          ),
          LmButton(
            label: 'Cancel',
            variant: LmButtonVariant.text,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}
