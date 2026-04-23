import 'dart:async';

import 'package:build/build.dart';
import 'package:cocktail_dsl/cocktail_dsl.dart';
import 'package:yaml/yaml.dart';

/// A build_runner builder that reads recipe markdown files, extracts an
/// optional `cocktail:` field from the YAML frontmatter, and emits a
/// rendered SVG diagram as `{slug}.cocktail.svg` next to the markdown.
Builder cocktailSvgBuilder(BuilderOptions _) => CocktailSvgBuilder();

class CocktailSvgBuilder implements Builder {
  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final contents = await buildStep.readAsString(inputId);

    final cocktailSource = _extractCocktailField(contents);
    if (cocktailSource == null) return;

    try {
      final recipe = CocktailParser.parse(cocktailSource);
      final svg = CocktailRenderer.render(recipe);
      final outputId = inputId.changeExtension('.cocktail.svg');
      await buildStep.writeAsString(outputId, svg);
    } on ParseException catch (e) {
      log.warning(
          'Skipped cocktail diagram for ${inputId.path}: ${e.message} '
          '(line ${e.line})');
    } catch (e) {
      log.warning('Failed to render cocktail in ${inputId.path}: $e');
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.md': ['.cocktail.svg'],
      };

  /// Extracts the `cocktail` field from the YAML frontmatter of a markdown
  /// file. Returns null if no frontmatter, no cocktail field, or parse error.
  static String? _extractCocktailField(String fileContents) {
    const separator = '---';
    final lines = fileContents.split('\n');
    if (lines.isEmpty || !lines.first.startsWith(separator)) return null;

    int? closing;
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].startsWith(separator)) {
        closing = i;
        break;
      }
    }
    if (closing == null) return null;

    final yamlStr = lines.getRange(1, closing).join('\n');
    try {
      final yaml = loadYaml(yamlStr);
      if (yaml is! Map) return null;
      final cocktail = yaml['cocktail'];
      if (cocktail is String && cocktail.trim().isNotEmpty) return cocktail;
    } catch (_) {
      return null;
    }
    return null;
  }
}
