import 'dart:io';
import 'dart:convert';
import 'package:yaml/yaml.dart';

class RecipeWriter {
  static const RECIPE_INDEX_PATH = 'web/index.md';

  bool fileExists(String filepath) {
    return FileSystemEntity.typeSync(filepath) != FileSystemEntityType.notFound;
  }

  String fileNameFromRecipeName(String recipeName) {
    return recipeName.toLowerCase().replaceAll('#', '').replaceAll(' & ', ' and ').replaceAll(' ', '-');
  }

  String pathFromRecipeName(String recipeName, bool isDraft) {
    var filename = fileNameFromRecipeName(recipeName);
    return isDraft ? "web/drafts/${filename}.md" : "web/${filename}.md";
  }

  Future updateIndex(String recipeName) async {
    var mdYaml = await File(RECIPE_INDEX_PATH).readAsString();
    var indexData = Map<String, dynamic>.from(loadYaml(mdYaml.substring(4, mdYaml.length - 5)));

    var recipeList = List<String>.from(indexData['recipes']);
    recipeList.add(fileNameFromRecipeName(recipeName));
    recipeList.sort();

    indexData['recipes'] = recipeList;

    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String prettyPrintedIndexData = encoder.convert(indexData);
    var indexFileContents = '''
---
${prettyPrintedIndexData}
---
''';
    await File(RECIPE_INDEX_PATH).writeAsString(indexFileContents, mode: FileMode.writeOnly);
  }

  /// A blank recipe. Every value is a placeholder that bin/validate_recipes.dart
  /// rejects, so an unfinished scaffold cannot reach the site unnoticed.
  String generateTemplate(String recipeName) {
    return '''
---
title: "${recipeName}"
template: recipe.mustache
time: "? minutes"
makes: "? servings"
ingredients:
  - Add ingredients
  - over here
steps:
  - Add steps
  - over here
notes:
  - relevant notes about the recipe
basedon:
  - source or inspiration for this recipe
---
''';
  }

  Future writeTemplate(String filepath, String recipeName) async {
    final recipeFile = File(filepath);
    var recipeTemplate = generateTemplate(recipeName);
    await recipeFile.writeAsString(recipeTemplate, mode: FileMode.writeOnly);
  }
}
