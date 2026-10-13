# Shokunin Protocol

> 職人 — an artisan specialist that earns its domain through demonstrated craft.

A **shokunin** is a domain specialist, iterated by swarm rounds until it can iterate itself.

## Fleet root and substrate

All paths in this file are relative to the fleet root, `$SHOKUNIN_ROOT` (default chosen by the
operator). Fleet state lives under `$SHOKUNIN_ROOT/.ufo/` (`state/`, `prompts/`,
`reports/round-N/`, `waves/`, `watchdog.log`, `l0-questions.md`, `history-pin.json`); lanes live
under `$SHOKUNIN_ROOT/<id>-shokunin/`. The driver launches a lane process via the configured
substrate command (see `scripts/shokunin-watchdog.sh`), resolving models through the host model
route table (see `shokunin.conf`); nothing in this file depends on a specific substrate CLI or
model alias. The upstream fleet ran on one specific substrate and model aliases — every rule here
is substrate-neutral, and the appendix's host notes mark the places where an incident row cites
that deployment.

## Lifecycle
```
mint → shonen (apprentice) → shokunin (artisan of a domain) → jin'i-ryu (self-iterating)
```

At every rank the learning signal is the path in `LEARNING.md`: corpus
expansion, rising quality, and increasingly well-calibrated recognition of
quality, each judged per round.

- **Shonen** — minted when a domain demand is proven: two documented *unplaceable* demand instances
  (work no existing province could absorb) or an explicit operator directive — the mint bar, stated
  once here; closure step 3 applies it. It starts with a scoped `SKILL.md` + `PROVINCE.md`, an empty
  `LOG.md`, and a domain record in `MANIFEST.json`.
- **Shokunin** — promoted when it demonstrably performs domain work end-to-end, per the gate below:
  its `LOG.md` shows completed rounds and a reviewer can execute the written instructions without
  oral hand-holding.
- **Jin'i-ryu** — promoted per the gate below when it can iterate on itself; the main repo
  aggregates only promotion/mint decisions.
- **Sibling mint (lane-initiated)** — any lane may mint a sibling when it finds a domain demand no
  existing province owns. In order: (a) scan `MANIFEST.json` + every `PROVINCE.md` and
  records the roster map it decided against — that scan record is part of the mint evidence; (b)
  create the sibling's repo dir `{id}-shokunin/` under the fleet root and its git remote
  (hosting operator-chosen; conventionally a single org/account owns `{id}-shokunin` remotes),
  seeding the canonical files (SKILL.md, PROVINCE.md, HOURS.md, SHONEN.md from the canonical template,
  AGENTS.md, LOG.md) plus a `MINT.md` stating the reasoning, the cause, the
  demand instances with evidence pointers, the rejected roster fit, and the claimed domain boundary;
  (c) wire it into the driver — a lane declaration in `shokunin.conf` (cwd under the fleet root,
  model route, axes; operator-side integrator work,
  surfaced in `.ufo/l0-questions.md` if the lane lacks the route map); the sibling
  self-iterates through at least three verified rounds building `corpus/` + `PROVINCE.md` before
  roster rows exist; (d) only after those rounds land does the operator add the `MANIFEST.json`
  roster row and `ROADMAP.md` table row — probation state is recorded in `rounds[].notes` meanwhile,
  not as a roster row. The minting lane never writes outside its own
  repo + the new sibling's seed files, and it never edits `MANIFEST.json` roster or a sibling's
  post-seed content.

Two consecutive dispatched-and-reported rounds with no `LOG.md` activity flag a shonen **dormant**
by the integrator in the round notes; undispatched rounds do not count against it. Dormancy is a
review trigger for the operator, never an automatic retirement.

## Promotion gates

A promotion is a decision backed by artifacts, not a vibe; every gate names its verifier and its
evidence.
- **shonen → shokunin.** Every `SHONEN.md` box checked by a reviewer who did not author the round's
  changes — a fresh lane or integrator review, never self-attestation; a subagent the lane
  dispatched is still the lane. Each checked box names its reviewer (`[x] <verifier>`) and cites its
  evidence pointer. The lane's own assessment is `[~]` asserted (with its evidence pointer); only a
  non-author `<id>` may write `[x]`, and any `[x]` carrying no named non-author verifier is author
  attestation counting as `[~]` for the gate. Minimum bar: the seed below changes only with this gate text.
  Box 1 needs at least one `SKILL.md` decision table, error-pattern list, and checklist, each citing a
  resolvable source (repo path, command output, or external document); box 2 requires an end-to-end
  task executed and logged; box 3 requires `SKILL.md`/`corpus/` instructions executable without oral
  context, self-contained, and with resolvable pointers; box 4 bars cross-domain bleed and keeps
  `PROVINCE.md` accurate.
On promotion `SHONEN.md` is deleted, `MANIFEST.json` rank is updated, and the review is recorded in
the promoter's lane report and the repo's `LOG.md`.
- **shokunin → jin'i-ryu.** At least one logged round in which the shokunin — given the round's
  telemetry — proposed and landed a falsifiable improvement to its own `SKILL.md`/`PROVINCE.md`. The
  delta and its falsification condition are recorded in `LOG.md`.

## Craft-hours — the 10,000-hour bar

A shonen becomes a shokunin only after **10,000 verified craft-hours** in its domain — the
mastery horizon, borrowed from the craft tradition the name comes from.

- **A craft-hour is one hour of verified in-domain lane work.** Time is *collective*: an N-lane
  swarm wave spending T minutes of in-domain work logs N×T craft-minutes. Parallelization is the
  intended accelerator — swarms compress calendar time, never the substance, because every logged
  lane-minute must be executed work with its evidence, and verification rules are unchanged by
  lane count.
- **Ledger.** Each lane keeps `HOURS.md` at repo root, append-only, one row per round:
  `round | lanes | in-domain lane-min | verified | evidence | cumulative (h)`. `verified` carries
  `[x]` (non-author evidenced) or `[~]` (lane-asserted with pointer); the cumulative column is the
  number the promotion gate reads.
- **What counts.** Only in-domain work accrues: meta, protocol, fleet-ops and other lanes'
  provinces log zero toward this lane. Honest rejected candidates still accrue — discernment
  practice is practice — provided the round itself executed and reported. A fabricated or
  unverifiable entry voids its row (artifact-trust rule) and is a protocol violation.
- **Retroactive crediting.** Pre-ledger rounds may be credited only by recomputation from
  artifacts (round reports, wave dirs, dispatch/commit timestamps) and are marked `[~]` estimate
  or `[x]` evidenced — never freehand numbers.
- **Necessary, never sufficient.** The floor is an additional requirement on top of the SHONEN
  checklist: a lane cannot burn idle or rubber-stamped lane-time into rank, because the gate
  still demands demonstrated artifacts checked by reviewers who did not author them. Hours buy
  depth; the gate buys demonstrated competence; both are required.

## Round-robin rounds

Each round, the orchestrator dispatches up to one swarm lane per rostered shokunin (round robin). A
shokunin with no dispatched lane participates in the round only as scope available to other lanes —
never as an implicit no-op.
Rounds are driven externally (a scheduler/steer names the round number); the steer advances the
round, the lane owns the work content. Round numbers are monotonic; a lane must not claim a round
other than the steered one — in commits, `LOG.md` entries, corpus lessons, and reports alike. A
round the driver skipped produces no entry rather than a mislabeled one; several entries for one
steered round are allowed.
Round prompts are snapshots: where a prompt — or any earlier round's instructions — conflicts with
the current `PROTOCOL.md` or `CORPUS.md`, the repo files win. A lane re-reads the protocol at the
start of every steered round; a long-lived mission does not grandfather superseded rules.
Round prompts embed the operative contract verbatim — the full round contract, not a convenience
summary. Each *child-lane* prompt carries, as quoted protocol text, the round-level contract:
(i) the mission/axes binding — `MISSION.md` and `AXES.md` govern the round and the lane works
exactly one axis-move; (ii) the L2 minimum — at least 8 L2 lanes in one batched AgentSwarm call
(the Kimi host surface), a number this file does not own: `MISSION.md` §L2 concurrency is its
source; (iii) commit-then-push ordering; (iv) push scope; and (v) the L0 side channel — plus the
five child-lane items: the report path and filename, the commit-before-report ordering, the
`SHONEN` heading requirement, the commit-hash citation rule, and the lane's write scope. The
shipped ROUND-PROMPT template (`templates/round-prompt.md`, operator-side) embeds all of these
verbatim — the full round contract and all five child-lane items; a dispatched prompt missing any
of them fails the step-1 fidelity check below. (The upstream fleet's template carried only 1 of the
5 child-lane items — §Appendix, "Prompt embeds contract".) The
aggregator prompt instead embeds *its* operative set verbatim: report path, the ledger path and
refresh duty, child-repo commit ownership (its own files, pathspec-limited), the corpus-only write
scope, and the L2 minimum — a number this file does not own: `MISSION.md` §L2 concurrency is its
source. The protocol prompt embeds its own duties: this file's re-read requirement, the
integrator-of-record closure steps, and the L2 minimum. This file alone reaches the lanes that
re-read it (§Appendix, "Prompt embeds contract"); the integrator's report must carry the exact
corrected `lane_prompt()` text required, since `scripts/` is operator-side.
Rounds are per-lane counters, not a fleet-global clock: the driver keeps `.ufo/state/<lane>.round`
and lanes can sit on different round numbers at the same wall-clock moment. `reports/round-<N>/`
collects whichever lanes ran their Nth round; the integrator closes round `<N>` per lane, not per
fleet.
A lane report **lands last** — written only after the lane's child-repo work is committed, and it
must cite that commit's hash. Landed means committed, so changes that exist only in a working tree
do not count for the round. The cited hash is the lane repo's `HEAD` when the report is written: a
hash the repo does not contain fails verification, and one that is not an ancestor of `HEAD` at
closure is a conformance defect (`git merge-base --is-ancestor <hash> HEAD` is the check).
A lane whose report is still uncommitted when its mission completes has not satisfied this clause.
Corrections land as new commits, never by amending a cited one (amending or rewriting orphans the
record); append-only files (`LOG.md`) take an appended correction entry pointing at the superseded
text, never an in-place rewrite. Landed also means landed *by the lane*: the commit that adds
`.ufo/reports/round-<N>/<id>.md` carries the lane identity, since any later fleet-level commit can
sweep it (§Appendix, "Lands last"). A swept report is still landed — history is never rewritten to
fix attribution — but the integrator records the attribution defect in the round notes. An orphaned
report is resolved in order: the lane's own respawn inherits and lands it first;
the integrator sweeps it for durability only if that successor mission also terminates without
landing it, recording the attribution defect, and the order never reaches aggregator-owned `corpus/`
files (§Appendix, "Orphaned report"). A terminated lane-round with an unlanded report is
recorded on its termination evidence with the durability debt named; the next pass
re-grades it `failed` for want of a landed report if the successor never lands it. A filed report is
a record: a correction to it lands in the correcting round's own report, or as an erratum
appended after the filed bytes in a new commit and naming the text it supersedes — never a rewrite
of the filed bytes, labelled or silent.
Every dispatched lane writes its report at `.ufo/reports/round-<N>/<id>.md` in the main repo, where
`<id>` is the roster id (`protocol` and `aggregator` for the two main-repo lanes). A report under
any other name does not satisfy the contract. The report file's existence is also the respawn
driver's round-completion signal: a lane that finishes all other work but files no report keeps the
*driver's* mission open until the stale-lane rule below fires, while a missing report never
holds a round open in the *integrator's ledger* — there the lane-round is recorded `failed` at
closure. Minimum content:
- work performed and evidence pointers (paths, commands, diffs);
- changes landed in the child repo, each tied to a `LOG.md` entry;
- cross-domain evidence encountered, with the domain it belongs to;
- a `SHONEN.md` checklist assessment for that lane's shokunin, under a `SHONEN` heading with one
  line per box (`[x]` / `[ ]` / `[~]` + pointer). A report without this heading does not satisfy the
  contract even if the same facts appear elsewhere in it; `[~]` means asserted-by-author, not
  skipped. Consequence: it is a conformance defect AND disqualified as evidence in that lane's
  promotion review — the assessment (reports are filed once; the assessment is not) must be re-filed
  under the heading in the next round's report.
A lane whose mission has terminated or been respawned without filing its round report is recorded
`failed` by the integrator. `failed` covers every lane-round that was prompted or dispatched and has
no report by closure, including an orphan prompt from a failed launch (step 4). A mission still open
more than two driver ticks after its steer is a stale-lane review trigger; the integrator may record
it `failed`. The trigger needs an actuator: every dispatched lane's report must list any mission
open longer than two driver ticks — age from the launch timestamp, not the tick counter (it resets
when the driver restarts) — and must say whether it is *progressing* or *silent*. Progressing means
observable activity in the lane's write scope since its launch — a commit authored by the lane, or
files modified under its repo (`find <repo> -newermt <launch-ts> -type f -not -path '*/.git/*'`);
silent means neither. A commit authored by *another* lane is not the subject lane's activity, since
the aggregator writes into every child repo, so
sibling-authored activity alone is a third grade, `progressing-weak`: named as such in the row,
never called progressing, and never silent or `failed` on its own. Commit sparsity is the norm
(§Appendix, "Stale-lane actuator"), so the absence of a commit is not silence and must not trigger
`failed`. The integrator-of-record records `failed` only for silent missions and flags progressing
ones in the round notes — and the driver's respawn path is unreachable while its daemon is up (step 4), so nothing in this section terminates live work: recording `failed` is a ledger act, not a kill.
A respawned mission inherits its predecessor's working tree: uncommitted *lane-authored* changes it
finds are uncommitted round work under the landed-means-committed rule — the new lane resolves them
(commit-under-its-entry or revert) before it files its own report. Uncommitted **aggregator-owned**
files (`corpus/lessons/round-*-aggregator-*`) are not the lane's to commit: the lane records them in
its report and leaves them for the aggregator to resolve.
A file at the report path is not automatically a report, and report existence alone is a gameable
completion signal — this is a known hole, closed here. The driver's completion check
(`report_of()` in `scripts/shokunin-watchdog.sh`) validates report **content**, not merely the
path's existence: a file at the report path completes a lane-round only if it carries the `SHONEN`
heading with one `[x]`/`[ ]`/`[~]` line per box **and** the minimum substance above — work
performed, at least one evidence pointer, changes landed in the child repo each tied to a `LOG.md`
entry, and a checkable commit-hash citation. A contentless **completion marker** at that path
closes nothing: it never fires the driver's completion signal, the lane's mission stays open until
the stale-lane rule below fires, and the integrator records that lane-round `failed` at closure
(§Appendix, "Marker vs report"). A filed
report recording no lane work — no changes, no evidence pointer, no resolvable commit — is a marker,
not a report: the integrator records that lane-round `failed`, keeps the marker file as a
conformance defect, and names the counter advancement in the round notes. A short report naming a
real committed round-work hash is a *defective* report, not a marker: status `ok`, minimum-content
defect recorded. A marker naming nothing checkable is `failed` whatever the lane actually did — real
work sitting unattributed in child repos does not rescue it. This does not relax step 1: contract
violations inside a real report stay status-neutral defects.
**Integrator of record.** The integrator this protocol assigns work to is the round's `protocol`
lane — a role, not a separate rostered lane; where a generated driver prompt conflicts (e.g. "never
MANIFEST.json"), this file wins per the snapshot clause. Its main-repo writes are `PROTOCOL.md` and its
REQUIRED sibling `PROTOCOL-APPENDIX.md`, `ROADMAP.md`/`SCORECARD.md`/`LOG.md`/its own report; those
expand by exactly six: appending `MANIFEST.json` `rounds` entries, the conformance/routing record in
its own report (the round notes), committing already-generated `.ufo/prompts/*.md`, committing
`.ufo/l0-questions.md`, committing the round's closure-gate artifacts under `.ufo/waves/round-<N>/`, and
writing/committing the append-only history pin `.ufo/history-pin.json` — the sixth, added in round 13;
regenerating a pin is a separate committed act named in the round notes, never a repair inside the same
closure pass. It never edits a prompt or the script, and `scripts/` plus `.ufo/state/` remain
operator-side (§Invariants);
required template corrections are named in its report. Its closure artifact is its own round report:
a protocol-lane report carrying no closure record — the statuses it wrote, or a statement of why none was writable — is an incomplete report whatever else it contains.
Text only in this file reaches the lanes that re-read it, and that is the only guaranteed delivery
channel: generated protocol prompts name none of steps 1–4 (§Appendix, "No closure channel"), so the
duty reaches the lane through this file's re-read. The closure record is a gate, not prose: steps 1
and 4 run through a committed checker whose frozen re-run reproduces every status the entry carries
(§Gate standard, "Two evidences"), so a closure record no reader can re-execute is an opinion.
A round is **completed** when every dispatched lane has either reported or been recorded failed by
the integrator — a failed lane counts; a missing report does not. Fleet-wide completion is never
observable (§Appendix, "Closure entries"); closure is therefore per lane-round: each protocol round
the integrator closes every lane-round that terminated since its last pass plus any older one still
carrying an unresolved row (step 4). After closing, the integrator:
1. Reads every lane report and verifies each cited child-repo commit exists *and is an ancestor of
   the lane repo's `HEAD`*; verifies no participating repo is left with uncommitted round work
   (uncommitted aggregator-owned files are reported, not lane debt); checks each report for the
   contract-required `SHONEN` heading; checks the round's dispatched `.ufo/prompts/*.md` carried the
   full round contract verbatim per the embed clause above — the round-level items and the five
   child-lane items — **and that any L2 route map quoted in the prompt matches the current
   `MISSION.md` bucket**. A report violating the report contract (missing
   heading, dead or orphaned hash, report filed before its commit) or a prompt missing embedded
   items is a conformance defect in the round notes — it does not change the lane's status unless
   the round's rules already prescribe `failed`.
2. Lands warranted protocol improvements in this file (a valuable feature found by any domain
   generalizes to the protocol); routes cross-domain defects a lane report filed against a sibling's
   files to the owning lane — the integrator's report carries one routing line per defect
   **including defects a lane owes its own repo** (self-defects ride the same durable queue; routing
   is integrator work and must exist in an artifact). The aggregator mirrors each routed defect into
   the owning repo's `corpus/lessons/` and keeps an **open routed-defects row** in its ledger until
   the owning lane's correction lands; unresolved rows are re-flagged each audited round, and after
   any absence the aggregator sweeps intervening lane reports and round notes, reconciles ledger rows
   before new audits. The ledger row, not round notes alone, is the durable queue: defects outlive the round that routed them.
3. Mints a new shonen only if evidence shows an unserved domain — minimum evidence per **Lifecycle**
   (the mint bar stated once there). `ROADMAP.md` restates the bar; where a restatement drifts, this
   file wins and the drift is a round-notes defect.
4. Appends one entry to `MANIFEST.json`'s `rounds` array (integrator-of-record scope; each lane's
   own `LOG.md` entry remains lane work, not integrator work — lanes write inside their own repos).
   Round-entry shape:
   `{round, date, type, lanes: {<id>: <status>}, promotions: [{id, from, to}], minted: [id...], notes}`
   where `<status>` is `ok | failed | not-dispatched | in-flight`. `type`, `closed_at`,
   `protocol_updates`, and other annotation keys are optional. Semantics under a per-lane-counter
   driver:
   - **Non-closure entry types are recognized, never silent.** A `type: "mint"` entry records a
     lane-initiated sibling mint: it carries no `lanes` map, is excluded from lane-status tallies,
     and names its mint evidence pointer, the probation note, and whether the roster/`ROADMAP.md`
     rows landed or are pending. A gate reports it as a recognized non-closure entry, never skips it.
   - **Partial entries are the norm.** Write the entry for round `N` as soon as one lane's Nth
     lane-round terminates: a terminal status for every `N` lane-round that has terminated,
     `in-flight` for lanes dispatched and still open, `not-dispatched` for lanes with no dispatch
     evidence **as of `closed_at`** — so `closed_at` is required on any entry carrying a
     `not-dispatched` row.
   - **Dispatch evidence** is the `.ufo/watchdog.log` dispatch line — `launch <lane> round=N`
     (respawn driver, written only after a successful launch) or `steer <lane> -> round N`
     (steer-era driver; the earliest rounds had no prompt files, so a prompt-only test misreads real
     lane-rounds as undispatched — §Appendix, "Dispatch evidence"). The committed
     `.ufo/prompts/<lane>-round-N.md` corroborates mission *content* and must be committed to be
     durable, but `lane_prompt()` writes it before the launch attempt — a prompt with no dispatch
     line is an attempted dispatch and records `failed`. **Completion evidence** is a
     `.ufo/reports/round-N/<lane>.md` that satisfies the report contract; a completion marker is not
     a report and makes the lane-round `failed`. **Termination evidence** is a `complete <lane>
     round=N` line or the lane's counter passing `N`. Liveness probes are not evidence of an open
     mission: the driver daemon's status probe still lists a completed mission, so the driver's
     `live` test can never fail while its daemon is up (§Appendix, "Liveness probes").
     `in-flight` is therefore decided from
     the absence of both a `complete <lane> round=N` line and a *landed* report — an
     uncommitted file at the report path does not end `in-flight`, however it fires the driver's
     existence signal (§Appendix, "Unlanded report") — and never from a status probe.
     `.ufo/watchdog.log` is mutable and the driver appends to it concurrently, so its line numbers
     drift: the round notes carry a committed digest (timestamp + text) of every dispatch/complete
     line a status rests on, and that digest — not the live log — is the pointer that resolves at
     closure.
   - **`in-flight` is debt, not a resting status.** Every `in-flight` row is answered by the next
     protocol round — resolved to a terminal status or re-confirmed with evidence — which appends
     `{"round": N, "type": "closure-correction", "closed_at": …, "lanes": {<id>: <status>}}` — never
     an in-place edit. A lane dispatched for its Nth round *after* round `N` closed rides the next
     closure-correction for `N` — never dropped, never folded into `N+1`; an `in-flight` row still
     live at the next pass is re-confirmed by a closure-correction carrying `in-flight` plus the
     launch pointer and stays debt until the mission terminates.
   - No lane may be recorded `not-dispatched` while dispatch evidence for that lane-round exists,
     and no lane may be recorded `in-flight` unless its mission was live at `closed_at`. A row
     contradicting evidence is a conformance defect of the entry (§Appendix, "Closure entries").
   - **A row names the lane-round it describes.** `lanes` values stay status strings; the optional
     `lane_rounds: {<id>: <n>}` map records a lane's own counter where it differs from the entry's
     `round` and is required on every `not-dispatched` row. The row describes lane-round `(<id>,
     round)`: `lane_rounds` annotates it and never re-keys it, so
     last-wins is computed over `(id, entry.round)`; reading the map as the key erases in-flight
     debt and manufactures rows out of the pre-fleet-2 fleet-keyed entries, which
     carry no `lane_rounds` and are `unadjudicable` as lane-rounds (§Appendix, "Row identity"). An
     `ok` row needs no pointer — `.ufo/reports/round-<n>/<id>.md` is derivable, and its absence
     falsifies the row. `failed`, `in-flight`, and `not-dispatched` rows carry their pointer in
     `notes`.
   - **Retroactive closure is typed, and is not a pass.** Entries for lane-rounds that terminated
     before the integrator role existed carry `type: "retroactive-closure"` and notes stating that
     the statuses are presence-of-evidence only, that step-1 verification (hash ancestry, `SHONEN`
     heading, prompt fidelity) did not run at the time, and — for rounds before fleet-2 (`609ecb6`)
     — that no axis-move duty existed. Promotion and axis reviews must never read a retroactive row
     as a contemporaneous pass.
   - **`rounds` is append-only after closure.** Corrections are appended entries carrying `type:
     "closure-correction"` and `supersedes: {round, type, date}` naming the row they replace — never
     in-place edits, never prepends, because index citations into the array must keep resolving.
     Where two corrections share round+type+date that triple names no unique row, so `supersedes`
     MAY also carry `entry` — the array index, stable precisely because the array is append-only —
     and a gate treats a correction that needs the disambiguator and omits it as ambiguous
     (§Appendix, "Append-only `rounds`"). Consumers read the array in order; `rounds[].round` is not
     unique and the last row for a lane wins.
   - **History is pinned.** `.ufo/history-pin.json` pins `sha256(rounds[0:k])` for the closed prefix
     plus the commit whose `MANIFEST.json` bytes hash to it; the closure gate reports
     `history_pin_mismatch` when closed history was edited in place and `history_pin_unanchored`
     when the pin was regenerated to bless an edit. Appends never invalidate it.
The **aggregator** lane is a main-repo lane that reviews every child repo's `corpus/` each round
(per `CORPUS.md`), files gaps as lessons inside the child repos, and files its own round report at
`.ufo/reports/round-<N>/aggregator.md`. Its report covers per-repo corpus verdicts and cross-lane
learnings. It is the sole exception to lane write-scope: it may create or repair `corpus/` inside any
child repo, and nothing else — no main-repo files outside its own report and ledger. Every file it
creates inside a child repo is **committed by the aggregator itself at creation time**, pathspec-limited
to its own files, under its own subject (`corpus: round-<N> aggregator …`) — never left uncommitted for
a lane's round commit to sweep, and a lane never commits an aggregator-owned file. Alongside the
per-round report it maintains one rolling audit ledger — canonically `.ufo/reports/AGGREGATE.md`,
and no third path counts; a superseded
snapshot elsewhere is relocated there by its next refresh and remains readable evidence, superseded
and not voided. While the canonical ledger is absent or unrefreshed, the integrator's round notes
are the queue of record (§Appendix, "Ledger"). The ledger is append-only in the same sense as
`LOG.md` — refresh sections supersede earlier rows explicitly rather than rewriting them. An
aggregator round report is incomplete unless the ledger was refreshed or the report names why no row
changed. A round filed without the ledger duty keeps the routed-defect queue empty by construction.

## Evidence standard

Everywhere the protocol says *evidence*, it means a resolvable pointer: a repo path, a command and
its output, a commit, or an external document — never a naked assertion. A `LOG.md` entry without a
pointer is not evidence; an unreachable claim in a lane report does not exist.
An **end-to-end domain task** is one real work item executed against the domain's actual surfaces,
logged as trigger → action → outcome → pointer. Where the domain's terminal action is operator-owned
(§Invariants, local-first), executed means *prepared + verified + handed off*: the handoff artifact
is the outcome pointer, and a documented negative result at that gate still counts.
A numeric claim carries its counting command, an absence claim its search sweep, and a quote its
location (frontmatter/body, file, line) — the `CORPUS.md` rules bind `LOG.md` entries and lane
reports too, not only `corpus/`. A status command printing configured values is not evidence of
capability: endpoint/ability claims need a probe against the real surface.
An evidence pointer must resolve at *closure* time, not only at write time: paths under `tmpfs`
(`/tmp`, `/dev/shm`), session-scoped `local://` artifacts, and any pointer a fresh session cannot
reach are not evidence — commit the artifact or cite a reproducible command. A timestamp on evidence
must be at or before the commit that ships it — future-dated evidence is a conformance defect
(§Appendix, "Evidence standard").
- **Claimed ≠ re-executed.** A command offered as evidence is a re-run performed at write time with
  its observed output — never an output quoted from memory or a prior session.
- **Corrections sweep every mention.** Before a round's commit, grep every file the lane touches
  (`corpus/README.md`, `SKILL.md`, `knowledge/`) for the superseded claim — a corrected fact left
  standing in a sibling file is still a defect.
- **A falsified claim in an append-only file gets a named correction entry in the lane's next
  round** — appended, never rewritten; it stays on the routed-defect queue until it lands.
- **Commits are cited by hash, never by subject or tag** — `git rev-parse round-4` fails wherever
  the tag doesn't exist.
- **Drift pins.** A pin counts only if its expected values are **persisted inside the repo** (a
  recorded sha/mode/lines baseline, or a committed expected-output file the script diffs against); a
  fingerprint *printer* with no stored baseline cannot detect drift; a pin is `RECOMMENDED` where the
  cited surface is outside the lane's control.

## Gate standard

A **gate** is a committed, re-runnable verdict script a lane owns: it reads surfaces, compares them
against expected values persisted in its own repo, and returns a verdict. A tool that cannot fail is
a **probe**, and is registered as one.
- **Verdict.** `0` = `clean` and `1` = `failed` fleet-wide; every other code a gate exits (`2`, `3`,
  `64`, …) is declared in its registry entry and mapped onto `clean | failed | could-not-evaluate`,
  and an undeclared nonzero code reads as `could-not-evaluate`. Nothing else is pinned: a gate's own
  vocabulary — WARN vs HIT, a missing baseline, finding kinds — stays lane-owned, and this section
  governs the outer interface only.
- **Self-test.** Every gate exposes a self-invocation mode over isolated fixtures (temp trees, no
  network, no live-tree write) asserting both the exit code and a stable expected finding-id, with
  the expected values committed in the owning repo and independent of the recomputation. The flag
  spelling is the lane's (`--selftest`, `--self-test`, `run_selftest()`)
  and the registry records it; a helper-only or model-only self-check does not satisfy this clause.
- **Two evidences.** Self-test green is capability, not a measurement (§Evidence standard). A gate
  whose verdict depends on a mutable fleet artifact also ships a run over a committed input snapshot
  with its committed expected verdict, so a later hand-edit of that artifact contradicts the frozen
  run. A verdict names the revision it was measured against: a gate grades the tree it runs on, so a
  run over a moving worktree is not comparable to one over the cited commit. A frozen baseline's
  `expected.json` MUST pin the digest of every snapshot input file, and the gate verifies those
  digests before comparing verdicts: an edited snapshot is `snapshot_tampered` (could-not-evaluate),
  not a compared verdict, and a baseline without digests is reported `unpinned (legacy)`.
- **Registry.** The schema is this section's; the rows live in each lane's `SKILL.md`: name,
  `gate|probe`, entry command, verdict map (code → class), self-test command and spelling,
  pinned-value path, write scope, owner. The aggregator ledger stays the routed-defect queue, not a
  second inventory; a fleet index is pointers to lane rows, never copied expected values. Frozen
  baseline names resolve under any `.ufo/waves/*/frozen` root; a bare name matching more than one
  root fails closed.
- **Scope.** Read-only over surfaces it does not own, and it never acts on an external surface —
  publishing, vault approval, claim submission and driver mutation stay operator-owned (§Invariants,
  local-first). A verdict is lane-local evidence: it
  never defines the host runtime's stop conditions (`loop_stop`/`mission_goal`) and
  never stands in for the native judge.
- **Closure consequence.** A red gate is a conformance defect recorded in the round notes and routed
  to its owner — status-neutral unless the round's rules already prescribe `failed`; gate redness is
  never the marker predicate, since step 1 grades marker-versus-real-report first and only a marker
  invokes `failed`. The integrator verifies a gate's *committed evidence* (self-test tally,
  frozen-run verdict, the revision measured); it does not execute a sibling's gate, whose
  dependencies and write scope are the lane's.
- **Delivery.** This section reaches a lane through the re-read duty, not the driver's prompt
  template (one of five child-lane items): the integrator names the exact `lane_prompt()` addition
  in its round report, and closure grades no gate conformant until its registry row exists in the
  lane's own `SKILL.md`.
  The closure gate verifies the history pin (§Round-robin step 4) as committed evidence; a pin
  failure is a conformance defect routed under Closure consequence.

## File contract per shokunin repo

| File | Purpose |
|---|---|
| `SKILL.md` | The specialist's craft: triggers, decision tables, error patterns, checklists, cited sources. Its frontmatter `description` carries quoted trigger strings, an anti-trigger, and a sibling-arbitration note — capability-and-scope-only descriptions misroute |
| `PROVINCE.md` | Domain boundary: what it owns, what it refuses, its work surfaces. Declared surfaces must resolve; when a lane finds a surface moved or absent it corrects `PROVINCE.md` to the real path and logs the correction |
| `LOG.md` | Append-only iteration log: round entries, accepted changes, falsifiable next-iterations |
| `SHONEN.md` | Promotion checklist to shokunin; generated at mint by copying the canonical template (below) verbatim and deleted on promotion. Gates evolve — when they change, the owning lane regenerates `SHONEN.md` verbatim from the template on its next steered round (the lane is the only allowed writer inside its repo). Verification is mechanical: the seed block (indented lines below) must diff byte-identical modulo `<name>` = the repo's directory name, and marks are confined to the box character plus one indented evidence line per box — `[x] <verifier-id>` or `[~]` with a resolvable pointer; no other prose, added boxes, or removed boxes (§Appendix, "Canonical form") |
| `AGENTS.md` | Operating rules when working inside this repo |
| `corpus/` | Proprietary knowledge corpus per `CORPUS.md`: `README.md` index, `knowledge/` sourced domain notes, `lessons/` per-round training lessons; reviewed by the aggregator lane every round |
| `SCORECARD.md` | Axis scores per `AXES.md`: owned axes → score 0–10 → evidence pointer → last-change round, plus `planned` and `retired`. Every score is a claim: it carries the counting command that produced it and the commit it was measured against, so a reader can re-derive it |
| `PROTOCOL-APPENDIX.md` | Main repo, protocol-lane owned: the incident digest that motivates `PROTOCOL.md`'s rules, and a REQUIRED sibling input for appendix-pointer verification. Rows are append-only dated incidents; the body's `(§Appendix, "X")` pointers resolve to the row whose first column names `X` |

The canonical `SHONEN.md` seed (verbatim — `<name>` is the only substitution):

    # <name> — Promotion checklist

    Promotion to shokunin requires all of:

    - [ ] SKILL.md contains real decision tables, error patterns, checklists, cited sources
    - [ ] At least one end-to-end domain task executed and logged in LOG.md
    - [ ] Instructions executable by an agent without oral context
    - [ ] No cross-domain bleed (PROVINCE.md still accurate)
    - [ ] ≥10,000 verified craft-hours in HOURS.md (§Craft-hours)

Marks: `[~]` asserted by the lane itself (evidence pointer required), `[x]` only with a named
non-author verifier per **Promotion gates**.

## Invariants

- Specialize, don't generalize: a shokunin's `SKILL.md` contains *cited, verifiable* knowledge of
  its domain — never generic agent advice.
- One domain per shokunin; a domain belongs to one shokunin. Contested scope — evidence or work
  is reported in the lane report; the integrator arbitrates by refining `PROVINCE.md` and records
  the ruling in the round notes. A contested-scope report left unruled by the next completed round
  is re-flagged in the lane report, the round notes, and an open aggregator-ledger row;
  silence is not a ruling and must never default scope to whichever lane wrote first.
- Rounds are evidence-driven: every `LOG.md` entry cites the work that motivated it.
- `LOG.md` is append-only: entries are never rewritten or deleted; corrections land as new entries.
- `MANIFEST.json` is canonical for rank and roster; `ROADMAP.md` mirrors it. Only integrator roles
  write main-repo files: `MISSION.md`, `AXES.md`, `CORPUS.md`, and `scripts/` are operator-side integrator files,
  whose corrections the protocol lane names in its round notes and does not edit; the protocol lane
  holds the `PROTOCOL.md`/`ROADMAP.md`/report writes plus, as integrator-of-record, `MANIFEST.json`
  `rounds` appends; edits *outside* `rounds` stay operator-side. Lanes write only inside their own
  child repo and their lane report at `.ufo/reports/round-<N>/<id>.md`; the two main-repo lanes
  (`protocol`, `aggregator`) also keep `SCORECARD.md` and `LOG.md` at the main-repo root.
  `.ufo/reports/`, `.ufo/waves/`, and the round's `.ufo/prompts/*.md` are committed with the round's
  integration commit — an untracked prompt is non-durable dispatch evidence. `.ufo/state/` and
  `.ufo/watchdog.log` are driver runtime that churns every tick, tracked since `609ecb6` (§Appendix, "Tracked runtime"); no lane commit
  may include them — pathspec-limited commits are the enforcement, and untracking them is operator-side
  work named in the round notes.
- A meta-domain shokunin (e.g. prompt & skill craft) documents *patterns*; it does
  not own the protocol files, other provinces' files, or promotions.
- Local-first: repos live locally; **domain-facing actions are operator-owned** (publishing, vault
  approval, claim submission). Push scope is owned by `MISSION.md` §Push scope — hard rule (operator
  rule, landed in `235b414` 2026-09-28): lanes push only to the main repo and their own
  `<lane>-shokunin` remote; domain source trees are read-only and upstream-bound work rides the
  round report. Repo bookkeeping — committing and `git push`ing the round's commits — is ordinary
  lane work, not publishing, when the driver instructs it. Exception: operator-gated artifacts
  (staged payloads, publish candidates, vault request material, evidence under embargo) are
  committed locally but not pushed until the operator releases the gate — bookkeeping never
  front-runs an operator decision. A lane's main-repo commit is pathspec-limited to its own report
  file (`git commit -- .ufo/reports/round-<N>/<id>.md`) — never `commit -a` / `add -A`, which sweeps
  up sibling in-flight edits and integrator working-tree changes.
- Lane authorship is auditable: each child repo is configured at mint so round commits carry the
  lane identity (`<lane>-shokunin` / `<lane>@shokunin.local`). A lane finding its repo unconfigured
  sets `git config user.name/email` once and notes it in `LOG.md`; commits under the operator
  identity made by lane rounds are a conformance defect (§Appendix, "Lane identity"). Main-repo
  commits follow the same rule but cannot rely on `git config`, the shared main-repo identity being
  the operator's personal one: a main-repo lane commits with `git -c user.name=<lane>-shokunin -c
  user.email=<lane>@shokunin.local commit …`.
- `corpus/` inherits the evidence standard: every `knowledge/` entry cites a resolvable source;
  `corpus/lessons/` entries cite the round and its LOG.md entry or lane report. Corpus corrections
  are new entries, never in-place rewrites: no lane edits another lane's corpus files, and
  `round-<N>-aggregator-*.md` are aggregator-owned.

## Fleet-2 conventions (adopted)

- Expertise axes live in `AXES.md`; each lane owns a named subset and works one axis-move per round,
  measured in `SCORECARD.md`. An axis-move inherits the evidence standard: before and after numbers
  each carry the counting command and the commit they were measured against, and a score no reader
  can re-derive is an opinion, not a measurement. A `SCORECARD.md` axis name not defined in
  `AXES.md` (`novelty`, `consistency`) is worked only if its row carries its mapping to one of the
  six axes `AXES.md` defines, in the same row, so a non-author can re-derive it. Axis work does not
  displace the file contract — a round that moves an axis while `corpus/`, `LOG.md`, or `SHONEN.md`
  drift is a conformance defect like any other.
- `MISSION.md` is the mission SSOT: fleet shape, model route table, concurrency floor (the L2
  minimum's source), push rule, L0 side channel. Watchdog prompts bind to it. Precedence between the
  two SSOTs: `PROTOCOL.md` owns process, evidence, and gates; where they conflict on process —
  `MISSION.md`'s unconditional "commit then push" against this file's operator-gated hold —
  `PROTOCOL.md` wins and the conflict is named in the round notes; neither file is edited by a lane.
- L0 side channel: lanes append `.ufo/l0-questions.md`; the aggregator surfaces it. The file is
  append-only — a lane restating or correcting its own question
  appends a new line naming the superseded one and never rewrites a filed line, and the operator's
  in-place answers are never a lane write. Cite a question by lane + round + its opening words,
  never by line number: the queue grows, so every line number moves. Its durability owner is the
  integrator, which commits it with the round's integration commit — a lane's appended question is
  non-durable until committed and no lane owns the path (§Appendix, "L0 durability").

## Appendix — incident digest (why these rules exist)
The incident digest lives in the committed sibling artifact `PROTOCOL-APPENDIX.md` (repo root, protocol-lane owned); `PROTOCOL.md` and `PROTOCOL-APPENDIX.md` are a REQUIRED pair for reading and verification and a reader or protocol-pointer verifier fails closed if either is absent. `§Appendix` means that artifact's first-column rule key, never an in-body incident table, and every incident pointer in this file resolves to the row of that artifact whose first column names the quoted rule.
