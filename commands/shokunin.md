---
description: Shokunin craft orchestrator — /shokunin runs an evidence-backed 1–3-claim round with source curation and mistake learning; /shokunin mint <domain> creates a domain specialist; /shokunin fleet reports driver state.
---

Run the shokunin protocol for: $ARGUMENTS

1. Load the `shokunin` skill and its protocol files in the stated load order:
   `PROTOCOL.md`, `PROTOCOL-APPENDIX.md`, `MISSION.md`, `AXES.md` + `CORPUS.md`,
   then `LEARNING.md`. The protocol in this repository is canonical; a fleet copy
   is vendored with its canonical revision recorded, not a competing authority.
2. Parse the verb in `$ARGUMENTS`: empty → craft round (steps 3–6); `mint <domain...>`
   → mint (steps 7–9); `fleet` → watchdog summary (step 10).
3. **Craft round — declare.** Read the lane's `SCORECARD.md` (create per `AXES.md`
   if missing). Declare **1–3 causally separable claims on distinct axes**, each
   with a falsifiable before→after; work the lowest-scoring non-retired axis unless
   the stagnation nudge waives it. A claim may acquire a capability; at most one
   may be exploratory, and that claim needs a named non-author reviewer for
   `unprovable-but-better`.
4. **Craft round — do and learn.** Land every claim and run the child-lane frontier
   step within the claim cap: curate `corpus/SOURCES.md` using the contract in
   `CORPUS.md`; record its census before→after; mine a mistake in the round lesson
   under `## Mistakes` (or paste the sweep that found none); and cite at least one
   opened `S###` row from a round claim. Main-repo lanes with no corpus skip this
   step and write `SOURCES: unchanged — main-repo lanes hold no corpus/`.
   Every round dispatches at least 8 L2 subagents in one batched AgentSwarm call.
5. **Craft round — judge and report.** Record one verdict per claim and one
   evidence-backed verdict for each `LEARNING.md` trend (`expansion`, `quality`,
   `discernment`): `improved`, `harmed`, `unchanged`, or `unprovable-but-better`.
   Admit only when every claim verifies and no axis is harmed; report trades and
   let the operator rule. File the report with Work performed, Landed changes,
   Before → after measurements, Sources & frontier, Trend verdicts, and SHONEN,
   then append the closure to `MANIFEST.json` `rounds[]`.
6. **Honest stop.** Never force a harmed or unprovable round through. Report the
   evidence and stop progression when the claim cannot be verified.
7. **Mint — enforce the bar.** Require two documented unplaceable demand instances
   (work no existing province could absorb) or an explicit operator directive.
   Absent the bar, refuse the mint and say what evidence would satisfy it.
8. **Mint — roster scan and scaffold.** Scan `MANIFEST.json` + every `PROVINCE.md`;
   record why each existing lane rejects the demand in the new `MINT.md`. Then use
   `scripts/mint-agent.sh --id <id> --domain "<domain...>" --fleet-root <root>`.
   The seed kit includes seven root templates plus corpus seeds, including an
   empty `corpus/SOURCES.md`; git identity is configured by the script.
9. **Mint — probation.** Before any roster row exists, complete ≥3 verified
   1–3-claim rounds with the child-lane frontier step, recorded as a `rounds[]`
   entry of type `"mint"`. Only the operator adds the roster row after probation.
10. **Fleet.** Summarize watchdog counters from `.ufo/state/<lane>.round` and
    landings/failures from `.ufo/reports/` and `.ufo/watchdog.log`. Halt respawns
    with `touch .ufo/fleet-wrap`; resume with `rm .ufo/fleet-wrap`. Launch the
    long-running driver with `SHOKUNIN_CONF` pointing at the deployment's config.

Honesty rules bind every verb: an unrun check has not passed; marker files and
contentless reports are failed rounds; unverifiable claims are reported, never
forced; never fabricate evidence; lane-identity commits are attribution, not
decoration.
