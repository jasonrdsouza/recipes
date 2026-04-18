import 'package:test/test.dart';
import 'package:cocktail_dsl/cocktail_dsl.dart';

void main() {
  group('Catalog', () {
    final catalog = Catalog();

    test('every ingredient has a unique id', () {
      final ids = catalog.all.map((i) => i.id).toSet();
      expect(ids.length, catalog.all.length);
    });

    test('every alias resolves uniquely', () {
      for (final ingredient in catalog.all) {
        for (final alias in ingredient.aliases) {
          final resolved = catalog.byAlias(alias);
          expect(resolved, isNotNull,
              reason: 'Alias "$alias" for ${ingredient.id} should resolve');
          expect(resolved!.id, ingredient.id,
              reason: 'Alias "$alias" should resolve to ${ingredient.id}');
        }
      }
    });

    test('every ingredient has a valid hex color', () {
      final hexPattern = RegExp(r'^[0-9A-Fa-f]{6}$');
      for (final ingredient in catalog.all) {
        expect(hexPattern.hasMatch(ingredient.color), isTrue,
            reason: '${ingredient.id} has invalid color: ${ingredient.color}');
      }
    });

    test('byId finds known ingredients', () {
      expect(catalog.byId('rye'), isNotNull);
      expect(catalog.byId('rye')!.name, 'Rye');
    });

    test('byId returns null for unknown', () {
      expect(catalog.byId('unobtainium'), isNull);
    });

    test('byAlias resolves common aliases', () {
      final rye = catalog.byAlias('rye whiskey');
      expect(rye, isNotNull);
      expect(rye!.id, 'rye');
    });

    test('core glass types exist', () {
      final coreGlasses = [
        'old-fashioned', 'rocks', 'tumbler', 'highball', 'collins',
        'martini', 'nick-nora', 'margarita', 'coupe', 'sour',
        'hurricane', 'poco-grande', 'sling', 'pilsner', 'pint',
        'red-wine',
      ];
      for (final id in coreGlasses) {
        expect(catalog.glassById(id), isNotNull, reason: 'Glass $id should exist');
      }
    });

    test('required ice types exist', () {
      for (final id in ['none', 'large-cube']) {
        expect(catalog.iceById(id), isNotNull, reason: 'Ice $id should exist');
      }
    });

    test('fill fraction returns glass default for unknown combo', () {
      final frac = catalog.fillFraction('rocks', 'some-unknown-ice');
      expect(frac, 0.5); // rocks default
    });

    test('catalog has mandatory color overrides', () {
      final overrides = {
        'campari': 'C8102E',
        'aperol': 'FF6B1A',
        'green-chartreuse': '4A7C2E',
        'angostura': '8B2C2C',
        'peychauds': 'C83E3E',
      };
      for (final entry in overrides.entries) {
        final ingredient = catalog.byId(entry.key);
        if (ingredient != null) {
          expect(ingredient.color, entry.value,
              reason: '${entry.key} should have color override ${entry.value}');
        }
      }
    });
  });
}
