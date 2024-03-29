import 'dart:html';

void main() {
  print('Recipe book loaded!');
  populateTableOfContents(alphabeticalIndexes(enumerateRecipes()));
  humanizeRecipeNames();
}

// Fetches all of the recipes on the index page
List<String> enumerateRecipes() {
  var recipeElements = document.querySelectorAll('.recipe');
  return recipeElements.map((element) => element.text).whereType<String>().toList();
}

// Converts a list of recipes into a map with the key corresponding to a unique letter,
// and the value corresponding to the alphabetically first recipe that starts with that letter.
//
// This will allow easy indexing of the list of recipes on the homepage.
Map<String, String> alphabeticalIndexes(List<String> recipes) {
  recipes.sort((a, b) => b.toLowerCase().compareTo(a.toLowerCase())); // sort in reverse order
  return Map.fromIterable(recipes, key: (item) => item[0].toUpperCase(), value: (item) => item);
}

void populateTableOfContents(Map<String, String> recipeIndex) {
  var tableOfContents = document.querySelector('#navigation');

  var tocEntries = recipeIndex.keys.toList();
  tocEntries.sort();

  var tocElements = tocEntries.map((e) {
    var a = AnchorElement(href: '#${recipeIndex[e]}');
    a.text = e;
    return a;
  });
  tableOfContents?.children.addAll(tocElements);
}

String humanize(String recipeName) {
  return recipeName
      .replaceAll("-", " ")
      .replaceAll(" and ", " & ")
      .replaceAllMapped(RegExp(r'\d+'), (Match m) => "#${m[0]}");
}

void humanizeRecipeNames() {
  var recipeElements = document.querySelectorAll('.recipe');
  recipeElements.forEach((element) {
    var currentText = element.firstChild!.text;
    if (currentText != null) {
      element.firstChild!.text = humanize(currentText);
    }
  });
}
