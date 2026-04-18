import 'dart:io';
import 'package:test/test.dart';
import 'package:cocktail_dsl/cocktail_dsl.dart';

/// Tests that all fixture .cocktail files parse and render successfully.
void main() {
  final fixtureDir = Directory('test/fixtures');
  final fixtures = fixtureDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.cocktail'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  group('Integration: parse + render all fixtures', () {
    for (final fixture in fixtures) {
      final name = fixture.uri.pathSegments.last.replaceAll('.cocktail', '');

      test('$name parses successfully', () {
        final source = fixture.readAsStringSync();
        final recipe = CocktailParser.parse(source);
        expect(recipe.title, isNotEmpty);
        expect(recipe.spine.lines, isNotEmpty);
      });

      test('$name renders to valid SVG', () {
        final source = fixture.readAsStringSync();
        final recipe = CocktailParser.parse(source);
        final svg = CocktailRenderer.render(recipe);

        expect(svg, contains('<svg xmlns="http://www.w3.org/2000/svg"'));
        expect(svg, contains('</svg>'));
        expect(svg, contains('clipPath'));
        expect(svg.endsWith('\n'), isTrue);

        // Write golden file
        final goldenFile = File('test/golden/$name.svg');
        goldenFile.writeAsStringSync(svg);
      });
    }
  });
}
