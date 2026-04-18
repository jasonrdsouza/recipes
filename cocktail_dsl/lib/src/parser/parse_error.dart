/// Exception thrown when parsing a cocktail DSL source fails.
class ParseException implements Exception {
  final String message;
  final int line;
  final int? column;

  const ParseException(this.message, this.line, [this.column]);

  @override
  String toString() =>
      'ParseException: $message (line $line${column != null ? ', col $column' : ''})';
}
