# Layout, assets, forms

## Layout

- `Row`/`Column`: `Expanded` to fill; `Flexible` to shrink; do not mix both on
  the same child. Use `Wrap` when children would overflow.
- Scroll: `SingleChildScrollView` for fixed overflow content; builder
  constructors for long lists/grids.
- `FittedBox` to scale a single child; `LayoutBuilder` / `MediaQuery` for
  responsive decisions.
- `Stack`: `Positioned` or `Align` for placement.
- `OverlayPortal` for overlays (custom dropdowns/tooltips) that sit above
  the rest of the UI.

## Assets & images

- Declare asset dirs in `pubspec.yaml` under `flutter: assets:`.
- Local: `Image.asset(...)`.
- Network: `Image.network` with `loadingBuilder` and `errorBuilder`.
- Caching: prefer a package such as `cached_network_image` when caching is
  required.
- Custom icons from an `ImageProvider`: `ImageIcon`.

## Text fields

Configure `textCapitalization`, `keyboardType`, and decoration hint/label
(placeholder) appropriately for the field’s data.
