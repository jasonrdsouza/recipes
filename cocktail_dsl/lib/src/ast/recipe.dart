import '../catalog/catalog.dart';

/// Cocktail Codex family classification.
enum CodexFamily {
  oldFashioned,
  martini,
  daiquiri,
  sidecar,
  whiskyHighball,
  flip,
}

/// Volume/measurement unit.
enum Unit {
  oz,
  ml,
  cl,
  dash,
  drop,
  bsp,
  tsp,
  tbsp,
  pinch,
  rinse,
  float,
}

/// Reference to an ingredient, either known (in catalog) or unknown (freeform).
sealed class IngredientRef {
  const IngredientRef();

  String get displayName;
  String get color;
}

class KnownIngredient extends IngredientRef {
  final Ingredient entry;

  const KnownIngredient(this.entry);

  @override
  String get displayName => entry.name;

  @override
  String get color => entry.color;
}

class UnknownIngredient extends IngredientRef {
  final String originalText;

  const UnknownIngredient(this.originalText);

  @override
  String get displayName => originalText;

  @override
  String get color => 'C8C8C8';
}

/// The spine of a cocktail — ratio-based core ingredients.
class Spine {
  final Unit baseUnit;
  final double baseAmount;
  final List<SpineLine> lines;

  const Spine({
    this.baseUnit = Unit.oz,
    this.baseAmount = 1.0,
    required this.lines,
  });
}

class SpineLine {
  final double ratio;
  final IngredientRef ingredient;

  const SpineLine({required this.ratio, required this.ingredient});
}

/// Non-scaling accent ingredients (dashes, drops, barspoons, etc.).
class AccentLine {
  final int amount;
  final Unit unit;
  final IngredientRef ingredient;

  const AccentLine({
    required this.amount,
    required this.unit,
    required this.ingredient,
  });
}

/// Garnish with optional modifiers.
class Garnish {
  final String text;
  final String? modifiers;

  const Garnish({required this.text, this.modifiers});
}

/// Preparation step that happens before the main build.
sealed class PrepStep {
  const PrepStep();

  String get verb;
  String get target;
}

class RinseStep extends PrepStep {
  final IngredientRef ingredient;

  const RinseStep(this.ingredient);

  @override
  String get verb => 'rinse';

  @override
  String get target => ingredient.displayName;
}

class ChillStep extends PrepStep {
  final String what;

  const ChillStep(this.what);

  @override
  String get verb => 'chill';

  @override
  String get target => what;
}

class MuddleStep extends PrepStep {
  final IngredientRef ingredient;

  const MuddleStep(this.ingredient);

  @override
  String get verb => 'muddle';

  @override
  String get target => ingredient.displayName;
}

class FlameStep extends PrepStep {
  final IngredientRef ingredient;

  const FlameStep(this.ingredient);

  @override
  String get verb => 'flame';

  @override
  String get target => ingredient.displayName;
}

class SmokeStep extends PrepStep {
  final IngredientRef ingredient;

  const SmokeStep(this.ingredient);

  @override
  String get verb => 'smoke';

  @override
  String get target => ingredient.displayName;
}

/// A method step (shake, stir, strain, etc.).
class MethodStep {
  final String verb;

  const MethodStep(this.verb);
}

/// Full parsed cocktail recipe.
class Recipe {
  final String title;
  final CodexFamily? family;
  final Glass glass;
  final Ice ice;
  final List<MethodStep> method;
  final List<PrepStep> prep;
  final Spine spine;
  final List<AccentLine> accent;
  final List<Garnish> garnishes;
  final Map<String, String> metadata;

  const Recipe({
    required this.title,
    this.family,
    required this.glass,
    required this.ice,
    required this.method,
    this.prep = const [],
    required this.spine,
    this.accent = const [],
    this.garnishes = const [],
    this.metadata = const {},
  });
}
