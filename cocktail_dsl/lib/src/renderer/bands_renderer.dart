import '../ast/recipe.dart';
import '../catalog/catalog.dart' show Rect;
import 'svg_builder.dart';

/// Computed band data for use by the label renderer.
class Band {
  final double y;
  final double height;
  final double midY;
  final String name;

  Band({required this.y, required this.height, required this.name})
      : midY = y + height / 2;
}

/// Renders stacked liquid bands inside the glass clip-path.
class BandsRenderer {
  static List<Band> renderBands(
    Spine spine,
    Rect liquidBounds,
    double fillFraction,
    String clipId,
    SvgBuilder svg,
  ) {
    final totalRatio = spine.lines.fold<double>(0, (sum, l) => sum + l.ratio);
    if (totalRatio == 0) return [];

    // The liquidBounds extends ~20px past the clip path bottom so the
    // clip path's rounded corners shape the liquid. Fill fraction is applied
    // to the visible interior only. The bottom band gets extra height below
    // to reach into the overflow zone.
    const bottomOverflow = 20.0;
    final visibleHeight = liquidBounds.height - bottomOverflow;
    final liquidHeight = visibleHeight * fillFraction;

    final bands = <Band>[];
    final bandSvg = StringBuffer();

    // Stack from the visible bottom (not the overflow bottom).
    final visibleBottom = liquidBounds.y + visibleHeight;
    var currentY = visibleBottom;

    for (var i = 0; i < spine.lines.length; i++) {
      final line = spine.lines[i];
      final bandHeight = (line.ratio / totalRatio) * liquidHeight;
      currentY -= bandHeight;
      final ingredient = line.ingredient;
      final color = ingredient.color;
      final isUnknown = ingredient is UnknownIngredient;
      final isBottomBand = i == 0;

      // Bottom band gets extra height so clip path rounds the bottom
      final renderHeight = isBottomBand ? bandHeight + bottomOverflow : bandHeight;
      final renderX = liquidBounds.x;
      final renderWidth = liquidBounds.width;

      if (isUnknown) {
        bandSvg.write(
          '<rect x="$renderX" y="$currentY" '
          'width="$renderWidth" height="$renderHeight" '
          'fill="#C8C8C8" stroke="#808080" stroke-dasharray="4 2" stroke-width="1">'
          '<title>${_escapeXml(ingredient.displayName)}</title>'
          '</rect>',
        );
      } else {
        // Flat fill with saturation-boosted color.
        final popColor = _saturate(color, 1.5);
        bandSvg.write(
          '<rect x="$renderX" y="$currentY" '
          'width="$renderWidth" height="$renderHeight" '
          'fill="#$popColor">'
          '<title>${_escapeXml(ingredient.displayName)}</title>'
          '</rect>',
        );
      }

      bands.add(Band(
        y: currentY,
        height: bandHeight,
        name: ingredient.displayName,
      ));
    }

    // Wrap in clip-path group
    svg.add('<g clip-path="url(#$clipId)">');
    svg.add(bandSvg.toString());
    svg.add('</g>');

    return bands;
  }

  /// Push a color away from its own luminance by [factor] to boost saturation.
  static String _saturate(String hex, double factor) {
    final r = int.parse(hex.substring(0, 2), radix: 16) / 255;
    final g = int.parse(hex.substring(2, 4), radix: 16) / 255;
    final b = int.parse(hex.substring(4, 6), radix: 16) / 255;
    final lum = 0.299 * r + 0.587 * g + 0.114 * b;
    final nr = (lum + (r - lum) * factor).clamp(0.0, 1.0);
    final ng = (lum + (g - lum) * factor).clamp(0.0, 1.0);
    final nb = (lum + (b - lum) * factor).clamp(0.0, 1.0);
    return '${(nr * 255).round().toRadixString(16).padLeft(2, '0')}'
        '${(ng * 255).round().toRadixString(16).padLeft(2, '0')}'
        '${(nb * 255).round().toRadixString(16).padLeft(2, '0')}';
  }

  static String _escapeXml(String s) =>
      s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
}
