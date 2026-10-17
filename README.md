# kimi-shokunin

The Kimi Code CLI plugin for the shokunin fleet: a way to mint a specialist
for a domain, run one craft round against it, and drive many lanes round
after round — each lane keeping its own province instead of folding every
new demand into a generalist.

Shokunin (職人, artisan) names the lifecycle. A lane moves
mint → shonen (apprentice, probation of at least three verified rounds) →
shokunin (a named non-author verifier has checked every `SHONEN.md` box) →
jin'i-ryu (it can iterate on itself). A round is one axis-move on one of
six axes — depth, coverage, operability, freshness, calibration, adjacency.
The lane declares a falsifiable claim, lands one verifiable improvement,
measures before → after, and judges every axis with a verdict:
`improved`, `harmed`, `unchanged`, or `unprovable-but-better`. A round is
admitted only when at least one axis improved and none were harmed.
Evidence is the currency. Lane identity
(`<id>-shokunin <<id>@shokunin.local>`) rides in every commit.

The fleet root that this plugin vendors its protocol from is
[github.com/VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin).

## Install

From a Kimi Code CLI session:

```
/plugins install https://github.com/VeigaPunk/kimi-shokunin
/reload
```

Local dev: `/plugins install /path/to/kimi-shokunin`, then `/reload`.
`./install.sh` runs the sanity gate (required files, mint-kit shape,
`bash -n`, manifest JSON) before you install.

## Use it

In a session, one craft round on the current target:

```
/shokunin
/shokunin mint rust-embedded systems for bare-metal firmware
/shokunin fleet
```

`/shokunin` declares the axis set, makes one axis-move, verdict-judges
every axis, and records the result. `mint` enforces the mint bar before
it scaffolds a lane. `fleet` reads watchdog status from `.ufo/state` and
`.ufo/reports`.

Fleet mode, round after round:

```
cp templates/shokunin.conf.example shokunin.conf
scripts/shokunin-watchdog.sh
```

Edit the lanes table and `SUBSTRATE_CMD` in the conf first. Or point the
driver at another file with `SHOKUNIN_CONF=/path/to/shokunin.conf`.

`SUBSTRATE_CMD` is the substrate-neutral lane launcher: a shell command
in which `%C` expands to the lane working directory and `%P` to the
rendered round-prompt file. The shipped example shows a headless-style
Kimi invocation — point it at whatever substrate serves your lanes.
Touch `.ufo/fleet-wrap` to halt respawns; remove it to resume.

`scripts/mint-agent.sh` is the non-interactive mint scaffold.

## What's inside

```
kimi-shokunin/
├── kimi.plugin.json            plugin manifest
├── install.sh                  sanity gate + install instructions
├── commands/
│   └── shokunin.md             /shokunin entrypoint (round | mint | fleet)
├── skills/
│   └── shokunin/
│       ├── SKILL.md            orchestrator skill
│       └── protocol/           PROTOCOL, appendix, mission, axes, corpus
├── templates/
│   ├── mint/                   canonical seed kit for a new lane
│   ├── MANIFEST.schema.json    rounds-ledger schema
│   ├── round-prompt.md         fleet round prompt
│   └── shokunin.conf.example   watchdog config example
└── scripts/
    ├── shokunin-watchdog.sh    respawn-per-round driver (450s tick, cap 1024)
    └── mint-agent.sh           non-interactive mint scaffold
```

The protocol files under `skills/shokunin/protocol/` are the contract the
fleet root vendors. `templates/mint/` is the seed kit (`SKILL.md` calls
it the canonical 7-file kit). On disk that directory holds `SKILL.md`,
`PROVINCE.md`, `SHONEN.md`, `LOG.md`, `MINT.md`, `AGENTS.md`,
`EXAMPLE.kama.md`, and a `corpus/` with `README.md` and `QUALITY.md`.

## Contract in one line

One axis-move per round, verdicts not scores, evidence or it didn't happen,
lane identity in every commit.
