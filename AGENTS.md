# Recipes

A family recipe book served as a static site at recipes.dsouza.io. Built with Dart and the `cork_site` static site generator.

## Creating a new recipe

### Option 1: Use the CLI tool

```
dart run bin/create_recipe.dart --name "Recipe Name"
```

This scaffolds a new recipe file and adds it to the index. Pass `--scrape <url>` to pre-populate from a supported recipe site (currently Bon Appetit).

### Option 2: Create manually

1. **Create the recipe file** at `web/<recipe-slug>.md` where the slug is the lowercase, hyphenated name (e.g. "Steak Tartare" → `web/steak-tartare.md`). Use `&` → `and` in slugs.

2. **Use this format:**

```yaml
---
title: "Recipe Name"
template: recipe.mustache
time: "30 minutes"
makes: "4 servings"
ingredients:
  - First ingredient with quantity
  - Second ingredient **(with optional parenthetical notes)**
steps:
  - First step
  - Second step with *emphasis* or **(bold parenthetical asides)**
notes:
  - Observations, tips, or commentary about the recipe
basedon:
  - "[Source Name](https://example.com)"
---
```

3. **Add the recipe slug to `web/index.md`** in the `recipes` JSON array, maintaining alphabetical order.

### Format conventions

- Ingredients include quantities inline (e.g. `2 oz rum`, `1 cup sugar`)
- Parenthetical notes use bold: `**(like this)**`
- Emphasis in steps uses italics: `*like this*`
- Markdown links work in notes and basedon fields
- The `basedon` field uses markdown link syntax: `"[Display Text](url)"`
- All fields are required. Use `"?"` for unknown time/makes values.

## Local development

```
dart run build_runner serve
```

Serves the site at localhost:8080 with hot reload.

## Deployment

The site is built and deployed automatically via GitHub Actions on push to `master`. No manual build step is needed.
