# Shokunin Expertise Axes

What makes a shokunin an expert is decomposed into measurable axes. Every
shokunin works its own subset; the protocol and aggregator lanes own the
fleet-level axes.

## The six axes

| Axis | Definition | Signal an expert shows |
|---|---|---|
| **depth** | Verifiable technical detail — decision tables with real thresholds, named error signatures, cited sources | A reader can act on SKILL.md alone; no filler |
| **coverage** | Fraction of the domain's real surfaces the skill governs (repo paths, tools, edge classes) | PROVINCE.md lists every surface; none unexplored without reason |
| **operability** | Runnable artifacts: checklists that are executable, commands that exist, scripts that run | A checklist item can be run and produces the stated outcome |
| **freshness** | Drift detection — skill claims re-verified against live surfaces; stale items flagged or fixed | Each round LOG entry includes a re-verification result |
| **calibration** | Self-assessment quality: gaps named honestly, confidence graded, overreach caught | SHONEN.md/SCORECARD entries match observed repo state |
| **adjacency** | Cross-domain awareness — evidence belonging to another domain reported, not absorbed | Lane reports name contested scope; integrator arbitrates |

## The learning path

The axes are the unit of work; the learning signal is `LEARNING.md`'s three
trends. Expansion ↔ `coverage` + `adjacency`; quality ↔ `depth` + `freshness`
+ `operability`; discernment ↔ `calibration`. Pick the round's axis from the
trend furthest behind.

## Working an axis

A lane's round is one axis-move: pick the lowest-scoring axis for the repo,
land one verifiable improvement, measure it (file exists / command runs /
citation resolves), record before→after in `SCORECARD.md`, log evidence in
`LOG.md`. If an axis saturates, the lane may retire it or split it into a
sub-axis — recorded in `SCORECARD.md` with reason.

## SCORECARD.md contract (per child repo)

| Field | Content |
|---|---|
| axes | Axis name → score 0–10 → evidence pointer → last-change round |
| planned | The single next axis-move the lane intends |
| retired | Axes retired with justification (saturation or wrong fit) |
