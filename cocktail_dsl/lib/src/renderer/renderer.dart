import '../ast/recipe.dart';
import '../catalog/catalog.dart' show Catalog, Glass;
import 'svg_builder.dart';
import 'glass_renderer.dart';
import 'bands_renderer.dart';
import 'ice_renderer.dart';
import 'accent_renderer.dart';
import 'labels_renderer.dart';

/// Renders a parsed cocktail recipe as a self-contained SVG string.
class CocktailRenderer {
  /// Renders [recipe] to a self-contained SVG string.
  static String render(Recipe recipe) {
    final svg = SvgBuilder();
    final catalog = Catalog();
    final fillFraction = catalog.fillFraction(recipe.glass.id, recipe.ice.id);

    // Compute a tight viewBox based on the glass's actual Y extent.
    final glassBounds = _glassYBounds(recipe.glass);
    final hasAccents = recipe.accent.isNotEmpty;
    // Top margin: room for accent dots if present, otherwise small padding.
    final topMargin = hasAccents ? 24.0 : 8.0;
    final topY = glassBounds[0] + GlassRenderer.offsetY - topMargin;
    final bottomY = glassBounds[1] + GlassRenderer.offsetY + 8.0;
    svg.viewBoxX = 0;
    svg.viewBoxY = topY;
    svg.viewBoxWidth = 400;
    svg.viewBoxHeight = bottomY - topY;

    // Wrap glass rendering in a transform group to offset into the glass region
    // 1. Glass silhouette (stroke only) + clip-path definition
    svg.add('<g transform="translate(${GlassRenderer.offsetX},${GlassRenderer.offsetY})">');
    GlassRenderer.renderGlass(recipe.glass, svg);
    svg.add('</g>');

    // Need to redefine clip-path with offset for the liquid/ice
    final offsetClipId = svg.nextId('offset_clip');
    svg.addDef(
      '<clipPath id="$offsetClipId">'
      '<path d="${recipe.glass.clipPathData}" '
      'transform="translate(${GlassRenderer.offsetX},${GlassRenderer.offsetY})"/>'
      '</clipPath>',
    );

    // 2. Liquid bands, clipped to glass interior
    final liquidBounds = GlassRenderer.liquidBounds(recipe.glass);
    final bands = BandsRenderer.renderBands(
      recipe.spine,
      liquidBounds,
      fillFraction,
      offsetClipId,
      svg,
    );

    // 3. Ice overlay
    IceRenderer.renderIce(recipe.ice, recipe.glass, offsetClipId, svg);

    // 4. Accent dots — positioned just above the glass rim (liquid top)
    AccentRenderer.renderAccents(recipe.accent, liquidBounds.y, svg);

    // 5. Leader-line labels (right gutter)
    LabelsRenderer.renderLabels(bands, liquidBounds.right, svg);

    return svg.build();
  }

  /// Parses a Glass's svgPath to extract the min and max Y coordinates.
  /// Returns [minY, maxY] in the glass's internal coordinate space
  /// (before the canvas offset is applied).
  static List<double> _glassYBounds(Glass glass) {
    // The svgPath contains coordinate pairs like "x,y". Parse all numbers
    // and take every second one as a Y value.
    final path = glass.svgPath;
    final numberRe = RegExp(r'-?\d+\.?\d*');
    final numbers = numberRe
        .allMatches(path)
        .map((m) => double.tryParse(m.group(0)!))
        .whereType<double>()
        .toList();

    if (numbers.length < 2) return [40, 280];

    var minY = double.infinity;
    var maxY = double.negativeInfinity;
    for (var i = 1; i < numbers.length; i += 2) {
      final y = numbers[i];
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
    return [minY, maxY];
  }
}
