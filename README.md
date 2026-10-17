# kimi-shokunin

The Kimi Code CLI plugin for the shokunin fleet: mint a domain specialist,
then improve it one axis-move at a time.

Shokunin (職人, artisan) is a self-improving fleet. A new demand that no
existing province can absorb becomes a new lane, with its own repository,
its own corpus, and its own probation. This repository is the portable
plugin. Domain craft lives in the specialist repositories. The fleet root
is [github.com/VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin).

Lifecycle: mint → shonen (apprentice) → shokunin (promoted by a named
non-author verifier checking every `SHONEN.md` box) → jin'i-ryu
(self-iterating).

A round is one axis-move against six axes — depth, coverage, operability,
freshness, calibration, adjacency. Declare a falsifiable claim, land one
verifiable improvement, measure before → after, and judge every axis with
a verdict: `improved` / `harmed` / `unchanged` / `unprovable-but-better`.
A round is admitted only if at least one axis improved and none were
harmed. Lane identity (`<id>-shokunin <<id>@shokunin.local>`) rides in
every commit.

## What's inside

```
kimi-shokunin/
├── kimi.plugin.json            plugin manifest (name, version, skills, commands)
├── install.sh                  sanity gate + install instructions
├── commands/
│   └── shokunin.md             /shokunin entrypoint (round | mint | fleet)
├── skills/
│   └── shokunin/
│       ├── SKILL.md            orchestrator skill
│       └── protocol/           PROTOCOL, APPENDIX, MISSION, AXES, CORPUS
├── templates/
│   ├── mint/                   canonical seed kit for a new lane
│   ├── MANIFEST.schema.json    rounds-ledger schema
│   ├── round-prompt.md         fleet round prompt
│   └── shokunin.conf.example   watchdog config example
└── scripts/
    ├── shokunin-watchdog.sh    respawn-per-round fleet driver
    └── mint-agent.sh           non-interactive mint scaffold
```

## Quick start

In a Kimi Code CLI session:

```
/shokunin
/shokunin mint rust-embedded systems for bare-metal firmware
/shokunin fleet
```

`/shokunin` runs one craft round on the current target: declare the axis
set, make one axis-move, verdict-judge every axis, record it. `mint`
enforces the mint bar before scaffolding a lane. `fleet` reads watchdog
status from `.ufo/state` and `.ufo/reports`.

Fleet mode, round after round, across many lanes:

```
cp templates/shokunin.conf.example shokunin.conf
scripts/shokunin-watchdog.sh
```

`SUBSTRATE_CMD` in the conf is the lane launcher. `%C` expands to the lane
working directory and `%P` to the rendered round-prompt file. The shipped
example shows a headless-style Kimi invocation; point it at the substrate
that serves your lanes. Touch `.ufo/fleet-wrap` to halt respawns. Remove
it to resume.

## Install

From a Kimi Code CLI session:

```
/plugins install https://github.com/VeigaPunk/kimi-shokunin
/reload
```

Local dev: `/plugins install /path/to/kimi-shokunin`, then `/reload`.
`./install.sh` runs the sanity gate — required files, mint-kit shape,
`bash -n`, manifest JSON — before you install.

## Contract

One axis-move per round. Verdicts, never scalar scores. Evidence, or the
round did not happen. Lane identity in every commit.

Protocol text in `skills/shokunin/protocol/` is the copy this plugin
ships. The fleet root remains the coordination ledger.
