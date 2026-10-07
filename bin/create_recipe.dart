import 'dart:io';
import 'package:args/args.dart';
import 'recipe_writer.dart';

/// Scaffolds a new recipe file and adds it to the index.
///
/// The generated file is placeholder text throughout; fill it in from the
/// details the user gives you, then check it with bin/validate_recipes.dart.
void main(List<String> arguments) async {
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addOption('name', abbr: 'n', help: 'Name of the recipe to create')
    ..addFlag('draft', abbr: 'd', negatable: false, help: 'Denote this recipe as a draft')
    ..addFlag('dry-run', negatable: false, help: 'Print the template instead of writing it');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } on FormatException catch (e) {
    // Notably --scrape, which this tool used to accept. Fetch source recipes
    // yourself and draft from them instead.
    print('${e.message}\n');
    print(parser.usage);
    exitCode = 1;
    return;
  }

  var recipeName = argResults['name'] as String?;
  var isDraft = argResults['draft'] as bool;
  var dryRun = argResults['dry-run'] as bool;

  if (recipeName == null || recipeName.trim().isEmpty) {
    print('Missing required --name option.\n');
    print(parser.usage);
    exitCode = 1;
    return;
  }

  var writer = RecipeWriter();
  var filepath = writer.pathFromRecipeName(recipeName, isDraft);
  if (writer.fileExists(filepath) && !dryRun) {
    print("File already exists at ${filepath}... not overwriting");
    exitCode = 1;
    return;
  }

  print("Creating ${recipeName} recipe template at ${filepath}");
  if (dryRun) {
    print(writer.generateTemplate(recipeName));
    return;
  }

  await writer.writeTemplate(filepath, recipeName);
  if (!isDraft) {
    await writer.updateIndex(recipeName);
  }
}
