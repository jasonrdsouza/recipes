import 'ingredients.dart';

/// Category of a cocktail ingredient.
enum Category {
  whiskey,
  gin,
  rum,
  agave,
  brandy,
  vodka,
  otherSpirit,
  wine,
  fortifiedWine,
  beer,
  liqueur,
  amaro,
  citrus,
  sweetener,
  bitters,
  accent,
}

/// A cataloged ingredient with color and alias information.
class Ingredient {
  final String id;
  final String name;
  final Category category;
  final String color; // hex, no '#'
  final List<String> aliases;
  final String? notes;

  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    this.aliases = const [],
    this.notes,
  });
}

/// Glass metadata with SVG rendering data.
class Glass {
  final String id;
  final String name;
  final String svgPath; // silhouette path data, centered in 240x240 region
  final Rect liquidBounds; // where the liquid rectangle lives
  final String clipPathData; // interior region for clip-path
  final double defaultFillFraction;

  const Glass({
    required this.id,
    required this.name,
    required this.svgPath,
    required this.liquidBounds,
    required this.clipPathData,
    this.defaultFillFraction = 0.6,
  });
}

/// Simple rectangle for layout.
class Rect {
  final double x;
  final double y;
  final double width;
  final double height;

  const Rect(this.x, this.y, this.width, this.height);

  double get bottom => y + height;
  double get right => x + width;
}

/// Ice type metadata with SVG rendering data.
class Ice {
  final String id;
  final String name;
  final String svgFragment; // path(s) for rendering

  const Ice({
    required this.id,
    required this.name,
    required this.svgFragment,
  });
}

/// Lookup table for ingredient, glass, and ice data.
class Catalog {
  final Map<String, Ingredient> _byId = {};
  final Map<String, Ingredient> _byAlias = {};
  final Map<String, Glass> _glasses = {};
  final Map<String, Ice> _iceTypes = {};
  final Map<String, double> _fillLines = {};

  static final Catalog _instance = Catalog._build();

  factory Catalog() => _instance;

  Catalog._build() {
    for (final ingredient in allIngredients) {
      _byId[ingredient.id] = ingredient;
      for (final alias in ingredient.aliases) {
        _byAlias[alias.toLowerCase()] = ingredient;
      }
    }
    for (final glass in allGlasses) {
      _glasses[glass.id] = glass;
    }
    for (final ice in allIceTypes) {
      _iceTypes[ice.id] = ice;
    }
    for (final entry in allFillLines.entries) {
      _fillLines[entry.key] = entry.value;
    }
  }

  Ingredient? byId(String id) => _byId[id.toLowerCase()];

  Ingredient? byAlias(String raw) {
    final lower = raw.toLowerCase();
    return _byAlias[lower] ?? _byId[lower];
  }

  Iterable<Ingredient> get all => _byId.values;

  Glass? glassById(String id) => _glasses[id.toLowerCase()];

  List<Glass> get glasses => _glasses.values.toList();

  Ice? iceById(String id) => _iceTypes[id.toLowerCase()];

  double fillFraction(String glassId, String iceId) {
    final key = '${glassId.toLowerCase()}:${iceId.toLowerCase()}';
    if (_fillLines.containsKey(key)) return _fillLines[key]!;
    final glass = glassById(glassId);
    return glass?.defaultFillFraction ?? 0.6;
  }
}
