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
    return ['still', 'need to', 'implement'];
  }

  @override
  String parsedTime() {
    return '?';
  }

  @override
  String parsedName() {
    return 'todo';
  }

  @override
  Uri source() {
    return recipeSource;
  }
}
