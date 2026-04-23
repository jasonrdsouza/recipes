/// Lightweight string-based SVG builder.
class SvgBuilder {
  final _defs = StringBuffer();
  final _body = StringBuffer();
  int _idCounter = 0;

  /// Tight viewBox bounds. Defaults fit typical cocktail diagrams;
  /// callers can set these based on actual content bounds.
  double viewBoxX = 0;
  double viewBoxY = 30;
  double viewBoxWidth = 400;
  double viewBoxHeight = 270;

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
    sb.writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'viewBox="$viewBoxX $viewBoxY $viewBoxWidth $viewBoxHeight">');
    // Theme-aware styling via CSS custom properties. Light-theme defaults;
    // consumers can override by setting CSS variables on a parent element.
    sb.writeln('<style>');
    sb.writeln('  svg { '
        '--cocktail-bg: transparent; '
        '--cocktail-glass-fill: rgba(245,245,250,0.4); '
        '--cocktail-glass-stroke: rgba(0,0,0,0.55); '
        '--cocktail-label: #333; '
        '--cocktail-leader: rgba(0,0,0,0.3); '
        '}');
    sb.writeln('</style>');
    sb.writeln(
        '<rect x="$viewBoxX" y="$viewBoxY" '
        'width="$viewBoxWidth" height="$viewBoxHeight" '
        'fill="var(--cocktail-bg)"/>');
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
