import 'dart:convert';
import 'dart:io';

/// Converts glass JSON coordinate data into Dart Glass(...) definitions.
/// Usage: dart run tools/convert_glasses.dart < glasses.json > lib/src/catalog/glasses.dart
void main() {
  final input = File('tools/reference.json').readAsStringSync();
  final glasses = jsonDecode(input) as List;

  final buf = StringBuffer();
  buf.writeln("import 'catalog.dart';");
  buf.writeln();
  buf.writeln('/// Glass catalog — ${glasses.length} glasses converted from coordinate data.');
  buf.writeln('/// All paths are designed for a 240x240 viewBox.');
  buf.writeln('const allGlasses = <Glass>[');

  for (final g in glasses) {
    final id = g['id'] as String;
    final name = g['name'] as String;
    final fill = (g['fill_fraction'] as num).toDouble();

    // Build outer svgPath
    final outerPath = _buildOuterPath(g);
    // Build interior clipPath
    final clipPath = _buildClipPath(g);
    // Compute liquidBounds from interior points with overflow
    final bounds = _computeLiquidBounds(g);

    buf.writeln('  Glass(');
    buf.writeln("    id: '$id',");
    buf.writeln("    name: '$name',");
    buf.writeln('    svgPath:');
    _writePathLines(buf, outerPath);
    buf.writeln('    liquidBounds: Rect(${bounds[0]}, ${bounds[1]}, ${bounds[2]}, ${bounds[3]}),');
    buf.writeln('    clipPathData:');
    _writePathLines(buf, clipPath);
    buf.writeln('    defaultFillFraction: $fill,');
    buf.writeln('  ),');
  }

  buf.writeln('];');
  stdout.write(buf);
}

String _buildOuterPath(Map<String, dynamic> g) {
  final outer = g['outer'] as Map<String, dynamic>;
  final leftWall = _pts(outer['left_wall']);
  final bottom = _pts(outer['bottom']);
  final rightWall = _pts(outer['right_wall']);

  final buf = StringBuffer();

  // Main body: left wall down, across bottom, right wall up, close
  buf.write('M${leftWall.first.x},${leftWall.first.y}');
  _writeCurveThrough(buf, leftWall.skip(1).toList());
  _writeCurveThrough(buf, bottom);
  _writeCurveThrough(buf, rightWall);
  buf.write(' Z');

  // Stem
  if (g['stem'] != null) {
    final stem = g['stem'] as Map<String, dynamic>;
    final stemLeft = _pts(stem['left']);
    final stemRight = _pts(stem['right']);
    // Draw stem as a thin shape
    buf.write(' M${stemLeft.first.x},${stemLeft.first.y}');
    for (final p in stemLeft.skip(1)) {
      buf.write(' L${p.x},${p.y}');
    }
    // Connect to right side at bottom, go back up
    buf.write(' L${stemRight.last.x},${stemRight.last.y}');
    for (final p in stemRight.reversed.skip(1)) {
      buf.write(' L${p.x},${p.y}');
    }
    buf.write(' Z');
  }

  // Base
  if (g['base'] != null) {
    final base = g['base'] as Map<String, dynamic>;
    final baseLeft = _pts(base['left_wall']);
    final baseBottom = _pts(base['bottom']);
    final baseRight = _pts(base['right_wall']);
    buf.write(' M${baseLeft.first.x},${baseLeft.first.y}');
    for (final p in baseLeft.skip(1)) buf.write(' L${p.x},${p.y}');
    for (final p in baseBottom) buf.write(' L${p.x},${p.y}');
    for (final p in baseRight) buf.write(' L${p.x},${p.y}');
    buf.write(' Z');
  }

  // Handle
  if (g['handle'] != null) {
    final handle = _pts(g['handle']);
    buf.write(' M${handle.first.x},${handle.first.y}');
    _writeCurveThrough(buf, handle.skip(1).toList());
  }

  return buf.toString();
}

String _buildClipPath(Map<String, dynamic> g) {
  final interior = g['interior'] as Map<String, dynamic>;
  final leftWall = _pts(interior['left_wall']);
  final bottom = _pts(interior['bottom']);
  final rightWall = _pts(interior['right_wall']);

  final buf = StringBuffer();
  buf.write('M${leftWall.first.x},${leftWall.first.y}');
  _writeCurveThrough(buf, leftWall.skip(1).toList());
  _writeCurveThrough(buf, bottom);
  _writeCurveThrough(buf, rightWall);
  buf.write(' Z');

  return buf.toString();
}

List<double> _computeLiquidBounds(Map<String, dynamic> g) {
  final interior = g['interior'] as Map<String, dynamic>;
  final allPts = [
    ..._pts(interior['left_wall']),
    ..._pts(interior['bottom']),
    ..._pts(interior['right_wall']),
  ];

  var minX = 999.0, maxX = 0.0, minY = 999.0, maxY = 0.0;
  for (final p in allPts) {
    if (p.x < minX) minX = p.x;
    if (p.x > maxX) maxX = p.x;
    if (p.y < minY) minY = p.y;
    if (p.y > maxY) maxY = p.y;
  }

  // Extend bottom by 20px for liquid overflow (rounded bottom effect)
  return [minX, minY, maxX - minX, maxY - minY + 20];
}

/// Write smooth curves through a series of points.
/// Uses Q (quadratic bezier) for smooth corners with 3+ points,
/// or L (line) for straight segments with 2 points.
void _writeCurveThrough(StringBuffer buf, List<_Pt> points) {
  if (points.isEmpty) return;

  if (points.length == 1) {
    buf.write(' L${points[0].x},${points[0].y}');
    return;
  }

  if (points.length == 2) {
    buf.write(' L${points[0].x},${points[0].y}');
    buf.write(' L${points[1].x},${points[1].y}');
    return;
  }

  // For 3+ points, use quadratic bezier with control points at the
  // data points and on-curve points at midpoints between them.
  // This produces smooth curves that approximate passing through all points.

  // Move to start
  buf.write(' L${points[0].x},${points[0].y}');

  // For each consecutive pair, use the first as a Q control point
  // and the midpoint to the next as the on-curve point
  for (var i = 0; i < points.length - 1; i++) {
    final curr = points[i];
    final next = points[i + 1];

    if (i < points.length - 2) {
      // Mid-segment: curve through control point to midpoint
      final midX = _r((curr.x + next.x) / 2);
      final midY = _r((curr.y + next.y) / 2);
      buf.write(' Q${curr.x},${curr.y} $midX,$midY');
    } else {
      // Last segment: curve to the final point
      buf.write(' Q${curr.x},${curr.y} ${next.x},${next.y}');
    }
  }
}

double _r(double v) => (v * 10).roundToDouble() / 10;

void _writePathLines(StringBuffer buf, String path) {
  // Break into lines of ~70 chars
  final lines = <String>[];
  var remaining = path;
  while (remaining.isNotEmpty) {
    if (remaining.length <= 70) {
      lines.add(remaining);
      remaining = '';
    } else {
      var br = remaining.lastIndexOf(' ', 70);
      if (br < 15) br = remaining.indexOf(' ', 40);
      if (br < 0) br = 70;
      lines.add(remaining.substring(0, br));
      remaining = remaining.substring(br + 1);
    }
  }
  for (var i = 0; i < lines.length; i++) {
    final isLast = i == lines.length - 1;
    // Add trailing space on non-last lines so adjacent string literals
    // don't concatenate SVG commands without whitespace
    final trailing = isLast ? '' : ' ';
    buf.writeln("        '${lines[i]}$trailing'${isLast ? ',' : ''}");
  }
}

List<_Pt> _pts(dynamic list) {
  return (list as List).map((p) {
    final coords = p as List;
    return _Pt(coords[0].toDouble(), coords[1].toDouble());
  }).toList();
}

class _Pt {
  final double x, y;
  _Pt(this.x, this.y);
}
