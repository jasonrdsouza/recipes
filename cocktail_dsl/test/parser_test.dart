import 'dart:io';
import 'package:test/test.dart';
import 'package:cocktail_dsl/cocktail_dsl.dart';

void main() {
  group('CocktailParser', () {
    test('parses Old Fashioned fixture', () {
      final source = File('test/fixtures/old_fashioned.cocktail').readAsStringSync();
      final recipe = CocktailParser.parse(source);

      expect(recipe.title, 'Old Fashioned');
      expect(recipe.family, CodexFamily.oldFashioned);
      expect(recipe.glass.id, 'rocks');
      expect(recipe.ice.id, 'large-cube');
      expect(recipe.method.length, 2);
      expect(recipe.method[0].verb, 'build');
      expect(recipe.method[1].verb, 'stir');

      // Spine
      expect(recipe.spine.baseUnit, Unit.oz);
      expect(recipe.spine.baseAmount, 1.0);
      expect(recipe.spine.lines.length, 2);
      expect(recipe.spine.lines[0].ratio, 2.0);
      expect(recipe.spine.lines[0].ingredient.displayName, 'Rye');
      expect(recipe.spine.lines[1].ratio, 0.25);
      expect(recipe.spine.lines[1].ingredient.displayName, 'Demerara Syrup');

      // Accent
      expect(recipe.accent.length, 2);
      expect(recipe.accent[0].amount, 2);
      expect(recipe.accent[0].unit, Unit.dash);
      expect(recipe.accent[0].ingredient.displayName, 'Angostura Bitters');
      expect(recipe.accent[1].amount, 1);
      expect(recipe.accent[1].unit, Unit.dash);
      expect(recipe.accent[1].ingredient.displayName, 'Orange Bitters');

      // Garnish
      expect(recipe.garnishes.length, 1);
      expect(recipe.garnishes[0].text, 'orange-peel');
      expect(recipe.garnishes[0].modifiers, 'expressed, dropped');
    });

    test('parses minimal recipe', () {
      final source = '''
# Test Drink
glass: rocks
ice: none
method: stir

spine:
  2  rye
''';
      final recipe = CocktailParser.parse(source);
      expect(recipe.title, 'Test Drink');
      expect(recipe.spine.lines.length, 1);
      expect(recipe.garnishes, isEmpty);
      expect(recipe.accent, isEmpty);
      expect(recipe.prep, isEmpty);
    });

    test('parses spine with custom base unit', () {
      final source = '''
# Equal Parts
glass: coupe
ice: none
method: shake, double-strain

spine (0.75 oz):
  1  gin
  1  green-chartreuse
  1  maraschino
  1  lime-juice
''';
      final recipe = CocktailParser.parse(source);
      expect(recipe.spine.baseAmount, 0.75);
      expect(recipe.spine.baseUnit, Unit.oz);
      expect(recipe.spine.lines.length, 4);
    });

    test('parses prep section with catalog resolution', () {
      final source = '''
# Sazerac
glass: rocks
ice: none
method: stir, strain

prep:
  rinse absinthe

spine:
  2     rye
  0.25  demerara-syrup

accent:
  3 dash  peychauds
  1 dash  angostura

garnish: lemon-peel (expressed, discarded)
''';
      final recipe = CocktailParser.parse(source);
      expect(recipe.prep.length, 1);
      expect(recipe.prep[0].verb, 'rinse');
      // absinthe is in the catalog, so should resolve to known ingredient
      expect(recipe.prep[0].target, 'Absinthe');
    });

    test('parses fraction numbers', () {
      final source = '''
# Fraction Test
glass: rocks
ice: none
method: stir

spine:
  2    rye
  3/4  sweet-vermouth
''';
      final recipe = CocktailParser.parse(source);
      expect(recipe.spine.lines[1].ratio, 0.75);
    });

    test('parses multiple garnishes', () {
      final source = '''
# Multi Garnish
glass: rocks
ice: none
method: build

spine:
  2  rye

garnish: orange-peel (expressed), cherry
''';
      final recipe = CocktailParser.parse(source);
      expect(recipe.garnishes.length, 2);
      expect(recipe.garnishes[0].text, 'orange-peel');
      expect(recipe.garnishes[0].modifiers, 'expressed');
      expect(recipe.garnishes[1].text, 'cherry');
      expect(recipe.garnishes[1].modifiers, isNull);
    });

    test('throws on missing title', () {
      final source = '''
glass: rocks
ice: none
method: stir
spine:
  2  rye
''';
      expect(() => CocktailParser.parse(source), throwsA(isA<ParseException>()));
    });

    test('throws on unknown glass', () {
      final source = '''
# Test
glass: invisible-chalice
ice: none
method: stir
spine:
  2  rye
''';
      expect(() => CocktailParser.parse(source), throwsA(isA<ParseException>()));
    });

    test('throws on unknown method', () {
      final source = '''
# Test
glass: rocks
ice: none
method: stir, levitate
spine:
  2  rye
''';
      expect(() => CocktailParser.parse(source), throwsA(isA<ParseException>()));
    });

    test('throws on empty spine', () {
      final source = '''
# Test
glass: rocks
ice: none
method: stir
spine:
''';
      expect(() => CocktailParser.parse(source), throwsA(isA<ParseException>()));
    });

    test('resolves unknown ingredients as freeform', () {
      final source = '''
# Test
glass: rocks
ice: none
method: stir
spine:
  2  made-up-spirit
''';
      final recipe = CocktailParser.parse(source);
      expect(recipe.spine.lines[0].ingredient, isA<UnknownIngredient>());
      expect(recipe.spine.lines[0].ingredient.color, 'C8C8C8');
    });

    test('handles comments', () {
      final source = '''
# Test // not part of title
glass: rocks
ice: none
method: stir

spine:
  2  rye // the good stuff
''';
      final recipe = CocktailParser.parse(source);
      expect(recipe.title, 'Test');
      expect(recipe.spine.lines.length, 1);
    });

    test('stores unknown top-level keys as metadata', () {
      final source = '''
# Test
glass: rocks
ice: none
method: stir
source: Some Book
author: A Person

spine:
  2  rye
''';
      final recipe = CocktailParser.parse(source);
      expect(recipe.metadata['source'], 'Some Book');
      expect(recipe.metadata['author'], 'A Person');
    });
  });
}
