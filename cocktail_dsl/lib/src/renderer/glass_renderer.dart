import '../catalog/catalog.dart';
import 'svg_builder.dart';

/// Renders the glass silhouette and produces the clip-path for liquid.
class GlassRenderer {
  /// Offset to center the 240x240 glass region within the 400x360 canvas.
  static const double offsetX = 80;
  static const double offsetY = 40;

  static String renderGlass(Glass glass, SvgBuilder svg) {
    final clipId = svg.nextId('glass_clip');

    // Define clip-path for liquid area
    svg.addDef(
      '<clipPath id="$clipId">'
      '<path d="${_offset(glass.clipPathData)}"/>'
      '</clipPath>',
    );

    // Draw glass: white fill with subtle gray stroke
    svg.add(
      '<path d="${_offset(glass.svgPath)}" '
      'fill="rgba(255,255,255,0.95)" stroke="rgba(200,200,210,0.8)" '
      'stroke-width="1.5" stroke-linejoin="round"/>',
    );

    return clipId;
  }

  /// Offset path data by the glass region origin.
  /// This is a simple transform — we wrap in a group with transform instead
  /// of rewriting path coordinates.
  static String _offset(String pathData) => pathData;

  /// Returns the liquid bounds offset to canvas coordinates.
  static Rect liquidBounds(Glass glass) {
    return Rect(
      glass.liquidBounds.x + offsetX,
      glass.liquidBounds.y + offsetY,
      glass.liquidBounds.width,
      glass.liquidBounds.height,
    );
  }
}
