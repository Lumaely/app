# figma tokens export

Small Figma plugin (development only, never published) that builds
`tokens/tokens.json` from the Figma file:
- colors: variable collection `v1`, one mode per theme (Dawn, Firefly)
- spacing and radii: collection `layout`
- text styles: local text styles

The output follows the W3C design tokens format. `tools/tokens_generator.dart`
then turns it into Dart.

## install (once)

Figma desktop > Plugins > Development > Import plugin from manifest...
and pick `manifest.json` in this folder.

## export

1. in the Lumaely Figma file: Plugins > Development > Lumaely tokens export
2. Download (or Copy) and replace `packages/lumaely_ui/tokens/tokens.json`
3. regenerate the Dart files:
   ```bash
   cd packages/lumaely_ui && fvm dart run tools/tokens_generator.dart
   ```
4. check the diff, run the tests (contrast test!) and commit both

Names of the collections and fonts are at the top of `code.js`.
