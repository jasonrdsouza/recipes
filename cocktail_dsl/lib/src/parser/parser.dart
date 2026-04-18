import '../ast/recipe.dart';
import '../catalog/catalog.dart';
import 'parse_error.dart';
import '../lexer/lexer.dart';
import '../lexer/token.dart';

/// Valid method verbs.
const _validMethods = {
  'shake', 'stir', 'build', 'swizzle', 'blend', 'throw', 'whip',
  'roll', 'dry-shake', 'reverse-dry-shake', 'strain', 'double-strain',
  'fine-strain',
};

/// Valid prep verbs.
const _validPrepVerbs = {'rinse', 'chill', 'muddle', 'flame', 'smoke'};

/// Valid base units for spine.
const _validBaseUnits = {'oz', 'ml', 'cl'};

/// Maps string to CodexFamily.
const _familyMap = <String, CodexFamily>{
  'old-fashioned': CodexFamily.oldFashioned,
  'martini': CodexFamily.martini,
  'daiquiri': CodexFamily.daiquiri,
  'sidecar': CodexFamily.sidecar,
  'whisky-highball': CodexFamily.whiskyHighball,
  'flip': CodexFamily.flip,
};

/// Maps string to Unit.
const _unitMap = <String, Unit>{
  'oz': Unit.oz, 'ml': Unit.ml, 'cl': Unit.cl,
  'dash': Unit.dash, 'drop': Unit.drop, 'bsp': Unit.bsp,
  'tsp': Unit.tsp, 'tbsp': Unit.tbsp, 'pinch': Unit.pinch,
  'rinse': Unit.rinse, 'float': Unit.float,
};

/// Parses cocktail DSL source text into a Recipe IR.
class CocktailParser {
  final List<Token> _tokens;
  final Catalog _catalog;
  int _pos = 0;

  CocktailParser._(this._tokens, this._catalog);

  /// Parses [source] and returns a [Recipe].
  /// Throws [ParseException] on invalid input.
  static Recipe parse(String source) {
    final lexer = Lexer(source);
    final tokens = lexer.tokenize();
    final parser = CocktailParser._(tokens, Catalog());
    return parser._parseRecipe();
  }

  Recipe _parseRecipe() {
    String? title;
    String? glassId;
    String? iceId;
    List<MethodStep>? method;
    CodexFamily? family;
    Spine? spine;
    List<AccentLine> accent = [];
    List<PrepStep> prep = [];
    List<Garnish> garnishes = [];
    Map<String, String> metadata = {};

    // Parse title
    if (_check(TokenType.hash)) {
      _advance(); // skip #
      if (_check(TokenType.text)) {
        title = _current().lexeme;
        _advance();
      }
      _skipNewlines();
    }

    // Parse fields and sections
    while (!_isAtEnd()) {
      _skipNewlines();
      if (_isAtEnd()) break;

      if (_check(TokenType.spine)) {
        spine = _parseSpineSection();
      } else if (_check(TokenType.accent)) {
        accent = _parseAccentSection();
      } else if (_check(TokenType.prep)) {
        prep = _parsePrepSection();
      } else if (_check(TokenType.identifier)) {
        final key = _current().lexeme;
        final keyLine = _current().line;
        _advance();
        if (_check(TokenType.colon)) {
          _advance(); // skip colon
          final value = _check(TokenType.text) ? _current().lexeme : '';
          if (_check(TokenType.text)) _advance();
          _skipNewlines();

          switch (key) {
            case 'glass':
              glassId = value.trim().toLowerCase();
            case 'ice':
              iceId = value.trim().toLowerCase();
            case 'method':
              method = _parseMethodValue(value, keyLine);
            case 'family':
              final fam = value.trim().toLowerCase();
              family = _familyMap[fam];
            case 'garnish':
              garnishes = _parseGarnishValue(value);
            default:
              // Unknown key → store as metadata
              metadata[key] = value.trim();
          }
        } else {
          _skipNewlines();
        }
      } else {
        _advance(); // skip unrecognized token
      }
    }

    // Validate required fields
    if (title == null) {
      throw ParseException('Missing required title (# Name)', 1);
    }
    if (glassId == null) {
      throw ParseException('Missing required field: glass', 1);
    }
    if (iceId == null) {
      throw ParseException('Missing required field: ice', 1);
    }
    if (method == null) {
      throw ParseException('Missing required field: method', 1);
    }
    if (spine == null) {
      throw ParseException('Missing required section: spine', 1);
    }

    // Resolve glass
    final glass = _catalog.glassById(glassId);
    if (glass == null) {
      throw ParseException('Unknown glass: $glassId', 1);
    }

    // Resolve ice
    final ice = _catalog.iceById(iceId);
    if (ice == null) {
      throw ParseException('Unknown ice type: $iceId', 1);
    }

    return Recipe(
      title: title,
      family: family,
      glass: glass,
      ice: ice,
      method: method,
      prep: prep,
      spine: spine,
      accent: accent,
      garnishes: garnishes,
      metadata: metadata,
    );
  }

  List<MethodStep> _parseMethodValue(String value, int line) {
    final parts = value.split(',').map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty);
    final steps = <MethodStep>[];
    for (final verb in parts) {
      if (!_validMethods.contains(verb)) {
        throw ParseException('Unknown method: $verb', line);
      }
      steps.add(MethodStep(verb));
    }
    return steps;
  }

  List<Garnish> _parseGarnishValue(String value) {
    if (value.trim().toLowerCase() == 'none') return [];

    final garnishes = <Garnish>[];
    // Split on commas that are outside parentheses
    final entries = _splitOutsideParens(value);
    for (final entry in entries) {
      final trimmed = entry.trim();
      if (trimmed.isEmpty) continue;

      final parenStart = trimmed.indexOf('(');
      if (parenStart >= 0 && trimmed.endsWith(')')) {
        garnishes.add(Garnish(
          text: trimmed.substring(0, parenStart).trim(),
          modifiers: trimmed.substring(parenStart + 1, trimmed.length - 1).trim(),
        ));
      } else {
        garnishes.add(Garnish(text: trimmed));
      }
    }
    return garnishes;
  }

  List<String> _splitOutsideParens(String value) {
    final result = <String>[];
    var depth = 0;
    var start = 0;
    for (var i = 0; i < value.length; i++) {
      if (value[i] == '(') depth++;
      if (value[i] == ')') depth--;
      if (value[i] == ',' && depth == 0) {
        result.add(value.substring(start, i));
        start = i + 1;
      }
    }
    result.add(value.substring(start));
    return result;
  }

  Spine _parseSpineSection() {
    final sectionLine = _current().line;
    _advance(); // skip 'spine'

    var baseUnit = Unit.oz;
    var baseAmount = 1.0;

    // Check for optional (amount unit) header
    if (_check(TokenType.lparen)) {
      _advance(); // skip (
      if (_check(TokenType.number)) {
        baseAmount = _current().numericValue!;
        _advance();
      }
      if (_check(TokenType.identifier)) {
        final unitStr = _current().lexeme;
        if (!_validBaseUnits.contains(unitStr)) {
          throw ParseException(
              'Invalid spine base unit: $unitStr (must be oz, ml, or cl)',
              _current().line, _current().column);
        }
        baseUnit = _unitMap[unitStr]!;
        _advance();
      }
      if (_check(TokenType.rparen)) _advance();
    }

    if (_check(TokenType.colon)) _advance();
    _skipNewlines();

    // Parse indented spine lines
    final lines = <SpineLine>[];
    int? indentSize;

    while (_check(TokenType.indent)) {
      final indentToken = _current();
      final thisIndent = indentToken.lexeme.length;

      // Validate consistent indentation
      if (indentSize == null) {
        if (thisIndent != 2 && thisIndent != 4) {
          throw ParseException(
              'Indentation must be 2 or 4 spaces, got $thisIndent',
              indentToken.line, 1);
        }
        indentSize = thisIndent;
      } else if (thisIndent != indentSize) {
        throw ParseException(
            'Mixed indentation: expected $indentSize spaces, got $thisIndent',
            indentToken.line, 1);
      }

      _advance(); // skip indent

      if (!_check(TokenType.number)) {
        _skipToNextLine();
        continue;
      }

      final ratio = _current().numericValue!;
      _advance();

      if (!_check(TokenType.identifier)) {
        throw ParseException('Expected ingredient id after ratio', _current().line, _current().column);
      }
      final ingredientId = _current().lexeme;
      _advance();
      _skipNewlines();

      lines.add(SpineLine(
        ratio: ratio,
        ingredient: _resolveIngredient(ingredientId),
      ));
    }

    if (lines.isEmpty) {
      throw ParseException('Spine section must have at least one line', sectionLine);
    }

    return Spine(baseUnit: baseUnit, baseAmount: baseAmount, lines: lines);
  }

  List<AccentLine> _parseAccentSection() {
    _advance(); // skip 'accent'
    if (_check(TokenType.colon)) _advance();
    _skipNewlines();

    final lines = <AccentLine>[];
    int? indentSize;

    while (_check(TokenType.indent)) {
      final indentToken = _current();
      final thisIndent = indentToken.lexeme.length;

      if (indentSize == null) {
        if (thisIndent != 2 && thisIndent != 4) {
          throw ParseException(
              'Indentation must be 2 or 4 spaces, got $thisIndent',
              indentToken.line, 1);
        }
        indentSize = thisIndent;
      } else if (thisIndent != indentSize) {
        throw ParseException(
            'Mixed indentation: expected $indentSize spaces, got $thisIndent',
            indentToken.line, 1);
      }

      _advance(); // skip indent

      if (!_check(TokenType.number)) {
        _skipToNextLine();
        continue;
      }

      final amountToken = _current();
      final amount = amountToken.numericValue!;
      if (amount != amount.roundToDouble()) {
        throw ParseException(
            'Accent amounts must be integers, got ${amountToken.lexeme}',
            amountToken.line, amountToken.column);
      }
      _advance();

      // Unit
      if (!_check(TokenType.identifier)) {
        throw ParseException('Expected unit after amount', _current().line, _current().column);
      }
      final unitStr = _current().lexeme;
      final unit = _unitMap[unitStr];
      if (unit == null) {
        throw ParseException('Invalid accent unit: $unitStr', _current().line, _current().column);
      }
      _advance();

      // Ingredient
      if (!_check(TokenType.identifier)) {
        throw ParseException('Expected ingredient id after unit', _current().line, _current().column);
      }
      final ingredientId = _current().lexeme;
      _advance();
      _skipNewlines();

      lines.add(AccentLine(
        amount: amount.toInt(),
        unit: unit,
        ingredient: _resolveIngredient(ingredientId),
      ));
    }

    return lines;
  }

  List<PrepStep> _parsePrepSection() {
    _advance(); // skip 'prep'
    if (_check(TokenType.colon)) _advance();
    _skipNewlines();

    final steps = <PrepStep>[];
    int? indentSize;

    while (_check(TokenType.indent)) {
      final indentToken = _current();
      final thisIndent = indentToken.lexeme.length;

      if (indentSize == null) {
        if (thisIndent != 2 && thisIndent != 4) {
          throw ParseException(
              'Indentation must be 2 or 4 spaces, got $thisIndent',
              indentToken.line, 1);
        }
        indentSize = thisIndent;
      } else if (thisIndent != indentSize) {
        throw ParseException(
            'Mixed indentation: expected $indentSize spaces, got $thisIndent',
            indentToken.line, 1);
      }

      _advance(); // skip indent

      if (!_check(TokenType.identifier)) {
        _skipToNextLine();
        continue;
      }

      final verb = _current().lexeme;
      final verbLine = _current().line;
      _advance();

      if (!_validPrepVerbs.contains(verb)) {
        throw ParseException('Unknown prep verb: $verb', verbLine);
      }

      String? target;
      if (_check(TokenType.identifier)) {
        target = _current().lexeme;
        _advance();
      }
      _skipNewlines();

      if (target == null) continue;

      switch (verb) {
        case 'rinse':
          steps.add(RinseStep(_resolveIngredient(target)));
        case 'chill':
          steps.add(ChillStep(target));
        case 'muddle':
          steps.add(MuddleStep(_resolveIngredient(target)));
        case 'flame':
          steps.add(FlameStep(_resolveIngredient(target)));
        case 'smoke':
          steps.add(SmokeStep(_resolveIngredient(target)));
      }
    }

    return steps;
  }

  IngredientRef _resolveIngredient(String id) {
    final byId = _catalog.byId(id);
    if (byId != null) return KnownIngredient(byId);
    final byAlias = _catalog.byAlias(id);
    if (byAlias != null) return KnownIngredient(byAlias);
    return UnknownIngredient(id);
  }

  // Token navigation helpers

  Token _current() => _tokens[_pos];

  bool _check(TokenType type) => !_isAtEnd() && _current().type == type;

  Token _advance() => _tokens[_pos++];

  bool _isAtEnd() => _pos >= _tokens.length || _current().type == TokenType.eof;

  void _skipNewlines() {
    while (_check(TokenType.newline)) {
      _advance();
    }
  }

  void _skipToNextLine() {
    while (!_isAtEnd() && !_check(TokenType.newline)) {
      _advance();
    }
    _skipNewlines();
  }
}
