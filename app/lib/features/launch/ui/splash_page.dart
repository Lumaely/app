import 'package:material_ui/material_ui.dart';

class SplashPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Opening your diary',
      liveRegion: true,
      child: const Scaffold(),
    );
  }
}
