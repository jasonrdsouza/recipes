import 'catalog.dart';

/// Full ice catalog — 7 ice types with SVG fragments for rendering
/// inside glasses. Fragments are drawn with semi-transparency at the
/// liquid surface. Coordinates assume a ~240x240 region; actual
/// positioning is adjusted by the renderer relative to the glass.
const allIceTypes = <Ice>[
  // ── None ────────────────────────────────────────────────
  Ice(
    id: 'none',
    name: 'None',
    svgFragment: '',
  ),

  // ── Large Cube ──────────────────────────────────────────
  Ice(
    id: 'large-cube',
    name: 'Large Cube',
    svgFragment:
        // Single large cube with 3D top & right face
        'M75,65 L155,65 L155,145 L75,145 Z '        // front face
        'M75,65 L95,48 L175,48 L155,65 '             // top face
        'M155,65 L175,48 L175,128 L155,145',          // right face
  ),

  // ── Small Cubes ─────────────────────────────────────────
  Ice(
    id: 'small-cubes',
    name: 'Small Cubes',
    svgFragment:
        // Cube 1 — upper left
        'M60,55 L100,55 L100,95 L60,95 Z '
        'M60,55 L72,44 L112,44 L100,55 '
        'M100,55 L112,44 L112,84 L100,95 '
        // Cube 2 — upper right, slightly rotated
        'M120,50 L158,54 L154,92 L116,88 Z '
        'M120,50 L134,40 L172,44 L158,54 '
        'M158,54 L172,44 L168,82 L154,92 '
        // Cube 3 — lower center
        'M85,100 L125,100 L125,140 L85,140 Z '
        'M85,100 L97,89 L137,89 L125,100 '
        'M125,100 L137,89 L137,129 L125,140',
  ),

  // ── Crushed Ice ─────────────────────────────────────────
  Ice(
    id: 'crushed',
    name: 'Crushed',
    svgFragment:
        // Irregular small angular pieces scattered
        'M55,60 L70,55 L75,68 L62,72 Z '
        'M82,52 L98,48 L102,62 L86,65 Z '
        'M108,56 L122,50 L128,64 L114,68 Z '
        'M135,54 L150,50 L154,63 L140,66 Z '
        'M160,58 L174,54 L177,67 L163,70 Z '
        'M60,78 L76,74 L80,88 L64,91 Z '
        'M90,75 L106,70 L110,84 L94,88 Z '
        'M118,76 L134,72 L137,86 L121,89 Z '
        'M146,74 L162,70 L165,83 L149,87 Z '
        'M68,96 L84,92 L88,106 L72,109 Z '
        'M100,94 L116,90 L119,103 L103,107 Z '
        'M130,92 L146,88 L150,102 L134,105 Z '
        'M80,112 L96,108 L99,121 L83,124 Z '
        'M112,110 L128,106 L132,120 L116,123 Z',
  ),

  // ── Pebble Ice ──────────────────────────────────────────
  Ice(
    id: 'pebble',
    name: 'Pebble',
    svgFragment:
        // Many tiny round pieces (circles approximated as short arcs)
        'M65,58 A5,5 0 1,1 65,57.9 Z '
        'M80,54 A5,5 0 1,1 80,53.9 Z '
        'M96,56 A5,5 0 1,1 96,55.9 Z '
        'M112,52 A5,5 0 1,1 112,51.9 Z '
        'M128,55 A5,5 0 1,1 128,54.9 Z '
        'M144,53 A5,5 0 1,1 144,52.9 Z '
        'M160,57 A5,5 0 1,1 160,56.9 Z '
        'M58,72 A5,5 0 1,1 58,71.9 Z '
        'M74,70 A5,5 0 1,1 74,69.9 Z '
        'M90,68 A5,5 0 1,1 90,67.9 Z '
        'M106,71 A5,5 0 1,1 106,70.9 Z '
        'M122,69 A5,5 0 1,1 122,68.9 Z '
        'M138,72 A5,5 0 1,1 138,71.9 Z '
        'M154,68 A5,5 0 1,1 154,67.9 Z '
        'M170,71 A5,5 0 1,1 170,70.9 Z '
        'M66,86 A5,5 0 1,1 66,85.9 Z '
        'M82,84 A5,5 0 1,1 82,83.9 Z '
        'M98,87 A5,5 0 1,1 98,86.9 Z '
        'M114,83 A5,5 0 1,1 114,82.9 Z '
        'M130,86 A5,5 0 1,1 130,85.9 Z '
        'M146,84 A5,5 0 1,1 146,83.9 Z '
        'M162,87 A5,5 0 1,1 162,86.9 Z '
        'M72,100 A5,5 0 1,1 72,99.9 Z '
        'M88,98 A5,5 0 1,1 88,97.9 Z '
        'M104,101 A5,5 0 1,1 104,100.9 Z '
        'M120,97 A5,5 0 1,1 120,96.9 Z '
        'M136,100 A5,5 0 1,1 136,99.9 Z '
        'M152,98 A5,5 0 1,1 152,97.9 Z '
        'M80,114 A5,5 0 1,1 80,113.9 Z '
        'M96,112 A5,5 0 1,1 96,111.9 Z '
        'M112,115 A5,5 0 1,1 112,114.9 Z '
        'M128,111 A5,5 0 1,1 128,110.9 Z '
        'M144,114 A5,5 0 1,1 144,113.9 Z',
  ),

  // ── Sphere ──────────────────────────────────────────────
  Ice(
    id: 'sphere',
    name: 'Sphere',
    svgFragment:
        // Single large sphere with a highlight arc
        'M120,55 A50,50 0 1,1 119.9,55 Z '            // full circle
        'M100,70 A20,20 0 0,1 115,60',                 // highlight crescent
  ),

  // ── Block ───────────────────────────────────────────────
  Ice(
    id: 'block',
    name: 'Block',
    svgFragment:
        // Tall rectangular block with 3D top & right face
        'M85,40 L150,40 L150,155 L85,155 Z '          // front face
        'M85,40 L100,28 L165,28 L150,40 '              // top face
        'M150,40 L165,28 L165,143 L150,155',            // right face
  ),
];
