import '../catalog/catalog.dart' show Ice, Glass;
import 'glass_renderer.dart';
import 'svg_builder.dart';

/// Renders ice overlay on top of liquid bands.
class IceRenderer {
  static void renderIce(Ice ice, Glass glass, String clipId, SvgBuilder svg) {
    if (ice.id == 'none' || ice.svgFragment.isEmpty) return;

    final bounds = GlassRenderer.liquidBounds(glass);

    // Position ice within the glass, clipped to the interior
    svg.add(
      '<g clip-path="url(#$clipId)" transform="translate(${bounds.x},${bounds.y})">'
      '<path d="${ice.svgFragment}" '
      'fill="rgba(200,220,240,0.7)" '
      'stroke="rgba(150,170,190,0.9)" stroke-width="1"/>'
      '</g>',
    );
  }
}
