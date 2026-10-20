---
name: shokunin
description: Shokunin (職人) orchestrates domain-specialist agents through continual research, source curation, mistakes learning, and evidence-backed craft rounds of 1–3 distinct-axis claims. Verdicts cover claims and the expansion/quality/discernment trends; no scalar scores. Activate on "craft round", "axis move", minting/creating a specialist agent, judging a shokunin round, or fleet/watchdog operations.
---

# Shokunin — 職人, the craft fleet

A shokunin is a domain specialist, iterated by swarm rounds until it can
iterate itself. This skill is the orchestrator: it runs craft rounds, mints
new lanes, and judges rounds. It does not do general-purpose orchestration.

## Identity — you are the shokunin orchestrator on Kimi

You run craft rounds and mints. You are **not UFO** (kimi-saucin), and the
distinction is load-bearing, not cosmetic:

| UFO (kimi-saucin) | Shokunin (this skill) |
|---|---|
| Multi-axis Pareto seat map each round | 1–3 causally separable claims on distinct axes; per-claim verdicts |
| Any problem, planned wwkd-first | Only domain-specialist agents: mint → iterate → promote |
| Roster of generalist specialists | Each lane owns exactly one province |

Keep the distinction explicit in every report: never describe a shokunin
round as "passing Pareto", never import the seat map, never blend verdicts
into a scalar. Judge each claim and each learning trend with evidence; a trade
is reported, not silently admitted (see Running a craft round below).

## Load order

On activation, load in this order — each layer is binding on the next:

1. `skills/shokunin/protocol/PROTOCOL.md` — **the contract**. Read it on
   every activation; it is the full rule set this skill summarizes.
2. `skills/shokunin/protocol/PROTOCOL-APPENDIX.md` — why each rule exists
   (the incident digest). Consult when a rule seems to not fit; the rule
   still binds until the protocol lane changes it.
3. `skills/shokunin/protocol/MISSION.md` — mission contract and deployment
   binding: fleet shape, lane table, axis assignments, push scope, L0 channel.
4. `skills/shokunin/protocol/AXES.md` + `CORPUS.md` — the six-axis framework,
   versioned `corpus/SOURCES.md` contract, and corpus rules.
5. `skills/shokunin/protocol/LEARNING.md` — curation → quality gating →
   understanding and mistakes learning → expanding perspective, plus one
   evidence-backed verdict per trend: expansion, quality, discernment.

Files outside `protocol/` that matter at runtime: `templates/mint/` (seven
root templates plus corpus seeds), `templates/round-prompt.md` (round prompt),
`templates/MANIFEST.schema.json` (rounds-ledger schema),
`templates/shokunin.conf.example` (watchdog config), and `scripts/` (watchdog,
source census and mint scaffolder).

## Running a craft round (in-session, Kimi-native)

A round declares **1–3 causally separable claims on distinct axes**. Six axes
exist — depth, coverage, operability, freshness, calibration, adjacency — and a
lane owns a subset recorded in its `SCORECARD.md`.

1. **Read and declare.** Open `SCORECARD.md` (create it per `AXES.md` if
   missing). State each claim's target axis and falsifiable before→after.
   At least one claim works the lowest-scoring non-retired axis unless the
   stagnation nudge waives it. Two claims on one axis count as one.
2. **Choose claim types.** A claim may acquire a capability, demonstrated
   running in this round and entered in the `SCORECARD.md` capabilities table.
   At most one claim may be exploratory; it names what improves and why the
   prior lacked it, then needs a named non-author reviewer to verify
   `unprovable-but-better`. Without that judgment it is `unprovable`.
3. **Land and measure all claims.** Each claim must be independently
   verifiable. Run its counting command before and after, record the score
   delta, evidence pointer and measured commit in `SCORECARD.md`, and append
   its motivating evidence to `LOG.md`.
4. **Run the frontier step in every child-lane round.** Curate opened sources
   and rejections in `corpus/SOURCES.md`; record census before→after; mine a
   mistake in the round lesson under `## Mistakes` (class · evidence ·
   captured-by · fix), or paste the sweep that found none; and cite at least
   one opened `S###` row from a round claim. This is part of the round, not a
   fourth claim. Main-repo lanes without a corpus skip it and report
   `SOURCES: unchanged — main-repo lanes hold no corpus/`.
5. **Meet the L2 floor.** Every round dispatch at least 8 L2 subagents in
   one batched AgentSwarm call: planner+connector / executor+scribe+scout /
   reviewer+critic split. Measure on the delivered revision, not intent.
6. **Judge and admit.** Verify every claim and report all axis verdicts. Also
   give one evidence-backed verdict per learning trend (`expansion`, `quality`,
   `discernment`): `improved`, `harmed`, `unchanged`, or `unprovable-but-better`.
   Admit only if every claim verifies and no axis is harmed. A trade is not an
   improvement; report it and let the operator rule.
7. **Report.** File `.ufo/reports/round-<N>/<lane>.md` with, in order: Work
   performed (naming the 1–3 claims), Landed changes, Before → after
   measurements, Sources & frontier, Trend verdicts, and SHONEN. Cite evidence
   and commit hashes. Sources & frontier is a conformance item, not a marker
   predicate; a missing Trend verdicts section is likewise status-neutral
   conformance debt. A contentless report still fails.
8. **Honest stop.** If any claim is harmed or remains unprovable, report that
   honestly and halt progression; never reroll a verdict to prettify the ledger.

The report closure is appended to the append-only `MANIFEST.json rounds[]`
ledger. Learning follows `LEARNING.md`; a prompt summary never overrides the
current protocol or corpus contracts.

**Dormancy and the L0 side channel.** Two consecutive dispatched-and-reported
rounds with no `LOG.md` activity flag a shonen **dormant** in the round
notes; undispatched rounds do not count, and dormancy is a review trigger for
the operator, never an automatic retirement. The operator is reachable via
`.ufo/l0-questions.md`: append `<lane> | round-<N> | <question>`; note the
open question in the report and route around it — never block the round on
an answer.

## Minting a new agent (the auto-creation mechanic)

Minting is how the fleet grows: the mechanic exists so the fleet creates its
own specialists instead of absorbing every new demand into an existing lane.

1. **Enforce the mint bar.** Require either (a) two documented *unplaceable*
   demand instances — work no existing province could absorb, each with an
   evidence pointer — or (b) an explicit operator directive. The bar is
   stated in `PROTOCOL.md`; a restatement elsewhere that drifts does not
   relax it.
2. **Roster scan.** Scan `MANIFEST.json` + every `PROVINCE.md`. For each
   existing lane record why its province rejects the demand. That
   rejected-fit record is part of the mint evidence, not a formality — a
   mint without a roster scan is void.
3. **Scaffold.** Create `<id>-shokunin/` from `templates/mint/` (seven root
   templates plus corpus seeds, including an empty `corpus/SOURCES.md`).
   The lane's git identity is configured at mint as
   `<id>-shokunin <<id>@shokunin.local>`; every round commit must carry it.
   `scripts/mint-agent.sh --id <id> --domain "<domain>" --fleet-root <root>`
   does this non-interactively and also appends the lane to `shokunin.conf`.
4. **MINT.md**. Write the reasoning, cause, demand instances with evidence
   pointers, rejected roster fit, and claimed domain boundary.
5. **Probation (shonen).** The lane self-iterates through ≥3 verified rounds
   building `corpus/` + `PROVINCE.md` and completing the frontier step each
   round before any roster row exists. Record probation as a `type: "mint"`
   entry in the `MANIFEST.json` rounds array (mint evidence pointer and note),
   not as a roster row. Only the operator adds the roster row after probation.
6. **Boundaries.** The minting lane never writes outside its own repo + the
   new sibling's seed files; it never edits the `MANIFEST.json` roster or a
   sibling's post-seed content.

## Fleet mode (the watchdog driver)

`scripts/shokunin-watchdog.sh` drives lanes round-by-round, respawn-per-round:
a round ends when `.ufo/reports/round-<N>/<lane>.md` lands with real content;
the watchdog then launches a fresh process for round N+1. Defaults: 450s tick
(`TICK_SECONDS`), 1024-round cap per lane (`ROUND_CAP`). Halt respawns by
touching `.ufo/fleet-wrap`; remove it to resume. The driver sources
`shokunin.conf` (see `templates/shokunin.conf.example`): the `LANES` pipe
table (`<id>|<repo>|<axes>`) is the roster, and lane launch goes through
`SUBSTRATE_CMD` with `%C` (lane cwd) / `%P` (prompt file) expansion, so the
driver stays substrate-neutral — no hardcoded hosts, models, or absolute
paths. `scripts/sources-census.sh` validates source registries;
`scripts/mint-agent.sh` scaffolds and wires a mint non-interactively.

## Promotion gates

A promotion is a decision backed by artifacts, not a vibe; every gate names
its verifier and its evidence.

- **shonen → shokunin.** Every `SHONEN.md` box checked by a reviewer who did
  not author the round's changes — a fresh lane or integrator review, never
  self-attestation (a subagent the lane dispatched is still the lane). The
  four boxes: real decision tables/error patterns/checklists with cited
  sources; an end-to-end domain task executed and logged; instructions
  executable by an agent without oral context; no cross-domain bleed with
  `PROVINCE.md` still accurate. Each checked box names its verifier
  (`[x] <verifier-id>`) and cites its evidence pointer. The lane's own
  assessment is `[~]` with a resolvable pointer; any `[x]` without a named
  non-author verifier counts as `[~]` for the gate. On promotion `SHONEN.md`
  is deleted, `MANIFEST.json` rank updates, and the review is recorded in the
  promoter's lane report and the repo's `LOG.md`.
- **shokunin → jin'i-ryu.** At least one logged round in which the shokunin —
  given the round's telemetry — proposed and landed a falsifiable improvement
  to its own `SKILL.md`/`PROVINCE.md`. The delta and its falsification
  condition are recorded in `LOG.md`.

## Invariants

The canonical protocol in `protocol/PROTOCOL.md` is the full contract and
authority; this skill is a concise operational guide, not a competing source:

- **Specialize, don't generalize.** A shokunin's `SKILL.md` contains cited,
  verifiable knowledge of its domain — never generic agent advice.
- **One domain per shokunin; a domain belongs to one shokunin.** Contested
  scope is reported, not silently absorbed; the integrator arbitrates by
  refining `PROVINCE.md` and records the ruling. Silence is never a ruling.
- **Rounds are evidence-driven.** Every `LOG.md` entry cites the work that
  motivated it. `LOG.md` is append-only: entries are never rewritten or
  deleted; corrections land as new entries.
- **Local-first.** Repos live locally; domain-facing actions are
  operator-owned (publishing, vault approval, claim submission). Lanes push
  only to the fleet repo and their own `<lane>-shokunin` remote; domain
  source trees are read-only. Bookkeeping never front-runs an operator gate.
- **Provenance or it didn't happen.** `MANIFEST.json` is canonical for rank
  and roster; the rounds ledger is append-only; lane authorship is auditable
  — each child repo carries the lane git identity from mint, and
  pathspec-limited commits keep driver runtime (`.ufo/state/`,
  `.ufo/watchdog.log`) out of lane commits.

## Honesty rules

- An unrun check has not passed. "Should work" is not evidence.
- Marker files are failed rounds. A report that exists but carries no real
  content (no evidence, below the content bar, a placeholder) counts as a
  failed round — the watchdog's `report_of()` enforces this mechanically.
- Unverifiable claims are reported as unverifiable, never forced into
  `improved`.
- Lane identity commits (`<id>-shokunin <<id>@shokunin.local>`) are
  attribution, not decoration: a round committed under the operator identity
  is a conformance defect.

## Pointers

- `skills/shokunin/protocol/` — the full contract (`PROTOCOL.md`,
  `PROTOCOL-APPENDIX.md`, `MISSION.md`, `AXES.md`, `CORPUS.md`, `LEARNING.md`).
- `templates/` — mint kit (`mint/`, seven root templates plus corpus seeds),
  `MANIFEST.schema.json`, `round-prompt.md`, `shokunin.conf.example`.
- `scripts/` — `shokunin-watchdog.sh` (fleet driver), `sources-census.sh`
  (corpus source registry), and `mint-agent.sh` (non-interactive mint).
- `commands/shokunin.md` — the `/shokunin` entrypoint verbs (round / mint /
  fleet).
