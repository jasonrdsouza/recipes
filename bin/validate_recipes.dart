import 'dart:io';

import 'package:cocktail_dsl/cocktail_dsl.dart';
import 'package:yaml/yaml.dart';

/// Validates the recipe corpus: frontmatter structure, index consistency,
/// cocktail DSL blocks, internal links, and leftover scaffold placeholders.
///
/// Exists to catch the classes of mistake that the site build does not:
/// cork renders missing fields as empty sections, and the cocktail builder
/// logs a warning and skips a bad diagram rather than failing. Both produce
/// a broken page from a green build.
///
/// Usage: dart run bin/validate_recipes.dart
void main(List<String> arguments) {
  final problems = Validator().run();

  if (problems.isEmpty) {
    print('No problems found.');
    exitCode = 0;
    return;
  }

  final byFile = <String, List<String>>{};
  for (final p in problems) {
    byFile.putIfAbsent(p.file, () => []).add(p.message);
  }

  for (final file in byFile.keys.toList()..sort()) {
    print(file);
    for (final message in byFile[file]!) {
      print('  error: $message');
    }
    print('');
  }

  final fileCount = byFile.length;
  print('${problems.length} ${_plural(problems.length, 'error')} '
      'in $fileCount ${_plural(fileCount, 'file')}');
  exitCode = 1;
}

String _plural(int n, String word) => n == 1 ? word : '${word}s';

class Problem {
  final String file;
  final String message;
  Problem(this.file, this.message);
}

class Validator {
  static const webDir = 'web';
  static const indexPath = 'web/index.md';
  static const templatesDir = 'web/templates';

  /// Pages under web/ that are not recipes and are exempt from recipe checks.
  static const nonRecipePages = {'index', '404'};

  /// Fields every recipe must declare.
  static const requiredStringFields = ['title', 'template', 'time', 'makes'];
  static const requiredListFields = ['ingredients', 'steps', 'notes', 'basedon'];

  /// Text the scaffolder emits that must be replaced before publishing.
  static const placeholders = [
    'Add ingredients',
    'Add steps',
    'over here',
    'relevant notes about the recipe',
    'source or inspiration for this recipe',
    '? minutes',
    '? servings',
    'file://',
  ];

  final List<Problem> _problems = [];

  void _report(String file, String message) =>
      _problems.add(Problem(file, message));

  List<Problem> run() {
    final recipeFiles = _recipeFiles();
    _checkIndex(recipeFiles);
    for (final file in recipeFiles) {
      _checkRecipe(file);
    }
    return _problems;
  }

  /// All recipe markdown files, as slugs, sorted.
  List<String> _recipeFiles() {
    final dir = Directory(webDir);
    if (!dir.existsSync()) {
      _report(webDir, 'directory does not exist');
      return [];
    }
    final slugs = dir
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((name) => name.endsWith('.md'))
        .map((name) => name.substring(0, name.length - 3))
        .where((slug) => !nonRecipePages.contains(slug))
        .toList()
      ..sort();
    return slugs;
  }

  void _checkIndex(List<String> recipeFiles) {
    final raw = _readFrontmatter(indexPath);
    if (raw == null) return;

    final listed = raw.data['recipes'];
    if (listed is! List) {
      _report(indexPath, 'missing or non-list "recipes" field');
      return;
    }

    final entries = <String>[];
    for (final entry in listed) {
      if (entry is! String) {
        _report(indexPath, 'non-string entry in "recipes": $entry');
        continue;
      }
      entries.add(entry);
    }

    final seen = <String>{};
    for (final entry in entries) {
      if (!seen.add(entry)) {
        _report(indexPath, 'duplicate entry "$entry"');
      }
    }

    final sorted = entries.toList()..sort();
    if (!_sameOrder(entries, sorted)) {
      _report(indexPath, 'entries are not in alphabetical order');
    }

    for (final slug in recipeFiles) {
      if (!seen.contains(slug)) {
        _report(indexPath,
            '$webDir/$slug.md exists but is not listed, so the page is unreachable from the index');
      }
    }
    for (final entry in seen) {
      if (!recipeFiles.contains(entry)) {
        _report(indexPath, 'lists "$entry" but $webDir/$entry.md does not exist');
      }
    }
  }

  bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _checkRecipe(String slug) {
    final path = '$webDir/$slug.md';
    final raw = _readFrontmatter(path);
    if (raw == null) return;

    final data = raw.data;

    for (final field in requiredStringFields) {
      final value = data[field];
      if (value == null) {
        _report(path, 'missing required field "$field"');
      } else if (value is! String || value.trim().isEmpty) {
        _report(path, 'field "$field" must be a non-empty string');
      }
    }

    for (final field in requiredListFields) {
      final value = data[field];
      if (value == null) {
        _report(path, 'missing required field "$field"');
        continue;
      }
      if (value is! List) {
        _report(path, 'field "$field" must be a list');
        continue;
      }
      if (value.isEmpty) {
        _report(path, 'field "$field" is empty');
        continue;
      }
      for (var i = 0; i < value.length; i++) {
        final entry = value[i];
        if (entry is! String || entry.trim().isEmpty) {
          _report(path, 'field "$field" entry ${i + 1} must be a non-empty string');
        }
      }
    }

    _checkTemplate(path, data['template']);
    _checkPlaceholders(path, data);
    _checkSlugAndCocktail(path, slug, data);
    _checkInternalLinks(path, data);
    _checkUnquotedComments(path, raw.lines);
  }

  /// An unquoted " #" starts a YAML comment, so the rest of the value is
  /// dropped without any parse error — "2oz Rye (Blend #40)" silently becomes
  /// "2oz Rye (Blend". Neither the build nor a parsed-YAML check can see this,
  /// so it has to be caught in the raw text.
  static final _listEntryPattern = RegExp(r'^\s*-\s+(.*)$');

  void _checkUnquotedComments(String path, List<String> frontmatterLines) {
    for (final line in frontmatterLines) {
      final match = _listEntryPattern.firstMatch(line);
      if (match == null) continue;

      final value = match.group(1)!.trim();
      if (value.startsWith('"') || value.startsWith("'")) continue;
      if (!value.contains(' #')) continue;

      final kept = value.substring(0, value.indexOf(' #')).trim();
      _report(path,
          'unquoted " #" starts a YAML comment, silently truncating this entry to "$kept"; quote the whole value: $value');
    }
  }

  void _checkTemplate(String path, Object? template) {
    if (template is! String || template.isEmpty) return; // already reported
    final file = File('$templatesDir/$template');
    if (!file.existsSync()) {
      _report(path, 'template "$template" not found in $templatesDir/');
    }
  }

  void _checkPlaceholders(String path, Map<String, dynamic> data) {
    for (final text in _allStrings(data)) {
      for (final placeholder in placeholders) {
        if (text.contains(placeholder)) {
          _report(path, 'leftover scaffold placeholder "$placeholder" in: $text');
        }
      }
    }
  }

  void _checkSlugAndCocktail(
      String path, String slug, Map<String, dynamic> data) {
    final declaredSlug = data['slug'];
    final cocktail = data['cocktail'];

    if (declaredSlug != null) {
      if (declaredSlug is! String) {
        _report(path, 'field "slug" must be a string');
      } else if (declaredSlug != slug) {
        _report(path,
            'slug "$declaredSlug" does not match filename "$slug"; the cocktail diagram would 404');
      }
    }

    if (cocktail == null) return;

    if (cocktail is! String || cocktail.trim().isEmpty) {
      _report(path, 'field "cocktail" must be a non-empty string');
      return;
    }

    // The template references {{slug}}.cocktail.svg, so a diagram without a
    // slug renders a broken object element.
    if (declaredSlug == null) {
      _report(path,
          'has a "cocktail" block but no "slug" field, so the diagram cannot be referenced');
    }

    try {
      CocktailParser.parse(cocktail);
    } on ParseException catch (e) {
      _report(path,
          'cocktail block failed to parse: ${e.message} (line ${e.line}); the build would skip the diagram with only a warning');
    } catch (e) {
      _report(path, 'cocktail block failed to render: $e');
    }
  }

  static final _linkPattern = RegExp(r'\[[^\]]*\]\(([^)\s]+)\)');

  void _checkInternalLinks(String path, Map<String, dynamic> data) {
    for (final text in _allStrings(data)) {
      for (final match in _linkPattern.allMatches(text)) {
        final target = match.group(1)!;
        if (!target.startsWith('/')) continue; // external or relative
        final resolved = _resolveInternalLink(target);
        if (resolved != null && !File(resolved).existsSync()) {
          _report(path, 'internal link "$target" has no target ($resolved missing)');
        }
      }
    }
  }

  /// Maps a site-absolute link to the source file that must exist, or null
  /// when the link needs no check.
  String? _resolveInternalLink(String target) {
    final withoutFragment = target.split('#').first.split('?').first;
    if (withoutFragment == '/' || withoutFragment.isEmpty) return null;

    // /manhattan.html is generated from web/manhattan.md
    if (withoutFragment.endsWith('.html')) {
      final stem = withoutFragment.substring(1, withoutFragment.length - 5);
      return '$webDir/$stem.md';
    }

    // Everything else (assets, css, images) ships as-is from web/
    return '$webDir${withoutFragment}';
  }

  /// Every string reachable from the frontmatter, flattened.
  Iterable<String> _allStrings(Map<String, dynamic> data) {
    final out = <String>[];
    void walk(Object? value) {
      if (value is String) {
        out.add(value);
      } else if (value is List) {
        value.forEach(walk);
      } else if (value is Map) {
        value.values.forEach(walk);
      }
    }

    walk(data);
    return out;
  }

  _Frontmatter? _readFrontmatter(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      _report(path, 'file does not exist');
      return null;
    }

    final contents = file.readAsStringSync();
    final lines = contents.split('\n');
    if (lines.isEmpty || !lines.first.startsWith('---')) {
      _report(path, 'no frontmatter: file must start with ---');
      return null;
    }

    final separators = <int>[];
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].startsWith('---')) separators.add(i);
    }
    if (separators.isEmpty) {
      _report(path, 'frontmatter is not closed with ---');
      return null;
    }
    // cork treats the LAST --- as the closing separator while this validator
    // uses the first; more than one means the two disagree about where the
    // frontmatter ends.
    if (separators.length > 1) {
      _report(path,
          'found ${separators.length} "---" separators; the build and this check would read different frontmatter');
    }

    final yamlStr = lines.getRange(1, separators.first).join('\n');
    Object? parsed;
    try {
      parsed = loadYaml(yamlStr);
    } on YamlException catch (e) {
      _report(path, 'frontmatter is not valid YAML: ${e.message}');
      return null;
    }

    if (parsed is! Map) {
      _report(path, 'frontmatter must be a YAML mapping');
      return null;
    }

    return _Frontmatter(
      Map<String, dynamic>.from(parsed),
      lines.getRange(1, separators.first).toList(),
    );
  }
}

class _Frontmatter {
  final Map<String, dynamic> data;

  /// Raw frontmatter lines, for checks that parsed YAML cannot express.
  final List<String> lines;

  _Frontmatter(this.data, this.lines);
}
