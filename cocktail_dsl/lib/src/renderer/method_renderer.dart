import '../ast/recipe.dart';
import 'svg_builder.dart';

/// Renders method icons in a horizontal strip below the glass.
class MethodRenderer {
  static const double regionY = 310.0;
  static const double iconSize = 20.0;
  static const double spacing = 8.0;

  static void renderMethod(List<MethodStep> method, SvgBuilder svg) {
    if (method.isEmpty) return;

    final totalWidth = method.length * iconSize + (method.length - 1) * spacing;
    final startX = 200.0 - totalWidth / 2;

    for (var i = 0; i < method.length; i++) {
      final x = startX + i * (iconSize + spacing);
      final verb = method[i].verb;
      final pathData = _iconPaths[verb];

      if (pathData != null) {
        svg.add(
          '<g transform="translate($x,$regionY)">'
          '<path d="$pathData" fill="#aaa" stroke="none"/>'
          '<title>${_escapeXml(verb)}</title>'
          '</g>',
        );
      } else {
        // Fallback: render verb as text
        svg.add(
          '<text x="${x + iconSize / 2}" y="${regionY + iconSize / 2 + 4}" '
          'text-anchor="middle" font-family="system-ui, sans-serif" '
          'font-size="9px" fill="#aaa">'
          '${_escapeXml(verb)}'
          '</text>',
        );
      }
    }
  }

  /// 20x20 icon path data for each method verb.
  static const _iconPaths = <String, String>{
    // Shake: shaker silhouette
    'shake':
        'M7,2 L13,2 L14,6 L15,18 L5,18 L6,6 Z '
        'M6,6 L14,6',
    // Stir: bar spoon / circular motion
    'stir':
        'M10,2 L10,14 M6,14 A4,4 0 1,0 14,14',
    // Build: layered bars
    'build':
        'M3,14 L17,14 L17,18 L3,18 Z '
        'M5,9 L15,9 L15,13 L5,13 Z '
        'M7,4 L13,4 L13,8 L7,8 Z',
    // Swizzle: stick with notches
    'swizzle':
        'M10,2 L10,18 M6,14 L14,14 M7,11 L13,11 M8,8 L12,8',
    // Blend: blender shape
    'blend':
        'M6,2 L14,2 L16,12 L4,12 Z M7,13 L13,13 L13,18 L7,18 Z',
    // Throw: arc with arrow
    'throw':
        'M3,15 Q10,2 17,15 M14,12 L17,15 L14,18',
    // Whip: whisk lines
    'whip':
        'M10,2 L10,8 M6,8 Q6,18 10,18 Q14,18 14,8 '
        'M8,8 Q8,16 10,16 Q12,16 12,8',
    // Roll: two containers with arrow
    'roll':
        'M2,4 L7,4 L7,16 L2,16 Z M13,4 L18,4 L18,16 L13,16 Z '
        'M8,10 L12,10 M11,8 L12,10 L11,12',
    // Dry shake: shaker with "no ice" indicator
    'dry-shake':
        'M7,2 L13,2 L14,6 L15,18 L5,18 L6,6 Z '
        'M3,3 L17,17',
    // Reverse dry shake: shaker with reverse indicator
    'reverse-dry-shake':
        'M7,2 L13,2 L14,6 L15,18 L5,18 L6,6 Z '
        'M17,3 L3,17',
    // Strain: strainer mesh pattern
    'strain':
        'M4,6 L16,6 L14,10 L6,10 Z '
        'M6,11 L14,11 M7,13 L13,13 M8,15 L12,15',
    // Double strain: two strainer layers
    'double-strain':
        'M4,4 L16,4 L14,8 L6,8 Z '
        'M5,9 L15,9 L13,13 L7,13 Z '
        'M8,14 L12,14 M9,16 L11,16',
    // Fine strain: fine mesh
    'fine-strain':
        'M4,6 L16,6 L14,10 L6,10 Z '
        'M7,11 L13,11 M7,12.5 L13,12.5 M7,14 L13,14 M7,15.5 L13,15.5',
  };

  static String _escapeXml(String s) =>
      s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
}
