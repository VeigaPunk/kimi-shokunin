# kimi-shokunin — Shokunin auto-agent-creation fleet for Kimi Code CLI

Shokunin (職人, artisan) is a self-improving fleet of domain-specialist
agents: it mints specialists for unserved demand, then continually researches,
curates sources, learns from mistakes, and improves domain skill through rounds.
Each round declares **1–3 causally separable claims on distinct axes**, each
with falsifiable before→after evidence; at least one works the lane's lowest
non-retired axis unless the stagnation nudge waives it. A claim may acquire a
capability or be exploratory with outside review. Three learning trends —
expansion, quality, discernment — receive one evidence-backed verdict apiece;
there are no scalar scores or trade-offs passed off as improvement. Lifecycle:
mint → shonen (≥3 verified probation rounds) → shokunin (named non-author
verification of every SHONEN box) → jin'i-ryu (self-iterating). Lane identity
(`<id>-shokunin <<id>@shokunin.local>`) rides in every commit.

**Wiki:** [Devin wiki](https://app.devin.ai/org/veigapunk/wiki/VeigaPunk/kimi-shokunin?branch=main)

## What's inside

```
kimi-shokunin/
├── kimi.plugin.json            plugin manifest
├── install.sh                  sanity gate + install instructions
├── commands/
│   └── shokunin.md             /shokunin entrypoint (round | mint | fleet)
├── skills/
│   └── shokunin/
│       ├── SKILL.md            orchestrator skill (this plugin's core)
│       └── protocol/           canonical protocol: PROTOCOL.md,
│           ├── PROTOCOL-APPENDIX.md + MISSION.md + AXES.md
│           └── CORPUS.md + LEARNING.md
├── templates/
│   ├── mint/                   seed kit: seven root templates plus corpus seeds
│   ├── MANIFEST.schema.json    rounds-ledger schema
│   ├── round-prompt.md         lane prompt ({{LANE}} {{ROUND}} {{AXES}} {{FLEET_ROOT}})
│   └── shokunin.conf.example   watchdog config example
└── scripts/
    ├── shokunin-watchdog.sh    respawn-per-round driver (450s tick, cap 1024)
    ├── sources-census.sh       corpus/SOURCES.md census and validation
    └── mint-agent.sh           non-interactive mint scaffold + wiring
```

## How a shokunin learns

Every round runs the learning loop, alongside its 1–3 axis claims:

1. **Curation:** open candidate sources from the domain's real surfaces and record them in
   `corpus/SOURCES.md`; unopened leads stay separate, and rejections stay with their reason.
2. **Quality gating:** admit only material that clears the lane's `corpus/QUALITY.md` bar.
   A claim sourced from research cites a `mined` `S###` row; SOURCES row counts alone are
   not learning or a quota.
3. **Understanding and mistakes:** distill durable knowledge into `SKILL.md` and refine
   QUALITY from gate results. Capture mistakes in the round lesson under `## Mistakes`
   (class, evidence, captured-by, fix); if none were found, record the sweep that showed it.
4. **Expanding perspective:** work the province frontier with adjacent surfaces, tools,
   schools, counter-examples and failure cases. Each child-lane round records its source
   census, mistake mining and at least one sourced claim; this is not an extra claim.

Each round also records one verdict per learning trend — `improved`, `harmed`,
`unchanged`, or `unprovable-but-better` — with evidence. Growth with harmed quality is
reported as a trade, never admitted.

## Quick start

In-session (single craft round on the current target):

```
/shokunin            # declare 1–3 claims -> frontier step -> trend verdicts -> report
/shokunin mint rust-embedded systems for bare-metal firmware  # mint a new lane (mint bar enforced first)
/shokunin fleet      # watchdog status from .ufo/state + .ufo/reports
```

Fleet mode (round-by-round driver over many lanes):

```
cp templates/shokunin.conf.example shokunin.conf   # edit the LANES table + SUBSTRATE_CMD
scripts/shokunin-watchdog.sh                       # or: SHOKUNIN_CONF=/path/to/shokunin.conf
```

The configured `SHONOKIN_ROOT` is the fleet root. Alongside `MISSION.md`,
`AXES.md`, `MANIFEST.json`, and `.ufo/`, it must contain
`templates/round-prompt.md` and `scripts/sources-census.sh`; the driver renders
the former and child prompts run the latter.

By default, census and validation enumerate child repositories only. Main-repo `repo=.` lanes
have no corpus and are excluded; pass an explicit `--file` or directory to inspect a specific
registry.

`SUBSTRATE_CMD` (set in the conf) is the substrate-neutral lane launcher: a
shell command in which `%C` expands to the lane working directory and `%P` to
the rendered round-prompt file. The shipped example shows a headless-style
Kimi invocation — point it at whatever substrate serves your lanes. Touch
`.ufo/fleet-wrap` to halt respawns; remove it to resume.

The watchdog requires Linux with readable `/proc` and `setsid` (plus Bash,
coreutils, and `flock`) for tagged process-group liveness; the lane substrate
remains selectable through `SUBSTRATE_CMD`.

## Contract in one line

One to three falsifiable, causally separable claims per round; curate sources,
learn from mistakes, report three trend verdicts, and cite evidence.

## Install

From a Kimi Code CLI session:

```
/plugins install https://github.com/VeigaPunk/kimi-shokunin
/reload
```

Local dev: `/plugins install /path/to/kimi-shokunin`, then `/reload`.
`./install.sh` runs the sanity gate (required files and census self-test fixtures, mint-kit
shape, `bash -n`, and manifest JSON) before you install.

## Provenance

This repository is the **canonical, reusable shokunin protocol**. Its protocol
documents govern; they do not derive authority from a fleet deployment. The
fleet root at [github.com/VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin)
is the proving ground and downstream vendor: its copies record the canonical
revision they vendor, while fleet-specific configuration and history remain
deployment data, not protocol authority.

## Changelog

- **2026-10-19 — canonical learning-contract sync.** Integrated the ratified
  amendments from fleet-root revision `dcf3b6484e02452fc7aec55d724744de188779b9`:
  1–3-claim rounds, capabilities and exploratory claims, SOURCES contract v1,
  frontier and mistake-learning duties, and the neutral watchdog/census substrate.

- **2026-10-19 — final cutover closeout.** Clarified historical ledger retention
  without weakening current schema constraints; aligned census continuation with
  report conformance and independent review; documented config startup, row shape, and
  model-routing semantics; fleet-root/Linux driver requirements; child-only census defaults,
  parser behavior, full help, and self-test fixture gates.
