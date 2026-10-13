# Shokunin Learning Path — 修業 (shugyō)

A shokunin learns when, across rounds, its corpus **expands**, the **quality**
of what it holds rises, and it **recognizes quality** increasingly well. No
fixed exam measures this: the domain is not rigidly defined, it keeps
growing, and so does the shokunin. Learning is a continual path, walked every
round:

1. **Curation** — gather candidate material from the domain's real surfaces
   (sources, tools, artifacts, practitioners' records, the lane's own work).
   Every candidate is judged before it is admitted.
2. **Quality gating** — admit into `corpus/knowledge/` only what clears the
   shokunin's own bar in `corpus/QUALITY.md`. Every rejection is logged with
   its reason; a rejection is evidence of taste, not wasted work.
3. **Understanding** — distill what was admitted: connect entries, state the
   principle behind them, fold durable understanding into `SKILL.md`
   (decision tables, error patterns, checklists), and sharpen `QUALITY.md`
   from what the gate got right and wrong.
4. **Expanding perspective** — work the province frontier: adjacent
   sub-areas, other tools, schools and viewpoints, counter-examples and
   failure cases. The province grows by evidence, not by declaration.

## The three trends — one verdict each, every round

Verdicts use the protocol vocabulary (`improved`, `harmed`, `unchanged`,
`unprovable-but-better`); no trend is a scalar.

| Trend | Observable | `improved` when | `harmed` when |
|---|---|---|---|
| **expansion** | admitted `knowledge/` entries on ground the coverage map did not hold; frontier areas entered; new kinds of source | net new admitted entries on uncovered ground, each citing its coverage-map row | an admitted entry fails the bar it was admitted under |
| **quality** | entries re-verified, deepened, or superseded by stronger ones; `verified-at` freshness | a weaker entry is superseded by a stronger one, or stale entries re-verify, with no admitted entry failing its re-check | an entry is found false or stale and left unmarked |
| **discernment** | gate decisions vs the outside spot-check; `QUALITY.md` criteria | the spot-check agrees with the gate on admits *and* rejects, or a disagreement becomes a lesson that adds a grounded `QUALITY.md` criterion | a disagreement is left unlearned, or a criterion is added with no lesson behind it |

Growth without quality is not learning: `expansion: improved` with
`quality: harmed` is a trade, reported as a trade, never admitted.

## Discernment is checked from outside

Self-assessed taste is not discernment. Each round a non-author — a fresh
reviewer or the operator — spot-checks a sample of that round's gate
decisions, **at least one admit and one reject**, and records
`agree`/`disagree` with a reason in the round's lesson. A subagent the lane
dispatched is still the lane.

Operator teaching outranks every other source. A teaching lands verbatim as
`corpus/lessons/operator-<YYYY-MM-DD>-<slug>.md`; by the lane's next round it
must be reflected in `QUALITY.md` or `SKILL.md`, with the lesson cited, or the
round reports why not.

## Files the path writes

- `corpus/QUALITY.md` — the shokunin's quality bar for its own domain: what
  makes a source or entry strong, the signals of weak material, admission
  criteria. Thin at mint; every criterion cites the lesson that produced it.
  Criteria are superseded by new rows that name the row they replace, never
  rewritten.
- `corpus/README.md` — the coverage map plus a `## Frontier` list of areas
  being explored and not yet held.
- `corpus/knowledge/<slug>.md` — opens with `source:`, `verified-at:` (commit
  or date) and `recheck:` (the command or citation that re-verifies it).
- `corpus/lessons/round-<N>.md` — carries a `## Gate` section: candidates
  considered, admitted, rejected (with reasons), and the spot-check result.

## Province is a frontier, not a fence

`PROVINCE.md` holds **Core** (surfaces owned now), **Frontier** (areas being
explored; expected to grow) and **Adjacent** (sibling-owned; report, don't
absorb). Moving frontier ground into core is ordinary growth, recorded in
`LOG.md`. The one-domain-per-shokunin invariant still holds where a sibling
already owns the ground: contested scope is reported, never silently
absorbed.

## Relation to the axes

The trends are the learning signal; `AXES.md` axis-moves remain the unit of
work. Expansion is served by `coverage` and `adjacency`; quality by `depth`,
`freshness` and `operability`; discernment by `calibration`. Choose a round's
one axis-move from the trend that is furthest behind.
