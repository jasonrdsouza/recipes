import '../ast/recipe.dart';
import 'svg_builder.dart';

/// Renders accent dots/ticks above the glass rim.
class AccentRenderer {
  static const double dotRadius = 4.0;
  static const double tickWidth = 8.0;
  static const double tickHeight = 6.0;
  static const double gapAboveRim = 12.0;

  /// Countable units render as dots; non-countable as ticks.
  static const _countableUnits = {Unit.dash, Unit.drop, Unit.pinch};

  static void renderAccents(List<AccentLine> accents, double glassTop, SvgBuilder svg) {
    if (accents.isEmpty) return;
    final regionY = glassTop - gapAboveRim;

    // Collect all visual items (dots and ticks)
    final items = <_AccentItem>[];
    for (final accent in accents) {
      final color = accent.ingredient.color;
      final unitName = accent.amount > 1
          ? _pluralUnit(accent.unit.name)
          : accent.unit.name;
      final title = '${accent.amount} $unitName ${accent.ingredient.displayName}';

      if (_countableUnits.contains(accent.unit)) {
        for (var i = 0; i < accent.amount; i++) {
          items.add(_AccentItem(color: color, isDot: true, title: title));
        }
      } else {
        items.add(_AccentItem(color: color, isDot: false, title: title));
      }
    }

    if (items.isEmpty) return;

    // Distribute items horizontally, centered in the accent region
    final totalWidth = items.length * (dotRadius * 3);
    final startX = 200.0 - totalWidth / 2 + dotRadius * 1.5;

    for (var i = 0; i < items.length; i++) {
      final x = startX + i * (dotRadius * 3);
      final item = items[i];

      if (item.isDot) {
        svg.add(
          '<circle cx="$x" cy="$regionY" r="$dotRadius" '
          'fill="#${item.color}">'
          '<title>${_escapeXml(item.title)}</title>'
          '</circle>',
        );
      } else {
        svg.add(
          '<rect x="${x - tickWidth / 2}" y="${regionY - tickHeight / 2}" '
          'width="$tickWidth" height="$tickHeight" rx="1" '
          'fill="#${item.color}">'
          '<title>${_escapeXml(item.title)}</title>'
          '</rect>',
        );
      }
    }
  }

  static String _pluralUnit(String unit) {
    switch (unit) {
      case 'dash': return 'dashes';
      case 'pinch': return 'pinches';
      default: return '${unit}s';
    }
  }

  static String _escapeXml(String s) =>
      s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
}

class _AccentItem {
  final String color;
  final bool isDot;
  final String title;

  _AccentItem({required this.color, required this.isDot, required this.title});
}
