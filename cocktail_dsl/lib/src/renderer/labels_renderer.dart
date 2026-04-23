import 'bands_renderer.dart';
import 'svg_builder.dart';

/// Renders leader-line labels for spine ingredients in the right gutter.
class LabelsRenderer {
  static const double stubOut = 8.0;
  static const double labelPad = 4.0;
  static const double minSpacing = 18.0;
  static const double fontSize = 11.0;

  static void renderLabels(
    List<Band> bands,
    double glassRightEdge,
    SvgBuilder svg,
  ) {
    if (bands.isEmpty) return;

    // Position labels relative to the glass right edge
    final elbowX = glassRightEdge + stubOut;
    final labelX = elbowX + labelPad;

    // Sort bands by vertical midpoint (top to bottom)
    final sorted = List<Band>.from(bands)
      ..sort((a, b) => a.midY.compareTo(b.midY));

    // Place labels with minimum spacing
    final labelYs = <double>[];
    for (final band in sorted) {
      final ideal = band.midY;
      if (labelYs.isEmpty) {
        labelYs.add(ideal);
      } else {
        final prev = labelYs.last;
        labelYs.add(ideal < prev + minSpacing ? prev + minSpacing : ideal);
      }
    }

    // Render each leader line and label
    for (var i = 0; i < sorted.length; i++) {
      final band = sorted[i];
      final labelY = labelYs[i];

      // Elbow path: horizontal from band → vertical → horizontal to label
      svg.add(
        '<path d="M${glassRightEdge},${band.midY} '
        'L$elbowX,${band.midY} '
        'L$elbowX,$labelY '
        'L$labelX,$labelY" '
        'fill="none" stroke="var(--cocktail-leader)" stroke-width="0.75"/>',
      );

      // Label text
      svg.add(
        '<text x="${labelX + 2}" y="${labelY + fontSize / 3}" '
        'font-family="system-ui, sans-serif" font-size="${fontSize}px" '
        'fill="var(--cocktail-label)">${_escapeXml(band.name)}</text>',
      );
    }
  }

  static String _escapeXml(String s) =>
      s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
}
