# Recipes
Family recipe book and gastronomic observations

The site is built automatically via GitHub Actions on every push to `master` and served at [recipes.dsouza.io](https://recipes.dsouza.io) via GitHub Pages.

## Usage

Run dev server:
```
dart run build_runner serve
```

Create new recipe:
```
dart run bin/create_recipe.dart --name "Recipe Name"
```

Reduce image size:
```
# Choose quality percentage based on desired quality vs size tradeoff
convert -quality 30% assets/original.jpg assets/output_reduced.jpg
```
