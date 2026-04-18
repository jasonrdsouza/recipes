import 'dart:io';
import 'package:test/test.dart';
import 'package:cocktail_dsl/cocktail_dsl.dart';

/// Renders a realistic cocktail in each glass type to showcase
/// the full render pipeline as an end user would use it.
void main() {
  final showcaseDir = Directory('test/golden/showcase');

  // Realistic cocktail recipes — one per glass type
  final recipes = <String, String>{
    'highball': '''
# Whiskey Highball
glass: highball
ice: none
method: build

spine:
  2  bourbon
  4  soda-water
''',
    'zombie': '''
# Zombie
glass: zombie
ice: none
method: shake, strain

spine:
  1.5  jamaican-rum
  1.5  demerara-rum
  1    lime-juice
  0.5  grenadine

accent:
  2 dash angostura
''',
    'collins': '''
# Tom Collins
glass: collins
ice: none
method: shake, strain

spine:
  2    gin
  1    lemon-juice
  0.75 simple-syrup
  2    soda-water

garnish: lemon-wheel
''',
    'weizenbier': '''
# Hefeweizen
glass: weizenbier
ice: none
method: build

spine:
  12  hefeweizen
''',
    'pilsner': '''
# Pilsner
glass: pilsner
ice: none
method: build

spine:
  12  czech-pilsner
''',
    'pint': '''
# IPA
glass: pint
ice: none
method: build

spine:
  16  ipa
''',
    'sling': '''
# Singapore Sling
glass: sling
ice: none
method: shake, strain

spine:
  1.5  gin
  0.5  benedictine
  0.5  cointreau
  0.5  grenadine
  2    pineapple-juice
  0.75 lime-juice

accent:
  1 dash angostura

garnish: cherry, orange-wheel
''',
    'pokal': '''
# Aperol Spritz
glass: pokal
ice: none
method: build

spine:
  3  aperol
  3  prosecco
  1  soda-water

garnish: orange-wheel
''',
    'old-fashioned': '''
# Old Fashioned
glass: old-fashioned
ice: none
method: build, stir

spine:
  2     rye
  0.25  demerara-syrup

accent:
  2 dash angostura
  1 dash orange-bitters

garnish: orange-peel (expressed, dropped)
''',
    'rocks': '''
# Negroni
glass: rocks
ice: none
method: build, stir

spine:
  1  gin
  1  campari
  1  sweet-vermouth

garnish: orange-peel (expressed)
''',
    'tumbler': '''
# Rum & Coke
glass: tumbler
ice: none
method: build

spine:
  2  aged-rum
  4  cola
''',
    'nick-nora': '''
# Bamboo
glass: nick-nora
ice: none
method: stir, strain

spine:
  1.5  dry-sherry
  1.5  dry-vermouth

accent:
  1 dash orange-bitters
  1 dash angostura
''',
    'martini': '''
# Martini
glass: martini
ice: none
method: stir, strain

spine:
  2.5  gin
  0.5  dry-vermouth

accent:
  1 dash orange-bitters

garnish: olive
''',
    'margarita': '''
# Margarita
glass: margarita
ice: none
method: shake, strain

spine:
  2     blanco-tequila
  1     cointreau
  0.75  lime-juice

garnish: lime-wheel, salt-rim
''',
    'hurricane': '''
# Hurricane
glass: hurricane
ice: none
method: shake, strain

spine:
  2    aged-rum
  1    lime-juice
  1    orange-juice
  0.5  grenadine
  0.5  simple-syrup
''',
    'poco-grande': '''
# Pina Colada
glass: poco-grande
ice: none
method: blend

spine:
  2    white-rum
  1.5  coconut-cream
  1.5  pineapple-juice
  0.5  lime-juice
''',
    'sour': '''
# Whiskey Sour
glass: sour
ice: none
method: shake, strain

spine:
  2     bourbon
  0.75  lemon-juice
  0.75  simple-syrup

accent:
  2 dash angostura

garnish: cherry
''',
    'milkshake': '''
# Mudslide
glass: milkshake
ice: none
method: blend

spine:
  1.5  vodka
  1.5  coffee-liqueur
  1.5  irish-cream
  2    cream
''',
    'red-wine': '''
# Cabernet Sauvignon
glass: red-wine
ice: none
method: build

spine:
  6  cabernet-sauvignon
''',
    'white-wine': '''
# Chardonnay
glass: white-wine
ice: none
method: build

spine:
  6  chardonnay
''',
    'rose-wine': '''
# Rose
glass: rose-wine
ice: none
method: build

spine:
  6  provence-rose
''',
    'sherry': '''
# Fino Sherry
glass: sherry
ice: none
method: build

spine:
  3  dry-sherry
''',
    'balloon': '''
# Gin & Tonic
glass: balloon
ice: none
method: build

spine:
  2  gin
  5  tonic-water

garnish: lime-wedge
''',
    'flute': '''
# French 75
glass: flute
ice: none
method: shake, strain

spine:
  1    gin
  0.5  lemon-juice
  0.5  simple-syrup
  3    champagne
''',
    'coupe': '''
# Daiquiri
glass: coupe
ice: none
method: shake, double-strain

spine:
  2     white-rum
  1     lime-juice
  0.75  simple-syrup
''',
    'goblet': '''
# Sangria
glass: goblet
ice: none
method: build

spine:
  4  tempranillo
  1  cointreau
  1  orange-juice
  1  simple-syrup
''',
    'snifter': '''
# Cognac Neat
glass: snifter
ice: none
method: build

spine:
  2  cognac
''',
    'tulip': '''
# Sazerac
glass: tulip
ice: none
method: stir, strain

prep:
  rinse absinthe

spine:
  2     rye
  0.25  demerara-syrup

accent:
  3 dash peychauds
  1 dash angostura

garnish: lemon-peel (expressed, discarded)
''',
    'nosing': '''
# Scotch Neat
glass: nosing
ice: none
method: build

spine:
  2  scotch

notes: Add a few drops of water to open up the aromas.
''',
    'pousse-cafe': '''
# B-52
glass: pousse-cafe
ice: none
method: build

spine:
  1  coffee-liqueur
  1  irish-cream
  1  cointreau
''',
    'grappa': '''
# Grappa Digestif
glass: grappa
ice: none
method: build

spine:
  2  grappa-spirit
''',
    'liqueur': '''
# Amaretto
glass: liqueur
ice: none
method: build

spine:
  2  amaretto
''',
    'shot': '''
# Tequila Shot
glass: shot
ice: none
method: build

spine:
  1.5  blanco-tequila
''',
  };

  setUpAll(() {
    if (!showcaseDir.existsSync()) showcaseDir.createSync(recursive: true);
  });

  group('Showcase', () {
    for (final entry in recipes.entries) {
      test('${entry.key}', () {
        final recipe = CocktailParser.parse(entry.value);
        final svg = CocktailRenderer.render(recipe);

        expect(svg, contains('<svg'));
        expect(svg, contains('</svg>'));

        File('${showcaseDir.path}/${entry.key}.svg').writeAsStringSync(svg);
      });
    }

    test('generate gallery HTML', () {
      final cards = StringBuffer();
      for (final entry in recipes.entries) {
        final id = entry.key;
        // Parse to get the title
        final recipe = CocktailParser.parse(entry.value);
        cards.writeln(
          '  <div class="card">'
          '<div class="svg-wrap"><img src="$id.svg"></div>'
          '<div class="label">${recipe.title}</div>'
          '<div class="glass-type">$id</div>'
          '</div>',
        );
      }

      final html = '''<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Cocktail Showcase</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: #1a1a2e; color: #ccc; font-family: system-ui, sans-serif; padding: 24px; }
  h1 { text-align: center; margin-bottom: 32px; font-size: 20px; color: #888; text-transform: uppercase; letter-spacing: 2px; }
  .gallery { max-width: 700px; margin: 0 auto; display: flex; flex-direction: column; gap: 32px; }
  .card { background: #16213e; border-radius: 12px; padding: 16px; text-align: center; }
  .svg-wrap { width: 100%; }
  .svg-wrap img { width: 100%; }
  .label { font-size: 18px; color: #eee; margin-top: 8px; font-weight: 600; }
  .glass-type { font-size: 12px; color: #666; margin-top: 2px; }
</style>
</head>
<body>
<h1>Cocktail Showcase (${recipes.length})</h1>
<div class="gallery">
${cards.toString()}</div>
</body>
</html>''';

      File('${showcaseDir.path}/index.html').writeAsStringSync(html);
    });
  });
}
