import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

const RECIPE_INDEX_PATH = 'web/index.md';
ArgResults argResults;

void main(List<String> arguments) {
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addOption('name', abbr: 'n', help: 'Name of the recipe to create')
    ..addFlag('draft', abbr: 'd', negatable: false, help: 'Denote this recipe as a draft');

  argResults = parser.parse(arguments);
  var recipeName = argResults['name'].toString();
  var isDraft = argResults['draft'] as bool;
  var filename = recipeName.toLowerCase().replaceAll(' ', '-');
  var filepath = isDraft ? "web/drafts/${filename}.md" : "web/${filename}.md";

  if (fileExists(filepath)) {
    print("File already exists at ${filepath}... not overwriting");
    return;
  }

  print("Creating ${argResults['name']} recipe template at ${filepath}");
  generateRecipeTemplate(filepath, recipeName);

  if (!isDraft) {
    updateIndex(filename);
  }
}

bool fileExists(String filepath) {
  return FileSystemEntity.typeSync(filepath) != FileSystemEntityType.notFound;
}

Future updateIndex(String recipeFilename) async {
  var mdYaml = await File(RECIPE_INDEX_PATH).readAsString();
  var indexData = Map<String, dynamic>.from(loadYaml(mdYaml.substring(4, mdYaml.length - 5)));

  var recipeList = List<String>.from(indexData['recipes']);
  recipeList.add(recipeFilename);
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

Future generateRecipeTemplate(String filepath, String recipeName) async {
  final recipeFile = File(filepath);
  var recipeTemplate = '''
---
title: "${recipeName}"
template: recipe.mustache
time: "X minutes"
makes: "X servings (comment?)"
ingredients:
  - list ingredients here
steps:
  - list steps here
notes:
  - relevant notes about the recipe
basedon:
  - links to inspiration/ original recipe
---
''';

  await recipeFile.writeAsString(recipeTemplate, mode: FileMode.writeOnly);
}
