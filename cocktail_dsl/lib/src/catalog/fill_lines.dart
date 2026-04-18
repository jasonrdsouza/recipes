/// Hand-tuned fill fractions for (glass, ice) combinations.
/// Key format: "glassId:iceId"
/// Missing combos fall back to the glass's defaultFillFraction.
///
/// Only entries where ice changes the fill level belong here.
/// The no-ice fill level is controlled by each glass's defaultFillFraction.
const allFillLines = <String, double>{
  // ── Tumblers with ice ───────────────────────────────────

  'old-fashioned:large-cube': 0.72,
  'old-fashioned:sphere': 0.72,
  'old-fashioned:small-cubes': 0.68,
  'old-fashioned:crushed': 0.75,
  'old-fashioned:pebble': 0.78,
  'old-fashioned:block': 0.70,

  'rocks:large-cube': 0.72,
  'rocks:sphere': 0.72,
  'rocks:small-cubes': 0.68,
  'rocks:crushed': 0.75,
  'rocks:pebble': 0.78,
  'rocks:block': 0.70,

  'tumbler:large-cube': 0.72,
  'tumbler:sphere': 0.72,
  'tumbler:small-cubes': 0.68,
  'tumbler:crushed': 0.75,
  'tumbler:pebble': 0.78,

  'highball:large-cube': 0.78,
  'highball:small-cubes': 0.75,
  'highball:crushed': 0.82,
  'highball:pebble': 0.85,

  'collins:small-cubes': 0.75,
  'collins:crushed': 0.80,
  'collins:pebble': 0.83,

  'zombie:small-cubes': 0.75,
  'zombie:crushed': 0.80,
  'zombie:pebble': 0.83,

  'pint:small-cubes': 0.75,
  'pint:large-cube': 0.76,

  // ── Stemware with ice ───────────────────────────────────

  'margarita:large-cube': 0.85,
  'margarita:small-cubes': 0.82,
  'margarita:crushed': 0.88,

  'balloon:large-cube': 0.60,
  'balloon:small-cubes': 0.58,

  // ── Curved & handled with ice ───────────────────────────

  'hurricane:crushed': 0.80,
  'hurricane:pebble': 0.83,
  'hurricane:small-cubes': 0.75,

  'poco-grande:crushed': 0.80,
  'poco-grande:pebble': 0.83,

  'sling:small-cubes': 0.75,
  'sling:crushed': 0.80,

  'mule-mug:crushed': 0.78,
  'mule-mug:pebble': 0.80,
  'mule-mug:small-cubes': 0.70,

  'milkshake:crushed': 0.78,
};
