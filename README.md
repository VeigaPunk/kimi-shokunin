# kimi-shokunin — 職人 for Kimi Code CLI

**Mint domain-specialist agents. Iterate them one axis at a time. Never
absorb a new demand into a generalist.**

Shokunin (職人, artisan) is a self-improving fleet of specialists. This
repository is the **portable Kimi Code CLI plugin**: the protocol
contract, the mint kit, the `/shokunin` command, and a substrate-neutral
fleet driver. The live fleet root — roster, round history, coordination
state — lives at [VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin).

```
mint → shonen (apprentice) → shokunin (artisan) → jin'i-ryu (self-iterating)
```

A round is **one axis-move** against six axes (`depth`, `coverage`,
`operability`, `freshness`, `calibration`, `adjacency`). Declare a
falsifiable claim, land one verifiable improvement, measure before→after,
and judge every axis with a verdict:

`improved` / `harmed` / `unchanged` / `unprovable-but-better`

Never a scalar score. A round is admitted only if at least one axis
improved and none were harmed. Evidence is the currency. Lane identity
(`<id>-shokunin <<id>@shokunin.local>`) rides in every commit.

This is **not UFO**. UFO runs a multi-axis Pareto seat map. Shokunin
runs per-axis verdicts on a specialist that owns exactly one province.

## Install

From a Kimi Code CLI session:

```
/plugins install https://github.com/VeigaPunk/kimi-shokunin
/reload
```

Local checkout:

```
/plugins install /path/to/kimi-shokunin
/reload
```

`./install.sh` is a **sanity gate**, not an installer. It checks required
files, the 7-file mint kit, `bash -n` on the scripts, and
`kimi.plugin.json` — then prints the commands above.

```
./install.sh
```

Apache-2.0. See [`LICENSE`](LICENSE).

## Commands

In-session, on the current target:

```
/shokunin
/shokunin mint rust-embedded systems for bare-metal firmware
/shokunin fleet
```

| Verb | What it does |
|---|---|
| *(empty)* | one craft round: declare axis set → one axis-move → verdict-judge every axis → record |
| `mint <domain…>` | mint a new lane (mint bar enforced first: two unplaceable demand instances, or an operator directive) |
| `fleet` | watchdog status from `.ufo/state` + `.ufo/reports` |

The command contract is [`commands/shokunin.md`](commands/shokunin.md).
The orchestrator skill is [`skills/shokunin/SKILL.md`](skills/shokunin/SKILL.md).

## Fleet mode

Round-by-round driver over many lanes:

```
cp templates/shokunin.conf.example shokunin.conf   # edit LANES + SUBSTRATE_CMD
scripts/shokunin-watchdog.sh                       # or: SHOKUNIN_CONF=/path/to/shokunin.conf
```

`SUBSTRATE_CMD` is the substrate-neutral lane launcher. `%C` expands to
the lane working directory, `%P` to the rendered round-prompt file. The
shipped example is a headless-style Kimi invocation — point it at
whatever substrate actually serves your lanes.

- Touch `.ufo/fleet-wrap` to halt respawns.
- Remove it to resume.
- Tick: 450s. Cap: 1024 rounds/lane (both overridable in the conf).

## Layout

```
kimi-shokunin/
├── kimi.plugin.json            plugin manifest
├── install.sh                  sanity gate + install instructions
├── LICENSE                     Apache-2.0
├── commands/
│   └── shokunin.md             /shokunin entrypoint (round | mint | fleet)
├── skills/shokunin/
│   ├── SKILL.md                orchestrator skill
│   └── protocol/               PROTOCOL.md · PROTOCOL-APPENDIX.md
│                               MISSION.md · AXES.md · CORPUS.md · LEARNING.md
├── templates/
│   ├── mint/                   canonical 7-file seed kit for a new lane
│   ├── MANIFEST.schema.json    rounds-ledger schema
│   ├── round-prompt.md         fleet round prompt
│   └── shokunin.conf.example   watchdog config example
└── scripts/
    ├── shokunin-watchdog.sh    respawn-per-round fleet driver
    └── mint-agent.sh           non-interactive mint scaffold + wiring
```

The mint kit is exactly seven files (`AGENTS.md`, `EXAMPLE.kama.md`,
`LOG.md`, `MINT.md`, `PROVINCE.md`, `SHONEN.md`, `SKILL.md`) plus the
corpus seed under `templates/mint/corpus/`. `install.sh` fails if that
count drifts.

## Contract in one line

One axis-move per round, verdicts not scores, evidence or it didn't happen,
lane identity in every commit.

## Provenance

Upstream fleet state: [github.com/VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin).
This plugin is the Kimi-native adaptation: protocol, mint kit, and round
templates ship in-tree, and the fleet driver is parameterized through
`SUBSTRATE_CMD` with no hardcoded hosts, models, or absolute paths.
