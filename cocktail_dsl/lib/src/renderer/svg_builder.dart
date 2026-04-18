/// Lightweight string-based SVG builder.
class SvgBuilder {
  final _defs = StringBuffer();
  final _body = StringBuffer();
  int _idCounter = 0;

  String nextId(String prefix) => '${prefix}_${_idCounter++}';

  void addDef(String svg) => _defs.writeln(svg);

  void add(String svg) => _body.writeln(svg);

  void addGroup(String attrs, String content) {
    _body.writeln('<g $attrs>');
    _body.write(content);
    _body.writeln('</g>');
  }

  String build() {
    final sb = StringBuffer();
    sb.writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 360">');
    sb.writeln('<rect width="400" height="360" fill="#2C2C3A"/>');
    if (_defs.isNotEmpty) {
      sb.writeln('<defs>');
      sb.write(_defs);
      sb.writeln('</defs>');
    }
    sb.write(_body);
    sb.writeln('</svg>');
    return sb.toString();
  }
}
