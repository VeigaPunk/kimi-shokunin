# Shokunin Corpus Contract

Every shokunin repo carries a proprietary corpus — knowledge about its domain
*and* training lessons about itself. It is the shokunin's memory; it must never
contain generic filler.

## Layout (per child repo)

```
corpus/
  README.md        — index: what's here, coverage map, known gaps, frontier
  QUALITY.md       — the shokunin's own quality bar (LEARNING.md)
  knowledge/       — domain facts, sourced notes, decision records
  lessons/         — training lessons: what worked/failed this round and why
  SOURCES.md       — curated source registry (contract below)
```

Each `knowledge/` entry opens with `source:`, `verified-at:` and `recheck:`;
each `lessons/round-<N>.md` carries a `## Gate` section (candidates,
admitted, rejected with reasons, spot-check result). See `LEARNING.md`.

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

## SOURCES.md — where a shokunin learns

Contract v1, ratified 2026-10-19 and integrated from the fleet root revision
`dcf3b6484e02452fc7aec55d724744de188779b9`. This canonical section is the
authority; fleet copies are vendored and do not override it. A change is a new
contract version, never an edit to this section.
Where a shokunin learns. `corpus/knowledge/` holds admitted facts; `corpus/SOURCES.md`
holds the places they come from — what each teaches, how far to trust it for which
scope, and when to look again. It is the lane's curated reading list and the standing
record of its taste. The curation and grading practice originated in the
fleet's kaika campaign; that history is provenance, not a separate authority.

### Shape

```
# SOURCES — where <id> learns
## Registry           the one table below
## Paths              ordered study sequences: `<topic> — S003 → S010 → S014: why this order`
## Search log         one prose note per bounded search (rule 5)
## Leads (unopened)   bullets; a lead is not evidence and never a row
```

| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |
|---|---|---|---|---|---|---|---|---|---|---|

- `id` — `S` + 3 or more digits, the next unused; never reused. No `|` inside any cell.
- `source` — title — canonical URL or DOI (a repo path or command for `own-work`).
- `kind` — `spec` · `docs` · `paper` · `code` · `tool` · `dataset` · `talk` · `book` ·
  `community` · `own-work`.
- `tier` — scoped to `scope`, never global. **A**: primary or authoritative for that scope
  (spec, official docs, source code, original paper, maintainer statement, the lane's own
  re-runnable gate output). **B**: strong secondary (expert write-up with reproducible
  detail, survey, textbook). **C**: lead only — never sole support for an admitted entry.
  `community` is never A. Tier is curation, not truth: no NATO/GRADE labels on rows.
- `scope` — the claim or topic the tier applies to.
- `anchor` — exact section / heading / page / line plus revision (version, commit, or
  publication date). Never a bare homepage.
- `teaches` — one grounded learner benefit. Rejected rows read
  `REJECTED: <reason>; flip: <what would change the verdict>`.
- `status` — `queued` (opened, worth mining) · `mined` (cited by ≥1 path in `used-by`) ·
  `rejected` (kept — a rejection is evidence of taste).
- `opened` — ISO date the row's author opened the source. `recheck` — ISO date or cadence
  (`90d`, `180d`, `on-release`).
- `used-by` — repo-relative paths of the knowledge entries or lessons citing the row,
  comma-separated, or `—`.

### Rules

1. **A row is a claim.** Write it only after opening the source in the round that writes
   the row. The round lesson's `## Gate` records, for every new row, the URL, the access
   date, and a ≤25-word quote with its location grounding `teaches`. Non-author
   verification re-opens a sample.
2. **Append-only.** Only `status`, `recheck` and `used-by` change in place, and each change
   is logged old→new in the round lesson. A correction is a new row whose `teaches` opens
   `supersedes S0NN —`.
3. **No second method.** Claim admission stays in `corpus/QUALITY.md`. Research
   method stays in the lane's designated domain instructions (question → source
   hierarchy → citation chain → claim-vs-source check); `SOURCES.md` only
   records and curates sources. `QUALITY.md` points here for tier definitions.
4. **Expansion is knowledge, not rows.** The expansion trend counts admitted `knowledge/`
   entries whose `source:` cites a `mined` row on uncovered coverage-map ground. There is
   no row quota; a short registry of opened, honestly tiered rows beats a long one.
5. **Search log.** PRISMA-inspired, not PRISMA-compliant: question/query, where searched,
   date, identified / screened / included / excluded counts, exclusion reasons, stop
   rationale. A negative claim carries its sweep.
6. **No credential material**, session or private URLs, or `op://` references — ever.

### Census — run from the lane root (tested 2026-10-19 on a synthetic table)

```sh
# rows (spacing-tolerant)
grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md
# malformed rows — 11 columns means NF=13; must print 0
awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF!=13 {n++} END{print n+0}' corpus/SOURCES.md
# tier histogram
awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {t=$5; gsub(/[[:space:]]/,"",t); n[t]++} END{for(k in n) printf "%s=%d ", k, n[k]; print ""}' corpus/SOURCES.md
# status histogram
awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {s=$9; gsub(/[[:space:]]/,"",s); n[s]++} END{for(k in n) printf "%s=%d ", k, n[k]; print ""}' corpus/SOURCES.md
# duplicate ids — must print nothing
awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {i=$2; gsub(/[[:space:]]/,"",i); print i}' corpus/SOURCES.md | sort | uniq -d
# enum violations and tier inflation — must print nothing
awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF==13 {i=$2;k=$4;t=$5;s=$9; gsub(/[[:space:]]/,"",i); gsub(/[[:space:]]/,"",k); gsub(/[[:space:]]/,"",t); gsub(/[[:space:]]/,"",s); if (t !~ /^[ABC]$/) print "tier", i, t; if (s !~ /^(queued|mined|rejected)$/) print "status", i, s; if (k !~ /^(spec|docs|paper|code|tool|dataset|talk|book|community|own-work)$/) print "kind", i, k; if (t=="A" && k=="community") print "tier-inflation", i}' corpus/SOURCES.md
# mined rows whose used-by paths do not exist — must print nothing
awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF==13 {s=$9; gsub(/[[:space:]]/,"",s); if (s=="mined") {n=split($12, a, /[,;]/); for (j=1;j<=n;j++) {p=a[j]; gsub(/^[[:space:]]+|[[:space:]]+$/,"",p); if (p!="" && p!="—") print p}}}' corpus/SOURCES.md | while read -r p; do [ -e "$p" ] || echo "missing: $p"; done
```

### Maintained parser note (outside frozen v1)

The maintained `scripts/sources-census.sh` CLI accepts 0–3 leading ASCII spaces before
Markdown table rows and headings; 4 or more spaces are indented code and are ignored.
The frozen manual census examples above assume column-zero input and remain unchanged.

## Additional corpus rules

These rules supplement, but do not amend, the frozen SOURCES contract v1 above. Their
historical rationale is recorded in `PROTOCOL-APPENDIX.md`, §Appendix, “Corpus sources”
and “Frontier step”.

- **A new knowledge entry opens with its provenance trio.** `source:`, `verified-at:`
  and `recheck:` come first. When the source is external, `source:` cites its `S###`
  row in `corpus/SOURCES.md` alongside the URL and anchor. Freshness sweeps read these
  fields, not provenance buried in prose or HTML comments.
- **A round lesson that mines mistakes carries `## Mistakes`.** Use one row per mistake:
  class · evidence pointer · captured-by (the criterion or rule that should have caught
  it, or `none`) · fix. Prose alone does not record the rejection and its prevention.
- **A fix is shown able to fail before it counts.** Ship a red-before state where the
  same command exits non-clean for the named reason and the fix is the only delta; commit
  the observed failure output.
