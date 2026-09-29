# Shokunin Fleet Mission — Source of Truth (fleet-2)

Binding mission instruction for every L1 lane. Changes persist into
`scripts/shokunin-watchdog.sh` prompt generation and are relayed to live lanes
by steer.

## Fleet shape (declared config)

Lanes are declared in `shokunin.conf` at the fleet root — the driver reads the
config each tick; nothing is hardcoded in `scripts/shokunin-watchdog.sh`. Each
lane declaration carries `id`, `cwd` (a repo under `$SHOKUNIN_ROOT` — the two
main-repo lanes point at the fleet root itself), `route` (a route name resolved
through the host model route table, never a bare model alias), and `axes`
(owned axes per `AXES.md`). All L1 lanes dispatch on the `swe`-class route of
the host model route table.

Initial config (the upstream fleet's nine lanes, axes preserved):

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
# every lane: route: swe   (resolved via the host model route table)
```

Round-robin across lanes; `respawn-per-round`: a round ends when
`.ufo/reports/round-<N>/<lane>.md` lands and passes the driver's content check
(`SHONEN` heading + minimum substance per `PROTOCOL.md`); watchdog completes the
mission and launches a fresh process for round N+1. Cap: 1024/lane. Tick: 450s.

## The axes framework

`AXES.md` defines the six expertise axes (depth, coverage, operability,
freshness, calibration, adjacency). A lane's round is **one axis-move**: pick
the lowest-scoring axis in `SCORECARD.md`, land one verifiable improvement,
measure it, record before→after in `SCORECARD.md`, log evidence in `LOG.md`.
Axes may be retired on saturation or split into sub-axes — recorded in
`SCORECARD.md` with the reason. Axis assignments in `shokunin.conf` are initial;
lanes may add/remove axes on evidence (falsifiable claim per move).

## L2 concurrency — required

Every L1 lane MUST dispatch **at least 8 L2 subagents per round**, in **one
batched AgentSwarm call** (the Kimi host surface) — one call carrying all lanes,
not a sequence of individual dispatches. Roles are expressed as lane roles and
routed through the host model route table (persisted globally in
`shokunin.conf` + the operator's route override file):

| Role class | Route bucket |
|---|---|
| planner, connector | heavy-reasoning route |
| executor, scribe, scout | fast-execution route |
| reviewer, critic, sentinel, revenger, labrat, mutation-tester, simplifier, distiller | economy route (fallback: fast-execution route) |

## Round prompt

Dispatch prompts are generated from the shipped ROUND-PROMPT template
(`templates/round-prompt.md`), which embeds the full round contract verbatim:
mission/axes binding, the axis-move rule, the L2 floor (≥8 lanes, one batched
AgentSwarm call), the report path with its required sections (the five
child-lane items), commit-then-push ordering, push scope, and the L0 side
channel. Prompt generation binds to this file; the closure step-1 fidelity
check grades each round's committed `.ufo/prompts/*.md` against the template.

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
