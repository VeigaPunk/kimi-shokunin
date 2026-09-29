#!/usr/bin/env bash
# shokunin-watchdog — respawn-per-round fleet driver (Kimi port of upstream
# scripts/shokunin-watchdog.sh). SSOT: MISSION.md. A lane's round ends when
# .ufo/reports/round-<N>/<lane>.md lands with REAL content; the watchdog then
# launches a fresh process for round N+1. Defaults: tick 450s, cap 1024
# rounds/lane (config keys TICK_SECONDS / ROUND_CAP). Bash + coreutils only.
#
# Config: $SHOKUNIN_CONF, else $SHOKUNIN_ROOT/shokunin.conf (copy
# templates/shokunin.conf.example and edit). The conf is SOURCED (trusted
# operator code) and may set:
#   SHOKUNIN_ROOT   fleet root (repo holding shokunin.conf, .ufo/, lanes).
#                   Empty/absent = derive from this script's location.
#   TICK_SECONDS    sweep interval (default 450).
#   ROUND_CAP       rounds/lane cap (default 1024).
#   LANES           pipe table, one lane per line:
#                       <id>|<repo relative to SHOKUNIN_ROOT; "." = fleet root>|<axes>
#   SUBSTRATE_CMD   lane launcher; %C expands to the lane cwd, %P to the
#                   rendered prompt file. Executed via the shell in the lane
#                   cwd (the conf is trusted — it is sourced anyway).
# Prompt: rendered from templates/round-prompt.md by substituting {{LANE}},
#   {{ROUND}}, {{AXES}}, {{FLEET_ROOT}} (the placeholders that template ships).
set -u
SHOKUNIN_ROOT=${SHOKUNIN_ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
export SHOKUNIN_ROOT
CONF=${SHOKUNIN_CONF:-"$SHOKUNIN_ROOT/shokunin.conf"}

die() { echo "ERROR: $*" >&2; exit 1; }
[ -f "$CONF" ] || die "config not found: $CONF (copy templates/shokunin.conf.example)"

# shellcheck disable=SC1090
. "$CONF"
[ -n "$SHOKUNIN_ROOT" ] || SHOKUNIN_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
export SHOKUNIN_ROOT
UFO="$SHOKUNIN_ROOT/.ufo"
TEMPLATE="$SHOKUNIN_ROOT/templates/round-prompt.md"
INTERVAL=${TICK_SECONDS:-450}
MAX_ROUNDS=${ROUND_CAP:-1024}
MIN_REPORT_BYTES=${MIN_REPORT_BYTES:-400}

log() { echo "$(date -Is) $*" >> "$UFO/watchdog.log"; }

: "${LANES:?$CONF must define the LANES table (<id>|<repo>|<axes> per line)}"
declare -A LANE_CWD=() LANE_AXES=()
while IFS='|' read -r _id _repo _axes; do
  _id=$(printf '%s' "$_id" | tr -d '[:space:]')
  case $_id in ''|\#*) continue ;; esac
  _repo=$(printf '%s' "$_repo" | tr -d '[:space:]'); [ -n "$_repo" ] || _repo=.
  _axes=$(printf '%s' "$_axes" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if [ "$_repo" = . ]; then LANE_CWD[$_id]=$SHOKUNIN_ROOT
  else LANE_CWD[$_id]=$SHOKUNIN_ROOT/$_repo; fi
  LANE_AXES[$_id]=$_axes
done <<EOF
$LANES
EOF
[ ${#LANE_CWD[@]} -gt 0 ] || die "no lanes parsed from LANES in $CONF"
mkdir -p "$UFO/state" "$UFO/prompts" "$UFO/reports"

round_of() { local n; n=$(cat "$UFO/state/$1.round" 2>/dev/null) || n=0
  case $n in ''|*[!0-9]*) echo 0 ;; *) echo "$n" ;; esac; }
mission_of() { cat "$UFO/state/$1.mission" 2>/dev/null || true; }

# report_of — content check, not existence: a real report carries a SHONEN
# section (heading '## SHONEN' or the '- **SHONEN**' bullet the round-prompt
# report contract requires) AND >= MIN_REPORT_BYTES. Anything less is a
# marker; markers are failed rounds and must NOT advance the counter.
report_of() {
  local f="$UFO/reports/round-$2/$1.md"
  [ -f "$f" ] || return 1
  grep -qE '^#+ *SHONEN|\*\*SHONEN\*\*' "$f" || return 1
  [ "$(wc -c < "$f")" -ge "$MIN_REPORT_BYTES" ]
}

render_prompt() { # lane n -> writes .ufo/prompts/<lane>-round-<n>.md
  local lane="$1" n="$2" out="$UFO/prompts/$1-round-$2.md"
  sed -e "s/{{LANE}}/$lane/g" -e "s/{{ROUND}}/$n/g" \
      -e "s/{{AXES}}/${LANE_AXES[$lane]:-}/g" \
      -e "s|{{FLEET_ROOT}}|$SHOKUNIN_ROOT|g" "$TEMPLATE" > "$out" || return 1
}

launch_lane() {
  local lane="$1" n="$2" prompt pid run_cmd
  [ "$n" -le "$MAX_ROUNDS" ] || { log "cap $lane round=$n (ROUND_CAP=$MAX_ROUNDS)"; return 1; }
  [ -n "${SUBSTRATE_CMD:-}" ] || { log "launch-fail $lane round=$n :: SUBSTRATE_CMD unset"; return 1; }
  [ -f "$TEMPLATE" ] || { log "launch-fail $lane round=$n :: missing template $TEMPLATE"; return 1; }
  [ -d "${LANE_CWD[$lane]:-}" ] || { log "launch-fail $lane round=$n :: cwd missing: ${LANE_CWD[$lane]:-}"; return 1; }
  prompt="$UFO/prompts/${lane}-round-${n}.md"
  mkdir -p "$UFO/reports/round-$n"
  render_prompt "$lane" "$n" || { log "launch-fail $lane round=$n :: prompt render failed"; return 1; }
  run_cmd=${SUBSTRATE_CMD//%C/${LANE_CWD[$lane]}}
  run_cmd=${run_cmd//%P/$prompt}
  ( cd -- "${LANE_CWD[$lane]}" || exit 1; eval "$run_cmd" ) >> "$UFO/state/${lane}.out" 2>&1 &
  pid=$!
  echo "$pid" > "$UFO/state/${lane}.mission"
  echo "$n" > "$UFO/state/${lane}.round"
  log "launch $lane round=$n pid=$pid"
}

lane_git() { # driver-authored commits carry the lane identity: attribution, not decoration
  git -C "$SHOKUNIN_ROOT" -c "user.name=${1}-shokunin" -c "user.email=${1}@shokunin.local" "$@"
}
commit_evidence() { # commit the round's prompt as dispatch evidence, pathspec-limited
  local lane="$1" f=".ufo/prompts/$1-round-$2.md"
  git -C "$SHOKUNIN_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  [ -f "$SHOKUNIN_ROOT/$f" ] || return 0
  lane_git "$lane" add -- "$f" >/dev/null 2>&1 || return 0
  lane_git "$lane" commit -q -m "round-$2: ${lane} dispatch evidence" -- "$f" >/dev/null 2>&1 || true
}

advance() { # lane n — report landed: wrap, cap, or respawn-per-round
  local lane="$1" n="$2"
  commit_evidence "$lane" "$n"
  if [ -f "$UFO/fleet-wrap" ]; then
    log "wrap $lane round=$n landed; NOT respawning (fleet-wrap)"
  elif [ "$n" -lt "$MAX_ROUNDS" ]; then
    launch_lane "$lane" $((n+1))
  else
    log "cap $lane round=$n reached ROUND_CAP=$MAX_ROUNDS"
  fi
}

tick=0
while :; do
  tick=$((tick+1))
  for lane in "${!LANE_CWD[@]}"; do
    n=$(round_of "$lane"); mid=$(mission_of "$lane")
    live=0; [ -n "$mid" ] && kill -0 "$mid" 2>/dev/null && live=1
    if [ "$n" -eq 0 ]; then launch_lane "$lane" 1; continue; fi
    if [ "$live" -eq 1 ]; then
      if report_of "$lane" "$n"; then
        kill "$mid" 2>/dev/null || true
        log "complete $lane round=$n (report landed early); respawning"
        advance "$lane" "$n"
      fi
      continue
    fi
    if report_of "$lane" "$n"; then
      log "complete $lane round=$n; respawning"
      advance "$lane" "$n"
    elif [ -f "$UFO/reports/round-$n/$lane.md" ]; then
      log "lane-round-failed $lane round=$n :: marker/contentless report; NOT advancing"
      launch_lane "$lane" "$n"
    else
      log "lane-dead-no-report $lane round=$n; retry same round"
      launch_lane "$lane" "$n"
    fi
  done
  log "tick=$tick"
  sleep "$INTERVAL"
done
