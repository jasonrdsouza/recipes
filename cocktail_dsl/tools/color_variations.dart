import 'dart:io';

/// Generates a gallery of color-treatment variations for three reference cocktails
/// (Banana Boulevardier + Martini + Margarita) side-by-side for comparison.
///
/// Run: dart run tools/color_variations.dart
/// Open: tools/variations/index.html

class Recipe {
  final String id;
  final String name;
  final String outerPath;
  final String clipPath;
  final double liquidX, liquidY, liquidW, liquidH;
  final double fillFraction;
  final double viewX, viewY, viewW, viewH;
  final List<Map<String, Object>> ingredients;
  const Recipe({
    required this.id,
    required this.name,
    required this.outerPath,
    required this.clipPath,
    required this.liquidX,
    required this.liquidY,
    required this.liquidW,
    required this.liquidH,
    required this.fillFraction,
    required this.viewX,
    required this.viewY,
    required this.viewW,
    required this.viewH,
    required this.ingredients,
  });
}

// All paths here use glass-internal coordinates from the catalog (no offset).

// Banana Boulevardier — rocks glass.
const bbRecipe = Recipe(
  id: 'bb',
  name: 'Banana Boulevardier',
  outerPath:
      'M80,100 L90,185 L90,185 Q90,185 90,186 Q90,187 90.5,188 Q91,189 91.5,190 '
      'Q92,191 93,192 Q94,193 95,193.5 Q96,194 97,194.5 Q98,195 99,195 Q100,195 '
      '120,195 Q140,195 141,195 Q142,195 143,194.5 Q144,194 145,193.5 Q146,193 '
      '147,192 Q148,191 148.5,190 Q149,189 149.5,188 Q150,187 150,185 L150,185 '
      'L160,100 Z',
  clipPath:
      'M86,100 L96,175 L96,175 Q96,175 96,176.5 Q96,178 96.5,179.5 Q97,181 98,182 '
      'Q99,183 100,184 Q101,185 102.5,185.5 Q104,186 105.5,186.5 Q107,187 108.5,187 '
      'Q110,187 120,187 Q130,187 131.5,187 Q133,187 134.5,186.5 Q136,186 137.5,185.5 '
      'Q139,185 140,184 Q141,183 142,182 Q143,181 143.5,179.5 Q144,178 144,175 '
      'L144,175 L154,100 Z',
  liquidX: 86, liquidY: 100, liquidW: 68, liquidH: 107,
  fillFraction: 0.7,
  viewX: 60, viewY: 90, viewW: 120, viewH: 120,
  ingredients: [
    {'name': 'Bourbon', 'color': 'B8732A', 'ratio': 1.0},
    {'name': 'Sweet Vermouth', 'color': '6E1F2A', 'ratio': 1.0},
    {'name': 'Campari', 'color': 'C8102E', 'ratio': 0.5},
    {'name': 'Creme de Banane', 'color': 'E8C547', 'ratio': 0.5},
  ],
);

// Martini — V-shape (bowl only part of path for simplicity; using clipPath for liquid).
const mtRecipe = Recipe(
  id: 'mt',
  name: 'Martini',
  outerPath:
      'M70,70 L80,83 Q80,83 85,89.5 Q90,96 95,102.5 Q100,109 105,115.5 '
      'Q110,122 117,130 L117,130 Q117,130 117.5,130.5 Q118,131 118.5,131.5 '
      'Q119,132 119.5,132 Q120,132 120.5,132 Q121,132 121.5,131.5 Q122,131 '
      '123,130 L123,130 Q123,130 126.5,126 Q130,122 135,115.5 Q140,109 '
      '145,102.5 Q150,96 155,89.5 Q160,83 170,70 Z '
      'M118,133 L118,169 L118,205 L122,205 L122,169 L122,133 Z '
      'M118,205 L115,206 L110,207 L104,207 L97,208 L90,208 L90,208 L90,209 '
      'L91,210 L120,210 L149,210 L150,209 L150,208 L150,208 L143,208 L136,207 '
      'L130,207 L125,206 L122,205 Z',
  clipPath:
      'M76,70 L84,80 Q84,80 88,85 Q92,90 96,95 Q100,100 104,105 Q108,110 '
      '116,122 L116,122 Q116,122 116.5,123 Q117,124 117.5,124.5 Q118,125 '
      '119,125.5 Q120,126 121,125.5 Q122,125 122.5,124.5 Q123,124 124,122 '
      'L124,122 Q124,122 128,116 Q132,110 136,105 Q140,100 144,95 Q148,90 '
      '152,85 Q156,80 164,70 Z',
  liquidX: 76, liquidY: 70, liquidW: 88, liquidH: 76,
  fillFraction: 0.8,
  viewX: 50, viewY: 60, viewW: 140, viewH: 160,
  ingredients: [
    {'name': 'Gin', 'color': 'DCE7E3', 'ratio': 2.5},
    {'name': 'Dry Vermouth', 'color': '6E1F2A', 'ratio': 0.5},
  ],
);

// Margarita — double-bowl shape.
const mgRecipe = Recipe(
  id: 'mg',
  name: 'Margarita',
  outerPath:
      'M70,70 L80,85 Q80,85 85,92.5 Q90,100 92.5,101 Q95,102 97.5,103 '
      'Q100,104 102.5,104.5 Q105,105 106.5,110 Q108,115 112,130 L112,130 '
      'Q112,130 112.5,131 Q113,132 114,133 Q115,134 116,134.5 Q117,135 '
      '118.5,135.5 Q120,136 121.5,135.5 Q123,135 124,134.5 Q125,134 '
      '126,133 Q127,132 128,130 L128,130 Q128,130 130,122.5 Q132,115 '
      '133.5,110 Q135,105 137.5,104.5 Q140,104 142.5,103 Q145,102 '
      '147.5,101 Q150,100 155,92.5 Q160,85 170,70 Z '
      'M117,136 L117,170 L117,205 L123,205 L123,170 L123,136 Z '
      'M117,205 L114,206 L109,207 L103,207 L97,208 L90,208 L90,208 '
      'L90,209 L91,210 L120,210 L149,210 L150,209 L150,208 L150,208 '
      'L143,208 L137,207 L131,207 L126,206 L123,205 Z',
  clipPath:
      'M76,70 L85,83 Q85,83 89.5,89.5 Q94,96 96.5,97 Q99,98 101.5,99 '
      'Q104,100 106.5,101 Q109,102 110.5,107 Q112,112 116,125 L116,125 '
      'Q116,125 116.5,126.5 Q117,128 117.5,128.5 Q118,129 118.5,129.5 '
      'Q119,130 119.5,130 Q120,130 120.5,130 Q121,130 121.5,129.5 '
      'Q122,129 122.5,128.5 Q123,128 124,125 L124,125 Q124,125 '
      '126,118.5 Q128,112 129.5,107 Q131,102 133.5,101 Q136,100 '
      '138.5,99 Q141,98 143.5,97 Q146,96 150.5,89.5 Q155,83 164,70 Z',
  liquidX: 76, liquidY: 70, liquidW: 88, liquidH: 80,
  fillFraction: 0.9,
  viewX: 50, viewY: 60, viewW: 140, viewH: 160,
  ingredients: [
    {'name': 'Blanco Tequila', 'color': 'E8D49C', 'ratio': 2.0},
    {'name': 'Cointreau', 'color': 'B8869C', 'ratio': 1.0},
    {'name': 'Lime Juice', 'color': 'E8D130', 'ratio': 0.75},
  ],
);

void main() {
  final dir = Directory('tools/variations');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final variations = <_Variation>[
    _Variation(
      id: '01-sat-1.2-flat',
      label: 'Flat, sat 1.2 (matte baseline)',
      style: BandStyle(flat: true, satBoost: 1.2),
    ),
    _Variation(
      id: '02-sat-1.3-flat',
      label: 'Flat, sat 1.3',
      style: BandStyle(flat: true, satBoost: 1.3),
    ),
    _Variation(
      id: '03-sat-1.4-flat',
      label: 'Flat, sat 1.4',
      style: BandStyle(flat: true, satBoost: 1.4),
    ),
    _Variation(
      id: '04-sat-1.5-flat',
      label: 'Flat, sat 1.5 (max pop)',
      style: BandStyle(flat: true, satBoost: 1.5),
    ),
    _Variation(
      id: '05-sat-1.3-slight-grad',
      label: 'Slight gradient (lighten 0.1), sat 1.3',
      style: BandStyle(lighten: 0.1, darken: 0, satBoost: 1.3),
    ),
    _Variation(
      id: '06-sat-1.3-soft-grad',
      label: 'Soft gradient (lighten 0.15), sat 1.3',
      style: BandStyle(lighten: 0.15, darken: 0.05, satBoost: 1.3),
    ),
    _Variation(
      id: '07-sat-1.4-soft-grad',
      label: 'Soft gradient, sat 1.4',
      style: BandStyle(lighten: 0.15, darken: 0.05, satBoost: 1.4),
    ),
    _Variation(
      id: '08-sat-1.5-soft-grad',
      label: 'Soft gradient, sat 1.5',
      style: BandStyle(lighten: 0.15, darken: 0.05, satBoost: 1.5),
    ),
    _Variation(
      id: '09-sat-1.4-medium-grad',
      label: 'Medium gradient, sat 1.4',
      style: BandStyle(lighten: 0.25, darken: 0.1, satBoost: 1.4),
    ),
    _Variation(
      id: '10-sat-1.4-pop-grad',
      label: 'Pop gradient (lighten 0.3, darken 0.1), sat 1.4',
      style: BandStyle(lighten: 0.3, darken: 0.1, satBoost: 1.4),
    ),
    _Variation(
      id: '11-sat-1.4-bright-top',
      label: 'Bright top (lighten 0.35), sat 1.4',
      style: BandStyle(lighten: 0.35, darken: 0.05, satBoost: 1.4),
    ),
    _Variation(
      id: '12-sat-1.5-diag',
      label: 'Diagonal gradient, sat 1.5',
      style: BandStyle(lighten: 0.2, darken: 0.05, satBoost: 1.5, diagonal: true),
    ),
    _Variation(
      id: '13-sat-1.4-sharp',
      label: 'Sharp pop gradient, sat 1.4',
      style: BandStyle(lighten: 0.3, darken: 0.2, satBoost: 1.4),
    ),
    _Variation(
      id: '14-sat-1.4-borders',
      label: 'Sat 1.4 flat with band borders',
      style: BandStyle(flat: true, satBoost: 1.4, bandBorder: true),
    ),
    _Variation(
      id: '15-sat-1.3-grad-borders',
      label: 'Soft gradient + borders, sat 1.3',
      style: BandStyle(lighten: 0.15, darken: 0.05, satBoost: 1.3, bandBorder: true),
    ),
    _Variation(
      id: '16-sat-1.6-flat',
      label: 'Flat, sat 1.6 (very saturated)',
      style: BandStyle(flat: true, satBoost: 1.6),
    ),
  ];

  final recipes = [bbRecipe, mtRecipe, mgRecipe];

  for (final v in variations) {
    for (final r in recipes) {
      File('${dir.path}/${v.id}-${r.id}.svg')
          .writeAsStringSync(renderSvg(r, v.style, '${r.id}-${v.id}'));
    }
  }

  final cards = variations.map((v) {
    final imgs = recipes
        .map((r) => '<img src="${v.id}-${r.id}.svg" title="${r.name}">')
        .join('');
    return '<div class="card">'
        '<div class="triple">$imgs</div>'
        '<div class="label">${v.label}</div>'
        '<div class="id">${v.id}</div>'
        '</div>';
  }).join('\n');

  final html = '''<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Color Variations</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: white; color: #222; font-family: system-ui, sans-serif; padding: 24px; }
  h1 { text-align: center; margin-bottom: 24px; font-size: 20px; }
  .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(400px, 1fr)); gap: 20px; max-width: 1800px; margin: 0 auto; }
  .card { background: #fafafa; border: 1px solid #e5e5e5; border-radius: 8px; padding: 12px; }
  .triple { display: flex; gap: 6px; }
  .triple img { width: 33%; aspect-ratio: 1 / 1; background: white; border-radius: 4px; display: block; }
  .label { font-size: 13px; color: #222; margin-top: 8px; font-weight: 600; }
  .id { font-size: 11px; color: #888; font-family: monospace; margin-top: 2px; }
</style>
</head>
<body>
<h1>Color Variations — Banana Boulevardier · Martini · Margarita</h1>
<div class="grid">
$cards
</div>
</body>
</html>''';

  File('${dir.path}/index.html').writeAsStringSync(html);
  print('Wrote ${variations.length * recipes.length} SVGs to ${dir.path}/');
  print('Open: ${dir.path}/index.html');
}

String renderSvg(Recipe r, BandStyle s, String prefix) {
  final sb = StringBuffer();
  final totalRatio = r.ingredients.fold<double>(0, (sum, i) => sum + (i['ratio'] as double));

  sb.writeln('<svg xmlns="http://www.w3.org/2000/svg" '
      'viewBox="${r.viewX} ${r.viewY} ${r.viewW} ${r.viewH}">');
  sb.writeln('<defs>');
  sb.writeln('<clipPath id="$prefix-clip"><path d="${r.clipPath}"/></clipPath>');

  const overflow = 20.0;
  final visibleHeight = r.liquidH - overflow;
  final liquidHeight = visibleHeight * r.fillFraction;

  for (var i = 0; i < r.ingredients.length; i++) {
    final color = _applySaturation(r.ingredients[i]['color'] as String, s.satBoost);
    final lighter = _lighten(color, s.lighten);
    final darker = _darken(color, s.darken);
    if (s.flat) continue;
    if (s.diagonal) {
      sb.writeln('<linearGradient id="$prefix-g$i" x1="0" y1="0" x2="1" y2="1">'
          '<stop offset="0%" stop-color="#$lighter" stop-opacity="${s.topOp}"/>'
          '<stop offset="100%" stop-color="#$darker" stop-opacity="${s.botOp}"/>'
          '</linearGradient>');
    } else {
      sb.writeln('<linearGradient id="$prefix-g$i" x1="0" y1="0" x2="0" y2="1">'
          '<stop offset="0%" stop-color="#$lighter" stop-opacity="${s.topOp}"/>'
          '<stop offset="60%" stop-color="#$color" stop-opacity="${s.midOp}"/>'
          '<stop offset="100%" stop-color="#$darker" stop-opacity="${s.botOp}"/>'
          '</linearGradient>');
    }
  }
  sb.writeln('</defs>');

  sb.writeln('<path d="${r.outerPath}" fill="rgba(245,245,250,0.4)" '
      'stroke="rgba(0,0,0,0.55)" stroke-width="3" stroke-linejoin="round"/>');

  sb.writeln('<g clip-path="url(#$prefix-clip)">');
  var currentY = r.liquidY + visibleHeight;
  for (var i = 0; i < r.ingredients.length; i++) {
    final ing = r.ingredients[i];
    final ratio = ing['ratio'] as double;
    final bandH = (ratio / totalRatio) * liquidHeight;
    currentY -= bandH;
    final renderH = i == 0 ? bandH + overflow : bandH;
    final color = _applySaturation(ing['color'] as String, s.satBoost);

    if (s.flat) {
      sb.writeln('<rect x="${r.liquidX}" y="$currentY" width="${r.liquidW}" height="$renderH" '
          'fill="#$color" fill-opacity="${s.topOp}"/>');
    } else {
      sb.writeln('<rect x="${r.liquidX}" y="$currentY" width="${r.liquidW}" height="$renderH" '
          'fill="url(#$prefix-g$i)"/>');
    }
    if (s.bandBorder && i < r.ingredients.length - 1) {
      sb.writeln('<line x1="${r.liquidX}" y1="$currentY" x2="${r.liquidX + r.liquidW}" y2="$currentY" '
          'stroke="rgba(0,0,0,0.15)" stroke-width="0.5"/>');
    }
  }
  sb.writeln('</g>');

  sb.writeln('</svg>');
  return sb.toString();
}

class BandStyle {
  final double lighten;
  final double darken;
  final double topOp;
  final double midOp;
  final double botOp;
  final bool flat;
  final double satBoost;
  final bool bandBorder;
  final bool diagonal;

  const BandStyle({
    this.lighten = 0,
    this.darken = 0,
    this.topOp = 1,
    this.midOp = 1,
    this.botOp = 1,
    this.flat = false,
    this.satBoost = 1.0,
    this.bandBorder = false,
    this.diagonal = false,
  });
}

class _Variation {
  final String id;
  final String label;
  final BandStyle style;
  _Variation({required this.id, required this.label, required this.style});
}

String _lighten(String hex, double factor) {
  final r = int.parse(hex.substring(0, 2), radix: 16);
  final g = int.parse(hex.substring(2, 4), radix: 16);
  final b = int.parse(hex.substring(4, 6), radix: 16);
  return _toHex(
    (r + (255 - r) * factor).round().clamp(0, 255),
    (g + (255 - g) * factor).round().clamp(0, 255),
    (b + (255 - b) * factor).round().clamp(0, 255),
  );
}

String _darken(String hex, double factor) {
  final r = int.parse(hex.substring(0, 2), radix: 16);
  final g = int.parse(hex.substring(2, 4), radix: 16);
  final b = int.parse(hex.substring(4, 6), radix: 16);
  final m = 1 - factor;
  return _toHex((r * m).round().clamp(0, 255), (g * m).round().clamp(0, 255), (b * m).round().clamp(0, 255));
}

String _applySaturation(String hex, double factor) {
  if (factor == 1.0) return hex;
  final r = int.parse(hex.substring(0, 2), radix: 16) / 255;
  final g = int.parse(hex.substring(2, 4), radix: 16) / 255;
  final b = int.parse(hex.substring(4, 6), radix: 16) / 255;
  final lum = 0.299 * r + 0.587 * g + 0.114 * b;
  final nr = lum + (r - lum) * factor;
  final ng = lum + (g - lum) * factor;
  final nb = lum + (b - lum) * factor;
  return _toHex((nr * 255).round().clamp(0, 255), (ng * 255).round().clamp(0, 255), (nb * 255).round().clamp(0, 255));
}

String _toHex(int r, int g, int b) =>
    '${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
