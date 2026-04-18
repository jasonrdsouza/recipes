import '../ast/recipe.dart';
import 'svg_builder.dart';

/// Renders garnish elements near the glass rim or as text below.
class GarnishRenderer {
  static const double textY = 340.0;
  static const double glyphY = 45.0; // near rim
  static const double glyphSize = 16.0;

  static void renderGarnishes(List<Garnish> garnishes, SvgBuilder svg) {
    if (garnishes.isEmpty) return;

    final totalWidth = garnishes.length * 60.0;
    final startX = 200.0 - totalWidth / 2 + 30;

    for (var i = 0; i < garnishes.length; i++) {
      final garnish = garnishes[i];
      final x = startX + i * 60;
      final glyphId = _resolveGlyph(garnish.text);

      if (glyphId != null && _glyphPaths.containsKey(glyphId)) {
        // Render known glyph near the rim
        final path = _glyphPaths[glyphId]!;
        svg.add(
          '<g transform="translate(${x - glyphSize / 2},${glyphY - glyphSize / 2})">'
          '<path d="$path" fill="#aaa" stroke="none"/>'
          '<title>${_formatGarnishTitle(garnish)}</title>'
          '</g>',
        );
      } else {
        // Render as text label below the glass
        final label = _formatGarnishTitle(garnish);
        svg.add(
          '<text x="$x" y="$textY" text-anchor="middle" '
          'font-family="system-ui, sans-serif" font-size="10px" fill="#aaa">'
          '${_escapeXml(label)}'
          '</text>',
        );
      }
    }
  }

  static String _formatGarnishTitle(Garnish g) {
    if (g.modifiers != null) return '${g.text} (${g.modifiers})';
    return g.text;
  }

  /// Loose matching from garnish text to known glyph id.
  static String? _resolveGlyph(String text) {
    final lower = text.toLowerCase();
    for (final entry in _glyphAliases.entries) {
      if (entry.value.any((alias) => lower.contains(alias))) {
        return entry.key;
      }
    }
    return null;
  }

  static const _glyphAliases = <String, List<String>>{
    'citrus-peel': ['peel', 'twist', 'zest'],
    'citrus-wheel': ['wheel'],
    'citrus-wedge': ['wedge'],
    'cherry': ['cherry', 'luxardo cherry', 'maraschino cherry'],
    'olive': ['olive'],
    'mint-sprig': ['mint'],
    'salt-rim': ['salt rim', 'salt-rim'],
    'sugar-rim': ['sugar rim', 'sugar-rim'],
    'cucumber-slice': ['cucumber'],
    'edible-flower': ['flower', 'edible flower'],
  };

  /// 16x16 glyph path data for known garnishes.
  static const _glyphPaths = <String, String>{
    'citrus-peel':
        'M4,12 Q2,6 8,3 Q14,6 12,12 M6,8 Q8,6 10,8',
    'citrus-wheel':
        'M8,1 A7,7 0 1,0 8,15 A7,7 0 1,0 8,1 '
        'M8,4 L8,12 M5,5.5 L11,10.5 M5,10.5 L11,5.5',
    'citrus-wedge':
        'M2,12 L8,2 L14,12 Z M5,9 L8,4 L11,9',
    'cherry':
        'M8,6 A4,4 0 1,0 8,14 A4,4 0 1,0 8,6 M8,6 Q10,2 12,1',
    'olive':
        'M8,3 A5,6 0 1,0 8,15 A5,6 0 1,0 8,3 M7,8 A1.5,1.5 0 1,0 9,8',
    'mint-sprig':
        'M8,14 L8,6 M5,8 Q8,4 11,8 M4,11 Q8,7 12,11',
    'salt-rim':
        'M2,8 L14,8 M3,6 L3,8 M5,5 L5,8 M7,6 L7,8 M9,5 L9,8 '
        'M11,6 L11,8 M13,5 L13,8',
    'sugar-rim':
        'M2,8 L14,8 M4,6 A1,1 0 1,0 4,8 M7,5 A1,1 0 1,0 7,7 '
        'M10,6 A1,1 0 1,0 10,8 M13,5 A1,1 0 1,0 13,7',
    'cucumber-slice':
        'M8,2 A6,6 0 1,0 8,14 A6,6 0 1,0 8,2 '
        'M8,5 L8,11 M5.5,6 L10.5,10 M5.5,10 L10.5,6',
    'edible-flower':
        'M8,4 Q10,2 12,5 Q14,7 12,9 Q10,12 8,10 '
        'Q6,12 4,9 Q2,7 4,5 Q6,2 8,4',
  };

  static String _escapeXml(String s) =>
      s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
}
