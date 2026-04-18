import 'dart:io';
import 'package:test/test.dart';
import 'package:cocktail_dsl/cocktail_dsl.dart';

/// Renders a minimal recipe in every glass type to produce golden SVGs
/// for visual verification of all 42 glass silhouettes.
void main() {
  final catalog = Catalog();

  // Minimal recipe template — just rye in each glass
  String minimalRecipe(String glassId) => '''
# Gallery: $glassId
glass: $glassId
ice: none
method: stir

spine:
  2  rye
  1  sweet-vermouth
''';

  final goldenDir = Directory('test/golden/gallery');

  setUpAll(() {
    if (!goldenDir.existsSync()) goldenDir.createSync(recursive: true);
  });

  group('Glass gallery', () {
    for (final glass in catalog.all.isEmpty ? <Glass>[] : _allGlasses(catalog)) {
      test('renders ${glass.id}', () {
        final source = minimalRecipe(glass.id);
        final recipe = CocktailParser.parse(source);
        final svg = CocktailRenderer.render(recipe);

        expect(svg, contains('<svg'));
        expect(svg, contains('</svg>'));

        File('${goldenDir.path}/${glass.id}.svg').writeAsStringSync(svg);
      });
    }
  });
}

List<Glass> _allGlasses(Catalog catalog) {
  // Dynamically get all glasses from the catalog
  return catalog.glasses;
}
