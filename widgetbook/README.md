<img src="../assets/logo-rounded-256.png" width="48" height="48" alt="Lumaely logo">

# lumaely_widgetbook

The catalog of Lumaely's design system (`lumaely_ui`), built with
[Widgetbook](https://www.widgetbook.io). Switch between Dawn and Firefly,
phone sizes and text scales without running the whole app.

## Run

```bash
cd widgetbook
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter run -d macos        # or -d chrome
```

## Add a use case

Write a function annotated with `@widgetbook.UseCase(name: …, type: …)` that
returns the widget, then run `build_runner` again: the navigation tree
(`lib/main.directories.g.dart`, not committed) is generated from the
annotations.
