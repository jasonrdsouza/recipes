import '../ast/recipe.dart';
import '../catalog/catalog.dart' show Catalog;
import 'svg_builder.dart';
import 'glass_renderer.dart';
import 'bands_renderer.dart';
import 'ice_renderer.dart';
import 'accent_renderer.dart';
import 'garnish_renderer.dart';
import 'labels_renderer.dart';

/// Renders a parsed cocktail recipe as a self-contained SVG string.
class CocktailRenderer {
  /// Renders [recipe] to a self-contained SVG string.
  /// The SVG has viewBox="0 0 400 360" with no width/height attributes.
  static String render(Recipe recipe) {
    final svg = SvgBuilder();
    final catalog = Catalog();
    final fillFraction = catalog.fillFraction(recipe.glass.id, recipe.ice.id);

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

    // 4. Accent dots
    AccentRenderer.renderAccents(recipe.accent, svg);

    // 5. Garnish
    GarnishRenderer.renderGarnishes(recipe.garnishes, svg);

    // 6. Leader-line labels (right gutter)
    LabelsRenderer.renderLabels(bands, liquidBounds.right, svg);

    return svg.build();
  }
}
