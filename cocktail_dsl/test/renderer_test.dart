import 'dart:io';
import 'package:test/test.dart';
import 'package:cocktail_dsl/cocktail_dsl.dart';

void main() {
  group('CocktailRenderer', () {
    test('renders Old Fashioned to valid SVG', () {
      final source = File('test/fixtures/old_fashioned.cocktail').readAsStringSync();
      final recipe = CocktailParser.parse(source);
      final svg = CocktailRenderer.render(recipe);

      expect(svg, contains('<svg xmlns="http://www.w3.org/2000/svg" viewBox="'));
      expect(svg, contains('</svg>'));
      // Should have glass silhouette (theme-aware fill)
      expect(svg, contains('var(--cocktail-glass-fill)'));
      // Should have liquid bands with gradients
      expect(svg, contains('linearGradient'));
      // Should have clip-path
      expect(svg, contains('clipPath'));
      // Should have ingredient labels
      expect(svg, contains('Rye'));
      expect(svg, contains('Demerara Syrup'));
      // Should have accent dots
      expect(svg, contains('Angostura'));
      // Should have leader lines
      expect(svg, contains('<path d="M'));
    });

    test('renders minimal recipe without accents/garnish', () {
      final source = '''
# Minimal
glass: rocks
ice: none
method: stir

spine:
  2  rye
''';
      final recipe = CocktailParser.parse(source);
      final svg = CocktailRenderer.render(recipe);

      expect(svg, contains('<svg'));
      expect(svg, contains('Rye'));
      // No accent dots
      expect(svg, isNot(contains('circle cx=')));
    });

    test('renders unknown ingredients with gray/dashed style', () {
      final source = '''
# Unknown Test
glass: rocks
ice: none
method: stir

spine:
  2  mystery-liquor
''';
      final recipe = CocktailParser.parse(source);
      final svg = CocktailRenderer.render(recipe);

      expect(svg, contains('#C8C8C8'));
      expect(svg, contains('stroke-dasharray="4 2"'));
    });

    test('SVG output ends with newline', () {
      final source = '''
# Test
glass: rocks
ice: none
method: stir
spine:
  2  rye
''';
      final recipe = CocktailParser.parse(source);
      final svg = CocktailRenderer.render(recipe);
      expect(svg.endsWith('\n'), isTrue);
    });

    test('write Old Fashioned SVG to golden file', () {
      final source = File('test/fixtures/old_fashioned.cocktail').readAsStringSync();
      final recipe = CocktailParser.parse(source);
      final svg = CocktailRenderer.render(recipe);

      // Write golden file for manual inspection
      final goldenFile = File('test/golden/old_fashioned.svg');
      goldenFile.writeAsStringSync(svg);

      expect(goldenFile.existsSync(), isTrue);
    });
  });
}
