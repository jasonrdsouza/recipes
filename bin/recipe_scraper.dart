import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import './recipe_parsers.dart';

class RecipeScraper {
  static const String BON_APPETIT = 'https://www.bonappetit.com';

  final Set<String> parsers = {BON_APPETIT};

  bool isParseable(Uri recipeUri) {
    return parsers.contains(recipeUri.origin);
  }

  Future<Document> fetchContents(Uri recipeUri) async {
    var response = await http.Client().get(recipeUri);

    if (response.statusCode == 200) {
      return parse(response.body);
    } else {
      throw Exception("Unable to fetch recipe");
    }
  }

  Future<RecipeParser> scrape(Uri recipeUri) async {
    var dom = await fetchContents(recipeUri);
    switch (recipeUri.origin) {
      case BON_APPETIT:
        return BonAppetitParser(recipeUri, dom);
      default:
        return BlankRecipeParser("");
    }
  }
}
