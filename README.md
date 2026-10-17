# kimi-shokunin — Shokunin fleet for Kimi Code CLI

**Mint specialist agents. Iterate them like artisans. Never absorb every
new demand into a generalist.**

Shokunin (職人, artisan) is a self-improving fleet of domain-specialist
agents. This plugin is the portable Kimi Code CLI adaptation of that
craft: the protocol contract, the mint kit, the round templates, and a
substrate-neutral fleet driver.

Each lane's lifecycle is

```
mint → shonen (apprentice, ≥3 verified rounds) → shokunin (promoted) → jin'i-ryu (self-iterating)
```

Promotion is not self-attestation. A named **non-author** verifier
checks every `SHONEN` box. Every round is **one axis-move** against six
axes — `depth`, `coverage`, `operability`, `freshness`, `calibration`,
`adjacency`. Pick the lane's lowest axis, declare a falsifiable claim,
land one verifiable improvement, measure before→after, and judge every
axis with a verdict: `improved` / `harmed` / `unchanged` /
`unprovable-but-better`. Never a scalar score.

A round is admitted only if at least one axis improved and none were
harmed. Evidence is the currency. Lane identity
(`<id>-shokunin <<id>@shokunin.local>`) rides in every commit.

The private fleet root — roster, round history, coordination state —
lives at [github.com/VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin).

## Contract in one line

One axis-move per round, verdicts not scores, evidence or it didn't happen,
lane identity in every commit.

## Install

From a Kimi Code CLI session:

```
/plugins install https://github.com/VeigaPunk/kimi-shokunin
/reload
```

Local development: `/plugins install /path/to/kimi-shokunin`, then
`/reload`.

`./install.sh` is the sanity gate. It checks required files, the
seven-file mint kit, `bash -n` on the scripts, and manifest JSON. It
does **not** install the plugin — Kimi's `/plugins install` does that.

## Commands

In-session, on the current target:

```
/shokunin            # declare axis set → one axis-move → verdict-judge all axes → record
/shokunin mint rust-embedded systems for bare-metal firmware
/shokunin fleet      # watchdog status from .ufo/state + .ufo/reports
```

`/shokunin mint` enforces the mint bar first: unplaceable demand, or
operator directive. It will not silently widen an existing province.

Fleet mode — a round-by-round driver over many lanes:

```
cp templates/shokunin.conf.example shokunin.conf   # edit the LANES table + SUBSTRATE_CMD
scripts/shokunin-watchdog.sh                       # or: SHOKUNIN_CONF=/path/to/shokunin.conf
```

`SUBSTRATE_CMD` is the substrate-neutral launcher: a shell command in
which `%C` expands to the lane working directory and `%P` to the
rendered round-prompt file. The shipped example shows a headless-style
Kimi invocation — point it at whatever substrate serves your lanes.
Touch `.ufo/fleet-wrap` to halt respawns; remove it to resume. Tick is
450s; cap is 1024 rounds.

## What's inside

```
kimi-shokunin/
├── kimi.plugin.json            plugin manifest (v0.1.0)
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
    ├── shokunin-watchdog.sh    respawn-per-round fleet driver
    └── mint-agent.sh           non-interactive mint scaffold + wiring
```

Nothing in this tree hardcodes hosts, models, or absolute paths. The
fleet driver is re-parameterized through `SUBSTRATE_CMD`.

## Provenance

Upstream shokunin lives at
[github.com/VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin)
(private). This plugin is the portable Kimi Code CLI adaptation: the
protocol contract, mint kit, and round templates ship in-tree, and the
fleet driver is re-parameterized to run through `SUBSTRATE_CMD`.
