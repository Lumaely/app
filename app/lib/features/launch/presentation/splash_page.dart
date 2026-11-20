import 'package:material_ui/material_ui.dart';

class SplashPage extends StatelessWidget {
  const new({super.key});

  // FIXME: english for now, the locale comes with translations
  static const semanticLabel = 'Opening your diary';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      child: const Scaffold(),
    );
  }
}
