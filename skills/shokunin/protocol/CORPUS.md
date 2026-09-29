# Shokunin Corpus Contract

Every shokunin repo carries a proprietary corpus — knowledge about its domain
*and* training lessons about itself. It is the shokunin's memory; it must never
contain generic filler.

## Layout (per child repo)

```
corpus/
  README.md        — index: what's here, coverage map, known gaps
  knowledge/       — domain facts, sourced notes, decision records
  lessons/         — training lessons: what worked/failed this round and why
```

## Rules

- `knowledge/` entries cite a source: file path, command output, or URL.
- `lessons/` entries cite the round and the evidence (LOG.md round, commit, report).
- A corpus entry is falsifiable or marked opinion; no unverifiable claims.
- The aggregator reviews every corpus each round and files gaps as lessons.

## Rules added from the round-1/2 corpus audits

Evidence: the per-repo `corpus/lessons/round-1-aggregator-audit.md` entries and
`.ufo/reports/round-2/AGGREGATE.md`.

- **A count carries its command.** Any number in a corpus entry (rows, files,
  lines, packages) is written as `<number> — <command> <date>`. Round-1 found
  four unreproducible counts: "275 claim packages" (observed 274 program dirs /
  295 package dirs / 281 `status.json`), "20-row registry" (observed 21),
  "~40 clones" (observed 50), "scripts/ 74 entries" (observed 82).
- **A negative claim carries its sweep.** "No counterexample", "nothing
  handles X", "absent everywhere" need the search command that produced the
  absence, or the claim is unverifiable.
- **A quote names its location.** Frontmatter vs body, header comment vs code,
  script vs installed skill. Round-1 defects: an anti-trigger quoted as
  frontmatter that lives in a body table; a `128`-lane cap attributed to an
  installed skill that contains no `128`.
- **An index row is a claim.** Write the row when the file exists, not before.
  A seeded index naming seven entries while one existed is worse than a
  one-row index.
- **No credential material, ever.** Secret values, session tokens, cookies, and
  vault ref paths (`op://…`) stay out of every corpus, including this one's
  examples. Cite the file path, the mode, and the mechanism; a reader with
  authority can regenerate the metadata.
- **Corrections are new entries, never rewrites.** Lanes own
  `lessons/round-<N>.md`; the aggregator writes only
  `lessons/round-<N>-aggregator-*.md` and does not edit lane-authored corpus
  files in place (same append-only discipline `PROTOCOL.md` gives `LOG.md`).
  This rule exists because of a real collision: aggregator and kagi lane both
  wrote `kagi-shokunin/corpus/lessons/round-1.md` in the same minute
  (2026-09-28 15:56); the lane's committed version was restored and the
  aggregator's moved to `round-1-aggregator-seed.md`.
- **Each round's review emits a verdict per repo** — `conformant` or
  `not conformant`, naming the failed rule and the command that shows it.
