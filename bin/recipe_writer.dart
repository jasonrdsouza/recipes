import 'dart:io';
import 'dart:convert';
import 'package:yaml/yaml.dart';
import './recipe_parsers.dart';

class RecipeWriter {
  static const RECIPE_INDEX_PATH = 'web/index.md';

  bool fileExists(String filepath) {
    return FileSystemEntity.typeSync(filepath) != FileSystemEntityType.notFound;
  }

  String fileNameFromRecipeName(String recipeName) {
    return recipeName.toLowerCase().replaceAll(' ', '-');
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

  String generateTemplate(String recipeName, RecipeParser parsedRecipe) {
    var ingredientsPartial = parsedRecipe.parsedIngredients().join('\n  - ');
    var stepsPartial = parsedRecipe.parsedSteps().join('\n  - ');
    var sourcePartial =
        parsedRecipe.source() == null ? '' : '\n  - "[${parsedRecipe.parsedName()}](${parsedRecipe.source()})"';
    return '''
---
title: "${recipeName}"
template: recipe.mustache
time: "${parsedRecipe.parsedTime()} minutes"
makes: "${parsedRecipe.parsedServings()} servings"
ingredients:
  - ${ingredientsPartial}
steps:
  - ${stepsPartial}
notes:
  - relevant notes about the recipe
basedon: ${sourcePartial}
---
''';
  }

  Future writeTemplate(String filepath, String recipeName, RecipeParser parsedRecipe) async {
    final recipeFile = File(filepath);
    var recipeTemplate = generateTemplate(recipeName, parsedRecipe);
    await recipeFile.writeAsString(recipeTemplate, mode: FileMode.writeOnly);
  }
}
