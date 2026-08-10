# Recipes

A family recipe book served as a static site at recipes.dsouza.io. Built with Dart and the `cork_site` static site generator.

## Working with Claude

When asked to add or change a recipe, drive the whole change: gather the missing details by asking, write the files, and open a PR for review. Two rules apply to both workflows below.

**Never invent recipe content.** Quantities, techniques, tasting notes, and opinions are personal and specific to this book. If a detail is missing, ask for it — do not substitute a plausible default. An unfinished draft is better than a confidently wrong one.

**Ask in batches.** Gather everything unclear into a single round of questions rather than a drip of one-at-a-time prompts. Follow up only when an answer opens something genuinely new.

### Adding a new recipe

1. Scaffold with the CLI tool, run from the repo root:

   ```
   dart run bin/create_recipe.dart --name "Recipe Name"
   ```

   Add `--scrape <url>` when there is a source URL to pull from. This writes `web/<slug>.md` and inserts the slug into `web/index.md`. If the Dart SDK isn't available, do both steps by hand — see "Option 2" below.

2. The scaffold is placeholder text (`Add ingredients`, `? minutes`). Interview until every placeholder can be replaced: ingredients with quantities, ordered steps, time, makes, notes, and sources for `basedon`. Ask whether it's a cocktail — if so it also needs `slug` and a `cocktail` block, see [Cocktail diagrams](#cocktail-diagrams).

3. Write the recipe following the format conventions below, then verify the site still builds if the Dart SDK is available:

   ```
   dart run build_runner build --release --output web:/tmp/recipe-build
   ```

4. Commit on a branch, push, and open a PR. Leave it for review — never merge it.

### Updating an existing recipe

The recipe lives at `web/<slug>.md` and is already listed in `web/index.md`, so the index needs no changes.

**Append, don't rewrite.** Notes are a dated log and ingredient order is often meaningful — chronological rather than alphabetical. Preserve both, and leave existing wording alone unless asked to change it.

The running-log recipes (`bourbon-infinity-bottle`, `cognac-infinity-bottle`) follow a specific pattern:

- New bottles append to the **end** of `ingredients`, in the order they were added, formatted `2oz <Distiller> <Expression>`. A trailing `*` marks a bottle worth recommending — ask whether it earns one.
- Tasting commentary becomes a new **last** entry in `notes`, prefixed with a bold ISO date: `"**2026-08-09** ..."`. Ask for this commentary in the user's own words; never draft a tasting note.
- An update is often bottles only, with no accompanying note. That's fine — don't manufacture one.

Verify the build and open a PR the same way as for a new recipe.

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
- `basedon` entries are usually markdown links — `"[Display Text](url)"` — but plain text is allowed (e.g. `Lifelong bourbon exploration`), and links may point at local scans (`/assets/foo.jpg`)
- All fields are required. Use `"?"` for unknown time/makes values.

**YAML quoting.** Quote any list entry that starts with `*`, `[`, or `{`, or that contains `: ` or ` #` — unquoted, YAML reads those as an alias, a flow sequence, or a comment, and the build breaks. This is why dated notes (`"**2024-12-22** ..."`), every `basedon` link (`"[Food Network Arugula Salad](https://...)"`), and entries like `"2oz Traveller Whiskey (Blend #40)"` are quoted. A trailing `*` is safe unquoted. When in doubt, quote.

## Cocktail diagrams

Cocktail recipes can carry a `cocktail` block in the frontmatter, which a build step renders into an SVG diagram shown on the page. Recipes using it also need a `slug` field matching the filename, since the template references `{{slug}}.cocktail.svg`.

```yaml
slug: sazerac
cocktail: |
  # Sazerac
  family: old-fashioned
  glass: rocks
  ice: none
  method: stir, strain

  prep:
    rinse absinthe

  spine:
    2     rye
    0.25  demerara-syrup

  accent:
    3 dash  peychauds
    1 dash  angostura

  garnish: lemon-peel (expressed, discarded)
```

- `spine` holds the ratio-based core ingredients — bare numbers are relative proportions, not absolute volumes.
- `accent` holds non-scaling additions, each with an explicit unit (`dash`, `drop`, `bsp`, `tsp`, `tbsp`, `pinch`, `rinse`, `float`).
- `family` is one of `old-fashioned`, `martini`, `daiquiri`, `sidecar`, `whisky-highball`, `flip`.
- `ice` is one of `none`, `large-cube`, `small-cubes`, `crushed`, `pebble`, `sphere`, `block`.
- `method` and `prep` verbs come from a fixed set (`shake`, `stir`, `build`, `strain`, `rinse`, `muddle`, …); see `cocktail_dsl/lib/src/parser/parser.dart`.
- Glass and ingredient names resolve against the catalog in `cocktail_dsl/lib/src/catalog/`. Unrecognized ingredients still render, just in a neutral grey — prefer a catalog name where one fits.

A block that fails to parse logs a warning and silently skips the diagram rather than failing the build, so check the build output when adding one. `cocktail_dsl/test/fixtures/` has worked examples.

## Local development

```
dart run build_runner serve
```

Serves the site at localhost:8080 with hot reload.

## Deployment

The site is built and deployed automatically via GitHub Actions on push to `master`. No manual build step is needed.
