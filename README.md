# kimi-shokunin — 職人 for Kimi Code CLI

Shokunin (職人, artisan) is a self-improving fleet of domain-specialist
agents. New demand mints a new lane. It does not disappear into a
generalist.

Each lane's life is:

```
mint → shonen (apprentice) → shokunin (artisan) → jin'i-ryu (self-iterating)
```

A shonen stays on probation until a **named non-author** verifier checks
every box in `SHONEN.md`. A round is one axis-move on the lane's lowest
axis — `depth`, `coverage`, `operability`, `freshness`, `calibration`, or
`adjacency`. The claim is falsifiable. The before→after is measured. Every
axis then gets a verdict: `improved`, `harmed`, `unchanged`, or
`unprovable-but-better`. A round is admitted only when at least one axis
improved and none were harmed. Lane identity
(`<id>-shokunin <<id>@shokunin.local>`) rides in every commit.

This repository is the **portable plugin**. The fleet root, the live
roster, and the round ledger live in
[shokunin](https://github.com/VeigaPunk/shokunin). The contract shipped
here is the same contract that root vendors.

## What's inside

```
kimi-shokunin/
├── kimi.plugin.json            plugin manifest (0.1.0, Apache-2.0)
├── install.sh                  sanity gate + install instructions
├── commands/
│   └── shokunin.md             /shokunin entrypoint (round | mint | fleet)
├── skills/
│   └── shokunin/
│       ├── SKILL.md            orchestrator skill
│       └── protocol/           PROTOCOL.md + PROTOCOL-APPENDIX.md + MISSION.md
│                               + AXES.md + LEARNING.md + CORPUS.md
├── templates/
│   ├── mint/                   canonical seed kit for a new lane
│   ├── MANIFEST.schema.json    rounds-ledger schema
│   ├── round-prompt.md         fleet round prompt ({{LANE}} {{ROUND}} {{AXES}} {{FLEET_ROOT}})
│   └── shokunin.conf.example   watchdog config example
└── scripts/
    ├── shokunin-watchdog.sh    respawn-per-round fleet driver (450s tick, cap 1024)
    └── mint-agent.sh           non-interactive mint scaffold + wiring
```

## Quick start

In a Kimi Code CLI session, one craft round on the current target:

```
/shokunin
/shokunin mint rust-embedded systems for bare-metal firmware
/shokunin fleet
```

`/shokunin` declares the axis set, lands one axis-move, verdict-judges
every axis, and records the round. `mint` enforces the mint bar before it
scaffolds a lane. `fleet` reads watchdog status from `.ufo/state` and
`.ufo/reports`.

Fleet mode, round after round, over many lanes:

```
cp templates/shokunin.conf.example shokunin.conf   # edit the LANES table + SUBSTRATE_CMD
scripts/shokunin-watchdog.sh                       # or: SHOKUNIN_CONF=/path/to/shokunin.conf
```

`SUBSTRATE_CMD` is the substrate-neutral launcher. `%C` expands to the
lane working directory and `%P` to the rendered round-prompt file. The
shipped example shows a headless-style Kimi invocation — point it at
whatever substrate serves your lanes. Touch `.ufo/fleet-wrap` to halt
respawns; remove it to resume.

Before you trust a checkout, run the sanity gate:

```sh
./install.sh
```

It checks required files, the mint-kit shape, `bash -n`, and that the
manifest is JSON.

## Install

From a Kimi Code CLI session:

```
/plugins install https://github.com/VeigaPunk/kimi-shokunin
/reload
```

Local dev: `/plugins install /path/to/kimi-shokunin`, then `/reload`.

## Contract in one line

One axis-move per round, verdicts not scores, evidence or it didn't happen,
lane identity in every commit.

## Provenance

Upstream shokunin lives at [github.com/VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin).
This plugin is the portable Kimi Code CLI adaptation: the protocol
contract, mint kit, and round templates ship in-tree, and the fleet driver
is re-parameterized to run through `SUBSTRATE_CMD` with no hardcoded hosts,
models, or absolute paths.
