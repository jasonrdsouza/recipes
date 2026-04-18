import 'token.dart';
import '../parser/parse_error.dart';

/// Tokenizes cocktail DSL source text.
class Lexer {
  final String _source;
  final List<Token> _tokens = [];
  int _line = 1;
  int _pos = 0;

  Lexer(this._source);

  /// Tokenize the full source and return the token list.
  List<Token> tokenize() {
    while (_pos < _source.length) {
      _skipBlankLinesAndComments();
      if (_pos >= _source.length) break;
      _scanLine();
    }
    _tokens.add(Token(
      type: TokenType.eof,
      lexeme: '',
      line: _line,
      column: 1,
    ));
    return _tokens;
  }

  void _skipBlankLinesAndComments() {
    while (_pos < _source.length) {
      // Skip blank lines
      if (_peek() == '\n') {
        _advance();
        _line++;
        continue;
      }
      // Check if line is all whitespace or a comment
      final lineStart = _pos;
      while (_pos < _source.length && _peek() == ' ') {
        _advance();
      }
      if (_pos >= _source.length) return;
      if (_peek() == '\n') {
        _advance();
        _line++;
        continue;
      }
      if (_peek() == '/' && _pos + 1 < _source.length && _source[_pos + 1] == '/') {
        _skipToEndOfLine();
        continue;
      }
      // Not blank or comment — rewind to line start
      _pos = lineStart;
      return;
    }
  }

  void _scanLine() {
    final lineNum = _line;

    // Check for indentation
    var indent = 0;
    while (_pos < _source.length && _peek() == ' ') {
      indent++;
      _advance();
    }

    if (indent > 0) {
      _tokens.add(Token(
        type: TokenType.indent,
        lexeme: ' ' * indent,
        line: lineNum,
        column: 1,
      ));
    }

    // Check for title line
    if (indent == 0 && _peek() == '#') {
      _advance(); // skip #
      _skipSpaces();
      final text = _readToEndOfLineOrComment();
      _tokens.add(Token(
        type: TokenType.hash,
        lexeme: '#',
        line: lineNum,
        column: 1,
      ));
      _tokens.add(Token(
        type: TokenType.text,
        lexeme: text.trim(),
        line: lineNum,
        column: 3,
      ));
      _emitNewline(lineNum);
      return;
    }

    // Read the first word on the line
    final col = indent + 1;
    if (_pos >= _source.length || _peek() == '\n') {
      _emitNewline(lineNum);
      return;
    }

    // Try to read a number first (for spine/accent lines)
    if (indent > 0 && _isDigit(_peek())) {
      _scanIndentedContentLine(lineNum, col);
      return;
    }

    // Read an identifier/keyword
    if (_isIdentStart(_peek())) {
      final word = _readIdentifier();
      final wordCol = col;

      // Check if this is a section or field header (followed by colon)
      _skipSpaces();
      if (_pos < _source.length && _peek() == '(') {
        // Could be "spine (30 ml):"
        final tokenType = _sectionTokenType(word);
        if (tokenType != null) {
          _tokens.add(Token(type: tokenType, lexeme: word, line: lineNum, column: wordCol));
          _scanSpineHeader(lineNum);
          return;
        }
      }
      if (_pos < _source.length && _peek() == ':') {
        _advance(); // skip colon
        final tokenType = _sectionTokenType(word);
        if (tokenType != null) {
          // Section header with no content after colon
          _tokens.add(Token(type: tokenType, lexeme: word, line: lineNum, column: wordCol));
          _tokens.add(Token(type: TokenType.colon, lexeme: ':', line: lineNum, column: _currentCol()));
        } else {
          // Field: key: value
          _tokens.add(Token(type: TokenType.identifier, lexeme: word, line: lineNum, column: wordCol));
          _tokens.add(Token(type: TokenType.colon, lexeme: ':', line: lineNum, column: _currentCol()));
        }
        _skipSpaces();
        // Read value as text
        final value = _readToEndOfLineOrComment();
        if (value.isNotEmpty) {
          _tokens.add(Token(
            type: TokenType.text,
            lexeme: value.trim(),
            line: lineNum,
            column: _currentCol(),
          ));
        }
        _emitNewline(lineNum);
        return;
      }

      // Indented line starting with an identifier (prep section)
      if (indent > 0) {
        _tokens.add(Token(type: TokenType.identifier, lexeme: word, line: lineNum, column: wordCol));
        _skipSpaces();
        final rest = _readToEndOfLineOrComment();
        if (rest.isNotEmpty) {
          _tokens.add(Token(
            type: TokenType.identifier,
            lexeme: rest.trim(),
            line: lineNum,
            column: _currentCol(),
          ));
        }
        _emitNewline(lineNum);
        return;
      }

      // Standalone identifier without colon (unusual, emit as identifier)
      _tokens.add(Token(type: TokenType.identifier, lexeme: word, line: lineNum, column: wordCol));
      final rest = _readToEndOfLineOrComment();
      if (rest.isNotEmpty) {
        _tokens.add(Token(type: TokenType.text, lexeme: rest.trim(), line: lineNum, column: _currentCol()));
      }
      _emitNewline(lineNum);
      return;
    }

    // Anything else — read as text
    final text = _readToEndOfLineOrComment();
    if (text.isNotEmpty) {
      _tokens.add(Token(type: TokenType.text, lexeme: text.trim(), line: lineNum, column: col));
    }
    _emitNewline(lineNum);
  }

  /// Scan an indented line that starts with a number (spine or accent line).
  void _scanIndentedContentLine(int lineNum, int col) {
    // Read number
    final numToken = _readNumber(lineNum, col);
    _tokens.add(numToken);
    _skipSpaces();

    if (_pos >= _source.length || _peek() == '\n') {
      _emitNewline(lineNum);
      return;
    }

    // Check if next word is a unit (for accent lines)
    final wordCol = _currentCol();
    final word = _readIdentifier();

    if (_isUnit(word)) {
      // Accent line: number unit ingredient
      _tokens.add(Token(type: TokenType.identifier, lexeme: _canonicalUnit(word), line: lineNum, column: wordCol));
      _skipSpaces();
      final ingredient = _readToEndOfLineOrComment().trim();
      if (ingredient.isNotEmpty) {
        _tokens.add(Token(type: TokenType.identifier, lexeme: ingredient, line: lineNum, column: _currentCol()));
      }
    } else {
      // Spine line: number ingredient
      _tokens.add(Token(type: TokenType.identifier, lexeme: word, line: lineNum, column: wordCol));
    }

    // Skip any inline comment
    _skipToEndOfContentOrComment();
    _emitNewline(lineNum);
  }

  void _scanSpineHeader(int lineNum) {
    // We're at "(" — parse "(number unit):"
    _advance(); // skip (
    _tokens.add(Token(type: TokenType.lparen, lexeme: '(', line: lineNum, column: _currentCol()));
    _skipSpaces();

    final numToken = _readNumber(lineNum, _currentCol());
    _tokens.add(numToken);
    _skipSpaces();

    final unitWord = _readIdentifier();
    _tokens.add(Token(type: TokenType.identifier, lexeme: unitWord, line: lineNum, column: _currentCol()));
    _skipSpaces();

    if (_pos < _source.length && _peek() == ')') {
      _advance();
      _tokens.add(Token(type: TokenType.rparen, lexeme: ')', line: lineNum, column: _currentCol()));
    }
    _skipSpaces();

    if (_pos < _source.length && _peek() == ':') {
      _advance();
      _tokens.add(Token(type: TokenType.colon, lexeme: ':', line: lineNum, column: _currentCol()));
    }

    _skipToEndOfContentOrComment();
    _emitNewline(lineNum);
  }

  Token _readNumber(int lineNum, int col) {
    final start = _pos;

    // Read digits
    while (_pos < _source.length && _isDigit(_peek())) {
      _advance();
    }

    if (_pos < _source.length && _peek() == '/') {
      // Fraction
      _advance(); // skip /
      while (_pos < _source.length && _isDigit(_peek())) {
        _advance();
      }
      final lexeme = _source.substring(start, _pos);
      final parts = lexeme.split('/');
      final numerator = int.parse(parts[0]);
      final denominator = int.parse(parts[1]);
      if (denominator == 0) {
        throw ParseException('Division by zero in fraction', lineNum, col);
      }
      return Token(
        type: TokenType.number,
        lexeme: lexeme,
        line: lineNum,
        column: col,
        numericValue: numerator / denominator,
      );
    }

    if (_pos < _source.length && _peek() == '.') {
      // Decimal
      _advance(); // skip .
      while (_pos < _source.length && _isDigit(_peek())) {
        _advance();
      }
    }

    final lexeme = _source.substring(start, _pos);
    return Token(
      type: TokenType.number,
      lexeme: lexeme,
      line: lineNum,
      column: col,
      numericValue: double.parse(lexeme),
    );
  }

  String _readIdentifier() {
    final start = _pos;
    while (_pos < _source.length && _isIdentChar(_peek())) {
      _advance();
    }
    return _source.substring(start, _pos).toLowerCase();
  }

  String _readToEndOfLineOrComment() {
    final start = _pos;
    while (_pos < _source.length && _peek() != '\n') {
      if (_peek() == '/' && _pos + 1 < _source.length && _source[_pos + 1] == '/') {
        break;
      }
      _advance();
    }
    return _source.substring(start, _pos);
  }

  void _skipToEndOfLine() {
    while (_pos < _source.length && _peek() != '\n') {
      _advance();
    }
    if (_pos < _source.length) {
      _advance(); // skip newline
      _line++;
    }
  }

  void _skipToEndOfContentOrComment() {
    while (_pos < _source.length && _peek() != '\n') {
      if (_peek() == '/' && _pos + 1 < _source.length && _source[_pos + 1] == '/') {
        break;
      }
      _advance();
    }
  }

  void _skipSpaces() {
    while (_pos < _source.length && _peek() == ' ') {
      _advance();
    }
  }

  void _emitNewline(int lineNum) {
    // Skip past inline comment if present
    if (_pos < _source.length && _peek() == '/' && _pos + 1 < _source.length && _source[_pos + 1] == '/') {
      _skipToEndOfLine();
      _tokens.add(Token(type: TokenType.newline, lexeme: '\\n', line: lineNum, column: _currentCol()));
      return;
    }
    if (_pos < _source.length && _peek() == '\n') {
      _advance();
      _line++;
    }
    _tokens.add(Token(type: TokenType.newline, lexeme: '\\n', line: lineNum, column: _currentCol()));
  }

  String _peek() => _source[_pos];
  void _advance() => _pos++;
  int _currentCol() => _pos - _lastLineStart() + 1;

  int _lastLineStart() {
    var i = _pos - 1;
    while (i >= 0 && _source[i] != '\n') {
      i--;
    }
    return i + 1;
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isIdentStart(String c) => _isLetter(c);
  bool _isIdentChar(String c) => _isLetter(c) || _isDigit(c) || c == '-';
  bool _isLetter(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  TokenType? _sectionTokenType(String word) {
    switch (word) {
      case 'spine':
        return TokenType.spine;
      case 'accent':
        return TokenType.accent;
      case 'prep':
        return TokenType.prep;
      default:
        return null;
    }
  }

  static const _unitForms = <String, String>{
    'oz': 'oz', 'ounce': 'oz', 'ounces': 'oz',
    'ml': 'ml', 'milliliter': 'ml', 'milliliters': 'ml',
    'cl': 'cl', 'centiliter': 'cl', 'centiliters': 'cl',
    'dash': 'dash', 'dashes': 'dash',
    'drop': 'drop', 'drops': 'drop',
    'bsp': 'bsp', 'barspoon': 'bsp', 'barspoons': 'bsp',
    'tsp': 'tsp', 'teaspoon': 'tsp', 'teaspoons': 'tsp',
    'tbsp': 'tbsp', 'tablespoon': 'tbsp', 'tablespoons': 'tbsp',
    'pinch': 'pinch', 'pinches': 'pinch',
    'rinse': 'rinse',
    'float': 'float',
  };

  bool _isUnit(String word) => _unitForms.containsKey(word);
  String _canonicalUnit(String word) => _unitForms[word] ?? word;
}
