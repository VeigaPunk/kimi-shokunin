# kimi-shokunin — 職人, for Kimi Code CLI

This plugin is the portable Kimi Code CLI adaptation of the shokunin fleet: auto agent creation with its own logic, instead of folding every new demand into a generalist (`README` contract, `kimi.plugin.json`).

The lifecycle the protocol describes, kept from the previous front door: mint, then shonen (apprentice, probation of at least three verified rounds), then shokunin (promoted only when a named non-author verifier checks every SHONEN box), then jin'i-ryu (self-iterating). Every round is one axis-move against six axes (depth, coverage, operability, freshness, calibration, adjacency). A round is admitted only if at least one axis improved and none were harmed. Lane identity (`<id>-shokunin <<id>@shokunin.local>`) rides in every commit. This repository is the plugin. It does not ship a `LOG.md`, and this change does not add one.

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
│       └── protocol/           PROTOCOL.md + PROTOCOL-APPENDIX.md + MISSION.md
│                               + AXES.md + CORPUS.md (the fleet contract)
├── templates/
│   ├── mint/                   canonical 7-file seed kit for a new lane
│   ├── MANIFEST.schema.json    rounds-ledger schema
│   ├── round-prompt.md         fleet round prompt ({{LANE}} {{ROUND}} {{AXES}} {{FLEET_ROOT}})
│   └── shokunin.conf.example   watchdog config example
└── scripts/
    ├── shokunin-watchdog.sh    respawn-per-round fleet driver (450s tick, cap 1024)
    └── mint-agent.sh           non-interactive mint scaffold + wiring
```

`LICENSE` is also at the repo root.

## Quick start

In-session (single craft round on the current target):

```
/shokunin            # declare axis set -> one axis-move -> verdict-judge all axes -> record
/shokunin mint rust-embedded systems for bare-metal firmware  # mint a new lane (mint bar enforced first)
/shokunin fleet      # watchdog status from .ufo/state + .ufo/reports
```

Fleet mode (round-by-round driver over many lanes):

```
cp templates/shokunin.conf.example shokunin.conf   # edit the LANES table + SUBSTRATE_CMD
scripts/shokunin-watchdog.sh                       # or: SHOKUNIN_CONF=/path/to/shokunin.conf
```

`SUBSTRATE_CMD` (set in the conf) is the substrate-neutral lane launcher: a shell command in which `%C` expands to the lane working directory and `%P` to the rendered round-prompt file. The shipped example shows a headless-style Kimi invocation. Point it at whatever substrate serves your lanes. Touch `.ufo/fleet-wrap` to halt respawns; remove it to resume.

Non-interactive mint, from `scripts/mint-agent.sh`:

```sh
scripts/mint-agent.sh --id <id> --domain "<domain>" --fleet-root <dir>
```

The mint bar is enforced by `/shokunin` before that script runs. The script does not fabricate mint-bar evidence (`scripts/mint-agent.sh` header).

## Contract in one line

One axis-move per round, verdicts not scores, evidence or it didn't happen, lane identity in every commit.

## Install

From a Kimi Code CLI session:

```
/plugins install https://github.com/VeigaPunk/kimi-shokunin
/reload
```

Local dev: `/plugins install /path/to/kimi-shokunin`, then `/reload`. `./install.sh` runs the sanity gate (required files, mint-kit shape, `bash -n`, manifest JSON) before you install. `install.sh --help` prints that usage. The script does not modify host config.

## Provenance

Upstream shokunin lives at [github.com/VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin) (private). This plugin is the portable Kimi Code CLI adaptation: the protocol contract, mint kit, and round templates ship in-tree, and the fleet driver is re-parameterized to run through `SUBSTRATE_CMD` with no hardcoded hosts, models, or absolute paths.
