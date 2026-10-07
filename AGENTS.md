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

   This writes `web/<slug>.md` and inserts the slug into `web/index.md`. If the Dart SDK isn't available, do both steps by hand — see "Option 2" below.

   **If there's a source recipe, fetch it yourself** and draft from it. There is deliberately no scraper: you are better at reading an arbitrary recipe page than a parser is, and the URL goes in `basedon` either way.

2. The scaffold is placeholder text throughout. Interview until every placeholder can be replaced: ingredients with quantities, ordered steps, time, makes, notes, and sources for `basedon`. Ask whether it's a cocktail — if so it also needs `slug` and a `cocktail` block, see [Cocktail diagrams](#cocktail-diagrams).

   **Notes are the part most worth getting right, and the easiest to get wrong.** They are earned observations, not general cooking advice: why San Marzano tomatoes specifically, why Luxardo cherries beat the three other brands that were tried, that browning meat in large batches cools the pot and ruins it, that a Manhattan improves as it warms. Anything that could be pasted into any other recipe does not belong. Ask what the user has noticed; never synthesize a note.

3. Write the recipe following the format conventions below, then validate it:

   ```
   dart run bin/validate_recipes.dart
   ```

   It names every problem it finds and exits non-zero. If the Dart SDK is available, also confirm the site builds:

   ```
   dart run build_runner build --release
   ```

4. Commit on a branch named for the recipe, push, and open a PR. Leave it for review — never merge it. CI runs the same checks, so wait for it and fix anything red rather than handing over a failing PR.

### Updating an existing recipe

The recipe lives at `web/<slug>.md` and is already listed in `web/index.md`, so the index needs no changes.

**Append, don't rewrite.** Notes are a dated log and ingredient order is often meaningful — chronological rather than alphabetical. Preserve both, and leave existing wording alone unless asked to change it.

The running-log recipes (`bourbon-infinity-bottle`, `cognac-infinity-bottle`) follow a specific pattern:

- New bottles append to the **end** of `ingredients`, in the order they were added, formatted `2oz <Distiller> <Expression>`. A trailing `*` marks a bottle worth recommending — ask whether it earns one.
- Tasting commentary becomes a new **last** entry in `notes`, prefixed with a bold ISO date: `"**2026-08-09** ..."`. Ask for this commentary in the user's own words; never draft a tasting note.
- An update is often bottles only, with no accompanying note. That's fine — don't manufacture one.

Validate and open a PR the same way as for a new recipe.

## What is checked automatically

`.github/workflows/ci.yml` runs on every pull request: `dart analyze` on the root package, `bin/validate_recipes.dart`, `cocktail_dsl`'s analyzer and tests, and a full release build.

The validator exists because a green build does not mean a correct page. cork renders a missing field as an empty section, and the cocktail builder logs a warning and skips a bad diagram rather than failing. It checks:

- Frontmatter parses as YAML and every required field is present and correctly typed
- `template` resolves to a file in `web/templates/`
- `web/index.md` and the files on disk agree, with no duplicates and no unreachable pages
- `slug` matches the filename, and any `cocktail` block parses with the real DSL parser
- Internal links (`/manhattan.html`, `/assets/foo.jpg`) have targets that exist
- No leftover scaffold placeholders (`Add ingredients`, `? minutes`, a `file://` source)
- No unquoted `" #"`, which YAML reads as a comment and silently truncates the value

What it cannot check is whether the recipe is *right* — quantities, technique, step order, whether a note reflects what actually happened, whether a bottle earns its asterisk. That is what the interview is for, and why these checks are a backstop rather than a substitute for asking.

## Creating a new recipe

### Option 1: Use the CLI tool

```
dart run bin/create_recipe.dart --name "Recipe Name"
```

This scaffolds a new recipe file and adds it to the index. Every field is a placeholder that `bin/validate_recipes.dart` rejects, so run it afterwards to get the list of what still needs filling in.

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
- All fields are required. Ask for `time` and `makes` rather than guessing; a bare `"?"` is accepted when genuinely unknown, but the scaffold's `"? minutes"` and `"? servings"` are rejected
- Images and scans go in `web/assets/` and are referenced as `/assets/<name>`. Downsize large ones first: `convert -quality 30% assets/original.jpg assets/output_reduced.jpg`

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
