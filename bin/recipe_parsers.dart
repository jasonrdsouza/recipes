import 'dart:convert';

import 'package:html/dom.dart';

abstract class RecipeParser {
  String parsedName();
  String parsedTime();
  String parsedServings();
  Uri source();
  List<String> parsedIngredients();
  List<String> parsedSteps();
}

class BlankRecipeParser implements RecipeParser {
  final String recipeName;

  BlankRecipeParser(this.recipeName);

  String parsedName() {
    return this.recipeName;
  }

  List<String> parsedIngredients() {
    return ['Add ingredients', 'over here'];
  }

  String parsedServings() {
    return '?';
  }

  List<String> parsedSteps() {
    return ['Add steps', 'over here'];
  }

  String parsedTime() {
    return '?';
  }

  Uri source() {
    return Uri.base;
  }
}

class RecipeSchemaParser implements RecipeParser {
  // apparently a lot of recipe sites use the recipe schema definition: https://schema.org/Recipe
  // Instead of scraping the HTML, we can just search for and use this structured data if it exists instead
  final Uri recipeSource;
  final Document dom;
  late Map<String, dynamic> recipeSchema;

  RecipeSchemaParser(this.recipeSource, this.dom) {
    this.recipeSchema = extractRecipeSchema();
  }

  Map<String, dynamic> extractRecipeSchema() {
    var recipeSchema = dom
        .getElementsByTagName('script')
        .firstWhere((element) => element.attributes['type'] == 'application/ld+json')
        .text;
    return jsonDecode(recipeSchema);
  }

  @override
  List<String> parsedIngredients() {
    return (recipeSchema['recipeIngredient'] as List).cast<String>(); // List<String>;
  }

  @override
  String parsedName() {
    return recipeSchema['name'] as String;
  }

  @override
  String parsedServings() {
    return recipeSchema['recipeYield'] as String;
  }

  @override
  List<String> parsedSteps() {
    var instructions = (recipeSchema['recipeInstructions'] as List).cast<Map<String, dynamic>>();
    return instructions.map((i) => i['text']).cast<String>().toList();
  }

  @override
  String parsedTime() {
    return recipeSchema['prepTime'] as String;
  }

  @override
  Uri source() {
    return recipeSource;
  }
}

class BonAppetitParser extends RecipeSchemaParser {
  BonAppetitParser(Uri recipeSource, Document dom) : super(recipeSource, dom);

  @override
  String parsedServings() {
    return '?';
  }

  @override
  String parsedTime() {
    return '?';
  }

  @override
  String parsedName() {
    return 'Bon Appetit - ${super.parsedName()}';
  }
}
