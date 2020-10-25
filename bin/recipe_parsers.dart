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
    return null;
  }
}

class RecipeSchemaParser implements RecipeParser {
  // apparently a lot of recipe sites use the recipe schema definition: https://schema.org/Recipe
  // Instead of scraping the HTML, we can just search for and use this structured data if it exists instead
  final Uri recipeSource;
  final Document dom;

  RecipeSchemaParser(this.recipeSource, this.dom) {
    extractRecipeSchema();
  }

  String extractRecipeSchema() {
    var recipeSchema = dom
        .getElementsByTagName('script')
        .firstWhere((element) => element.attributes['type'] == 'application/ld+json')
        .text;
    print(recipeSchema);
    return recipeSchema;
  }

  @override
  List<String> parsedIngredients() {
    // TODO: implement parsedIngredients
    throw UnimplementedError();
  }

  @override
  String parsedName() {
    // TODO: implement parsedName
    throw UnimplementedError();
  }

  @override
  String parsedServings() {
    // TODO: implement parsedServings
    throw UnimplementedError();
  }

  @override
  List<String> parsedSteps() {
    // TODO: implement parsedSteps
    throw UnimplementedError();
  }

  @override
  String parsedTime() {
    // TODO: implement parsedTime
    throw UnimplementedError();
  }

  @override
  Uri source() {
    // TODO: implement source
    throw UnimplementedError();
  }
}

class BonAppetitParser implements RecipeParser {
  final Uri recipeSource;
  final Document dom;
  BonAppetitParser(this.recipeSource, this.dom);

  @override
  List<String> parsedIngredients() {
    var ingredientElement = dom.getElementsByClassName('recipe__ingredient-list').first;
    var ingredientNodes = ingredientElement.children[2].children;
    return ingredientNodes.map((i) => i.text).toList();
  }

  @override
  String parsedServings() {
    var ingredientsElement = dom.getElementsByClassName('recipe__ingredient-list').first;
    return ingredientsElement.children[1].text.split(' ')[1];
  }

  @override
  List<String> parsedSteps() {
    var stepsElement = dom.getElementsByClassName('recipe__instruction-list').first;
    var stepsNodes = stepsElement.children[1].children;
    return stepsNodes.map((s) => s.text).toList();
  }

  @override
  String parsedTime() {
    return '?';
  }

  @override
  String parsedName() {
    var recipeTitle = dom.getElementsByTagName('h1').first.text;
    return 'Bon Appetit - ${recipeTitle}';
  }

  @override
  Uri source() {
    return recipeSource;
  }
}
