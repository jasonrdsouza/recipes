import 'dart:js_interop';
import 'package:web/web.dart';

void main() {
  print('Recipe book loaded!');
  populateTableOfContents(alphabeticalIndexes(enumerateRecipes()));
  humanizeRecipeNames();
}

// Fetches all of the recipes on the index page
List<String> enumerateRecipes() {
  var recipeElements = document.querySelectorAll('.recipe');
  return [
    for (var i = 0; i < recipeElements.length; i++)
      recipeElements.item(i)!.textContent ?? ''
  ];
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
  if (tableOfContents == null) return;

  var tocEntries = recipeIndex.keys.toList();
  tocEntries.sort();

  for (var e in tocEntries) {
    var a = document.createElement('a') as HTMLAnchorElement;
    a.href = '#${recipeIndex[e]}';
    a.textContent = e;
    tableOfContents.appendChild(a);
  }
}

String humanize(String recipeName) {
  return recipeName
      .replaceAll("-", " ")
      .replaceAll(" and ", " & ")
      .replaceAllMapped(RegExp(r'\d+'), (Match m) => "#${m[0]}");
}

void humanizeRecipeNames() {
  var recipeElements = document.querySelectorAll('.recipe');
  for (var i = 0; i < recipeElements.length; i++) {
    var element = recipeElements.item(i)!;
    var firstChild = element.firstChild;
    if (firstChild != null) {
      var currentText = firstChild.textContent;
      if (currentText != null) {
        firstChild.textContent = humanize(currentText);
      }
    }
  }
}
