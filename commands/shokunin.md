---
description: Shokunin craft orchestrator — /shokunin runs a one-axis-move craft round on the current target; /shokunin mint <domain> mints a domain-specialist agent from the canonical seed kit; /shokunin fleet reports watchdog state.
---

Run the shokunin protocol for: $ARGUMENTS

1. Load the `shokunin` skill (this plugin) and read `skills/shokunin/protocol/PROTOCOL.md` — it is the contract. `PROTOCOL-APPENDIX.md` explains why each rule exists; `MISSION.md` is the fleet SSOT; `AXES.md` + `CORPUS.md` are the axis and corpus contracts. This is shokunin, not UFO: verdict discipline is per-axis (improved/harmed/unchanged/unprovable-but-better), never a multi-axis Pareto seat map, never scalar scores.
2. Parse the verb in `$ARGUMENTS`:
   - empty → craft round on the current target (steps 3–5).
   - `mint <domain...>` → the mint mechanic (steps 6–8).
   - `fleet` → watchdog operations summary (step 9).
3. **Craft round — declare.** Read the target lane's `SCORECARD.md` (create per `AXES.md` if missing) and declare the round's axis set with direction + observable. Pick ONE axis — the lane's lowest. Declare the falsifiable claim: what measurable before→after delta counts as improvement.
4. **Craft round — do.** Land exactly one improvement against the chosen axis. When subagents are warranted, dispatch them as ONE batched AgentSwarm call with ≥8 lanes: planner+connector / executor+scribe+scout / reviewer+critic split. Measure before→after on the delivered revision; record the delta in `SCORECARD.md` and the evidence in `LOG.md` (append-only).
5. **Craft round — judge.** Judge EVERY axis in the declared set, each improved/harmed/unchanged/unprovable-but-better. Admit the round only if ≥1 axis improved AND none harmed. A trade is not an improvement: report both verdicts and let the operator rule. Record the verdict + evidence concisely, file the report at `.ufo/reports/round-<N>/<lane>.md`, and close the append-only `MANIFEST.json rounds[]` ledger entry. Honest stop: never force a harmed or unprovable round — report it and halt the lane's progression instead.
6. **Mint — enforce the bar.** Require two documented unplaceable demand instances (work no existing province could absorb) or an explicit operator directive. Absent the bar, refuse the mint and say what evidence would satisfy it.
7. **Mint — roster scan.** Scan `MANIFEST.json` + every `PROVINCE.md`; record why every existing lane rejects the demand. Write the rejected-fit record into the new lane's `MINT.md` evidence, then scaffold `<id>-shokunin/` from `templates/mint/` (7 files) via `scripts/mint-agent.sh --id <id> --domain "<domain...>" --fleet-root <fleet root>` — git identity `<id>-shokunin <<id>@shokunin.local>` is configured by the script.
8. **Mint — probation.** Register the lane in `shokunin.conf`; before any `MANIFEST.json` roster row exists, the lane must complete ≥3 verified self-iteration rounds, recorded as a `rounds[]` entry of type `"mint"`. Only the operator adds the roster row after probation.
9. **Fleet.** Summarize watchdog state: per-lane round counters from `.ufo/state/<lane>.round`, recent landings/failures from `.ufo/reports/` and `.ufo/watchdog.log`. Halt respawns with `touch .ufo/fleet-wrap`; resume with `rm .ufo/fleet-wrap`. Launch long-running fleet loops via `scripts/shokunin-watchdog.sh` with `SHOKUNIN_CONF` pointed at the fleet's `shokunin.conf`.

Honesty rules bind every verb: an unrun check has not passed; marker files and contentless reports are failed rounds; unverifiable claims are reported, never forced; never fabricate evidence; lane-identity commits are attribution, not decoration.
