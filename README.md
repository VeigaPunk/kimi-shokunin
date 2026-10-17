# kimi-shokunin — 職人 on Kimi Code CLI

**Mint domain-specialist agents. Iterate them one axis at a time. Never
absorb every new demand into a generalist.**

Shokunin (職人, artisan) is a self-improving fleet of domain-specialist
agents, iterated by swarm rounds — auto agent creation with its own logic.
This repository is the portable **Kimi Code CLI** plugin: the protocol
contract, the mint kit, the `/shokunin` command, and a substrate-neutral
fleet driver.

**Wiki:** [plugin overview](https://app.devin.ai/org/veigapunk/wiki/VeigaPunk/kimi-shokunin?branch=main)

Upstream fleet root: [VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin).

## The contract in one breath

```
mint → shonen (apprentice, ≥3 verified rounds)
    → shokunin (named non-author verifier checks every SHONEN box)
    → jin'i-ryu (self-iterating)
```

Every round is **one** axis-move against six axes — `depth`, `coverage`,
`operability`, `freshness`, `calibration`, `adjacency`. Declare a
falsifiable claim, land one verifiable improvement, measure before→after,
and judge every axis:

`improved` / `harmed` / `unchanged` / `unprovable-but-better`

Never a scalar score. A round is admitted only if at least one axis
improved and none were harmed. Evidence is the currency. Lane identity
(`<id>-shokunin <<id>@shokunin.local>`) rides in every commit.

## What's inside

```
kimi-shokunin/
├── kimi.plugin.json            plugin manifest (v0.1.0, Apache-2.0)
├── install.sh                  sanity gate + install instructions
├── commands/
│   └── shokunin.md             /shokunin entrypoint (round | mint | fleet)
├── skills/
│   └── shokunin/
│       ├── SKILL.md            orchestrator skill
│       └── protocol/           PROTOCOL.md + PROTOCOL-APPENDIX.md + MISSION.md
│                               + AXES.md + CORPUS.md
├── templates/
│   ├── mint/                   canonical 7-file seed kit for a new lane
│   ├── MANIFEST.schema.json    rounds-ledger schema
│   ├── round-prompt.md         fleet round prompt
│   └── shokunin.conf.example   watchdog config example
└── scripts/
    ├── shokunin-watchdog.sh    respawn-per-round fleet driver (450s tick, cap 1024)
    └── mint-agent.sh           non-interactive mint scaffold + wiring
```

`./install.sh` fails closed if the mint kit is not exactly seven files, if
a required path is missing, or if a script fails `bash -n`.

## Install

From a Kimi Code CLI session:

```
/plugins install https://github.com/VeigaPunk/kimi-shokunin
/reload
```

Local dev: `/plugins install /path/to/kimi-shokunin`, then `/reload`.
Run `./install.sh` first — it is the sanity gate, not the installer.

## Quick start

In-session (one craft round on the current target):

```
/shokunin            # declare axes → one axis-move → verdict-judge → record
/shokunin mint rust-embedded systems for bare-metal firmware
/shokunin fleet      # watchdog status from .ufo/state + .ufo/reports
```

Fleet mode (round-by-round driver over many lanes):

```
cp templates/shokunin.conf.example shokunin.conf   # edit LANES + SUBSTRATE_CMD
scripts/shokunin-watchdog.sh                       # or: SHOKUNIN_CONF=/path/to/shokunin.conf
```

`SUBSTRATE_CMD` is the substrate-neutral launcher: `%C` expands to the
lane working directory and `%P` to the rendered round-prompt file. The
shipped example shows a headless-style Kimi invocation — point it at
whatever substrate serves your lanes. Touch `.ufo/fleet-wrap` to halt
respawns; remove it to resume.

## What this plugin is not

It is **not UFO**. UFO runs a multi-axis Pareto seat map. Shokunin judges
per axis, one move per round, and only mints domain specialists. Never
describe a shokunin round as "passing Pareto." See
`skills/shokunin/SKILL.md` for the load-bearing distinction.

## Provenance

This plugin vendors the fleet contract in-tree so a Kimi session does not
need the private fleet root checked out. The driver is re-parameterized
through `SUBSTRATE_CMD` with no hardcoded hosts, models, or absolute
paths. License: Apache-2.0 (`LICENSE`).
