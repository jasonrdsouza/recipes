/// Token types produced by the lexer.
enum TokenType {
  // Structural
  hash,        // #
  colon,       // :
  comma,       // ,
  lparen,      // (
  rparen,      // )
  newline,
  indent,      // 2 or 4 spaces at start of line
  eof,

  // Values
  number,      // integer, decimal, or fraction (normalized to double)
  identifier,  // kebab-case word
  text,        // freeform text (garnish, notes, etc.)

  // Keywords (contextual)
  spine,
  accent,
  prep,
}

/// A token with position information.
class Token {
  final TokenType type;
  final String lexeme;
  final int line;
  final int column;
  final double? numericValue; // set for number tokens

  const Token({
    required this.type,
    required this.lexeme,
    required this.line,
    required this.column,
    this.numericValue,
  });

  @override
  String toString() => 'Token($type, "$lexeme", $line:$column)';
}
