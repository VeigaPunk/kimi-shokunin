# Shokunin Fleet Mission — Source of Truth (fleet-2)

Binding mission instruction for every L1 lane. Changes persist into
`scripts/shokunin-watchdog.sh` prompt generation and are relayed to live lanes
by steer.

## Fleet shape (declared config)

Lanes are declared in `shokunin.conf` at the fleet root. The driver sources this
configuration once at startup and does not reload it each tick. Each `LANES` row
is `<id>|<repo>|<axes>`; `repo` is relative to `$SHONOKIN_ROOT`, and `.` means
the fleet root. The driver derives each lane's working directory from `repo`.
Rows have no per-lane route field. Runtime model selection is determined by
`SUBSTRATE_CMD` and the host/operator's global model routing.

Historical example — the upstream fleet's initial nine-lane roster, in its
original YAML shape; not a current roster or the current `LANES` syntax (axes
preserved):

```yaml
lanes:
  protocol:   { cwd: $SHOKUNIN_ROOT,   axes: "fleet-meta: protocol soundness, gate integrity" }
  aggregator: { cwd: $SHOKUNIN_ROOT,   axes: "cross-lane quality, mint/dormancy calls, corpus review" }
  kasegi:     { cwd: kasegi-shokunin/, axes: "depth + coverage (bounty/security research)" }
  kengaku:    { cwd: kengaku-shokunin/, axes: "novelty + calibration (LLM eval/research)" }
  kake:       { cwd: kake-shokunin/,   axes: "operability + freshness (web properties)" }
  kumitate:   { cwd: kumitate-shokunin/, axes: "operability + coverage (orchestration/tooling)" }
  kotoba:     { cwd: kotoba-shokunin/, axes: "depth + consistency (prompt/skill craft)" }
  kagi:       { cwd: kagi-shokunin/,   axes: "freshness + calibration (secrets/vault ops)" }
  kama:       { cwd: kama-shokunin/,   axes: "operability + freshness (local model serving/endpoints)" }
# Historical YAML only; current LANES rows use <id>|<repo>|<axes>.
```

Round-robin across lanes; `respawn-per-round`: a round ends when
`.ufo/reports/round-<N>/<lane>.md` lands and passes the driver's content check
(`SHONEN` heading + minimum substance per `PROTOCOL.md`); watchdog completes the
mission and launches a fresh process for round N+1. Cap: 1024/lane. Tick: 450s.

## The axes framework

`AXES.md` defines the six expertise axes (depth, coverage, operability,
freshness, calibration, adjacency). A lane's round declares **1–3 claims**,
each an axis-move on a distinct axis with its own falsifiable before→after (at
least one on the lane's lowest non-retired axis; a claim may be a capability
acquisition or an exploratory taste-bound claim per `AXES.md` — exploratory
claims verify only as `unprovable-but-better` with a named non-author reviewer
on record): land the improvements, measure each, record before→after per claim
in `SCORECARD.md`, log evidence in `LOG.md`. A round admits only when every
claim verifies and no axis is harmed.
Axes may be retired on saturation or split into sub-axes — recorded in
`SCORECARD.md` with the reason. Axis assignments in `shokunin.conf` are initial;
lanes may add/remove axes on evidence (falsifiable claim per move).

## Frontier step

Every child-lane round curates `corpus/SOURCES.md` under the versioned contract
in `CORPUS.md`, mines one mistake into its lesson (or records the sweep that
found none), and cites at least one opened source row (`S###`) in a round claim.
This step is part of the round, not an additional claim. Main-repo lanes without
a corpus do not run the child-lane step; their report records
`SOURCES: unchanged — main-repo lanes hold no corpus/`.

## L2 concurrency — required

Every L1 lane MUST dispatch **at least 8 L2 subagents per round**, in **one
batched AgentSwarm call** (the Kimi host surface) — one call carrying all lanes,
not a sequence of individual dispatches. Roles are expressed as lane roles and
routed through the operator's global host model table; `shokunin.conf` carries no
per-role route pins. The grouping below is advisory to host routing, not a
driver-enforced route assignment:

| Role class | Route bucket |
|---|---|
| planner, connector | heavy-reasoning route |
| executor, scribe, scout | fast-execution route |
| reviewer, critic, sentinel, revenger, labrat, mutation-tester, simplifier, distiller | economy route (fallback: fast-execution route) |

## Round prompt

Dispatch prompts are generated from the shipped ROUND-PROMPT template
(`templates/round-prompt.md`), which embeds the full round contract verbatim:
mission/axes binding, the 1–3 claim rule, the child-lane frontier step, the L2
floor (≥8 lanes, one batched AgentSwarm call), the report path and its required
sections (work, landed changes, before→after measurements, Sources & frontier,
trend verdicts, SHONEN), commit-then-push ordering, push scope, and the L0 side
channel. Prompt generation binds to this file; closure grades committed
dispatch prompts against the template.

## Round end

Commit inside the owning repo then `git push`. Reports: `.ufo/reports/round-<N>/<lane>.md` on the main repo, commit + push.

## Push scope — hard rule

Lanes push ONLY to the fleet repo (`$SHOKUNIN_ROOT`, remote operator-chosen) or
their own `<lane>-shokunin` remote. Domain source trees (operator-designated
read-only checkouts outside the fleet root) are read-only surfaces: never
commit there, never push to their remotes. Work that belongs upstream is
documented in the lane report; the operator owns those pushes.

## L0 side channel

The operator is reachable via `.ufo/l0-questions.md` in the fleet repo: append a
line `<lane> | round-<N> | <question or decision needed>`. The aggregator lane
surfaces entries each round; the L0 answers by editing the file in place.
