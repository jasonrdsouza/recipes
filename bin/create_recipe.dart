import 'dart:io';
import 'package:args/args.dart';
import 'recipe_parsers.dart';
import 'recipe_writer.dart';
import 'recipe_scraper.dart';

ArgResults argResults;

void main(List<String> arguments) async {
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addOption('name', abbr: 'n', help: 'Name of the recipe to create')
    ..addFlag('draft', abbr: 'd', negatable: false, help: 'Denote this recipe as a draft')
    ..addOption('scrape', abbr: 's', defaultsTo: "", help: 'Link to scrape recipe from')
    ..addFlag('dry-run', negatable: false, help: 'Do a dry run of recipe creation (useful to test out scrapers)');

  argResults = parser.parse(arguments);
  var recipeName = argResults['name'].toString();
  var scrapeSource = argResults['scrape'].toString();
  var isDraft = argResults['draft'] as bool;
  var dryRun = argResults['dry-run'] as bool;

  var writer = RecipeWriter();
  var filepath = writer.pathFromRecipeName(recipeName, isDraft);
  if (writer.fileExists(filepath) && !dryRun) {
    print("File already exists at ${filepath}... not overwriting");
    exitCode = 1;
    return;
  }

  RecipeParser recipe = BlankRecipeParser(recipeName);
  if (scrapeSource != "") {
    var uri = Uri.parse(scrapeSource);
    var scraper = RecipeScraper();
    if (!scraper.isParseable(uri)) {
      print("Unable to scrape provided recipe... using blank template");
    } else {
      print("Scraping recipe from ${uri}");
      recipe = await scraper.scrape(uri);
    }
  }

  print("Creating ${recipeName} recipe template at ${filepath}");
  if (dryRun) {
    print(writer.generateTemplate(recipeName, recipe));
  } else {
    writer.writeTemplate(filepath, recipeName, recipe);
  }

  if (!isDraft && !dryRun) {
    writer.updateIndex(recipeName);
  }
}
