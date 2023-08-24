# Recipes
Family recipe book and gastronomic observations

## Usage

Run dev server:
```
dart run build_runner serve
```

Build site:
```
./build.sh
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
