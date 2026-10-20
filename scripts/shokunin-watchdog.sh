#!/usr/bin/env bash
# shokunin-watchdog v5 — respawn-per-round fleet driver, substrate-neutral.
# SSOT: MISSION.md. A lane's round ends when .ufo/reports/round-<N>/<lane>.md
# lands with REAL content (a SHONEN section + >= MIN_REPORT_BYTES); the
# watchdog then closes the round and launches a fresh process for round N+1.
# Defaults: tick 450s, cap 1024 rounds/lane. Bash + coreutils + flock.
#
# Config: $SHOKUNIN_CONF, else $SHOKUNIN_ROOT/shokunin.conf (copy
# templates/shokunin.conf.example and edit). The conf is SOURCED (trusted
# operator code) and may set:
#   SHOKUNIN_ROOT     fleet root (repo holding shokunin.conf, .ufo/, lanes).
#                     Empty/absent = derive from this script's location.
#   TICK_SECONDS      sweep interval (default 450; positive integer).
#   ROUND_CAP         rounds/lane cap (default 1024; positive integer).
#   MIN_REPORT_BYTES  report content floor (default 400; non-negative integer).
#   LANES             pipe table, one lane per line:
#                       <id>|<repo relative to SHOKUNIN_ROOT; "." = fleet root>|<axes>
#   SUBSTRATE_CMD     lane launcher; %C expands to the lane cwd, %P to the
#                     rendered prompt file. Runs via the shell in the lane cwd
#                     and must hold the agent in the FOREGROUND (the driver
#                     tracks the process group; backgrounding orphans the
#                     round). The conf is trusted — it is sourced anyway.
# Prompt: rendered from templates/round-prompt.md substituting {{LANE}},
#   {{ROUND}}, {{AXES}}, {{FLEET_ROOT}}, {{LANE_REPO}}, and the legacy literal
#   {{FLEET_ROOT}}/<{{LANE}}-repo> (replaced by the lane cwd). All
#   substitutions are literal string replaces — / & \ | in axes are data-safe.
# State: .ufo/state/<lane>.round holds the current round number;
#   .ufo/state/<lane>.mission holds the lane's process-group ID (the setsid
#   leader). Liveness verifies SHOKUNIN_LANE in a group member's environ, so a
#   recycled PID is never mistaken for the lane.
#   .ufo/state/<lane>.report-baseline holds "round SHA256" for the report bytes
#   captured immediately before launch or after a blocked source-gate check.
set -u

SHOKUNIN_ROOT=${SHOKUNIN_ROOT:-$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")/.." && pwd)}
export SHOKUNIN_ROOT
CONF=${SHOKUNIN_CONF:-"$SHOKUNIN_ROOT/shokunin.conf"}

die() { echo "ERROR: $*" >&2; exit 1; }
[ -f "$CONF" ] || die "config not found: $CONF (copy templates/shokunin.conf.example)"

# shellcheck disable=SC1090
. "$CONF"
[ -n "$SHOKUNIN_ROOT" ] || SHOKUNIN_ROOT=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")/.." && pwd)
_abs=$(CDPATH='' cd -- "$SHOKUNIN_ROOT" 2>/dev/null && pwd) || die "SHOKUNIN_ROOT not a directory: $SHOKUNIN_ROOT"
SHOKUNIN_ROOT=$_abs; unset _abs
UFO="$SHOKUNIN_ROOT/.ufo"
TEMPLATE="$SHOKUNIN_ROOT/templates/round-prompt.md"

# --- numeric conf validation (M5): bad numbers die at startup, not per tick ---
num() { case $1 in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac }
TICK_SECONDS=${TICK_SECONDS:-450}
ROUND_CAP=${ROUND_CAP:-1024}
MIN_REPORT_BYTES=${MIN_REPORT_BYTES:-400}
num "$TICK_SECONDS" && [ "$TICK_SECONDS" -gt 0 ] \
  || die "TICK_SECONDS must be a positive integer (got: $TICK_SECONDS)"
num "$ROUND_CAP" && [ "$ROUND_CAP" -gt 0 ] \
  || die "ROUND_CAP must be a positive integer (got: $ROUND_CAP)"
num "$MIN_REPORT_BYTES" \
  || die "MIN_REPORT_BYTES must be a non-negative integer (got: $MIN_REPORT_BYTES)"
INTERVAL=$TICK_SECONDS
MAX_ROUNDS=$ROUND_CAP
[ -n "${SUBSTRATE_CMD:-}" ] || die "SUBSTRATE_CMD not set in $CONF"
[ -f "$TEMPLATE" ] || die "prompt template not found: $TEMPLATE"

log() { echo "$(date -Is) $*" >> "$UFO/watchdog.log"; }

# --- lane roster from conf LANES pipe-table ----------------------------------
: "${LANES:?$CONF must define the LANES table (<id>|<repo>|<axes> per line)}"
declare -A LANE_CWD=() LANE_AXES=() LANE_REPO=()
while IFS='|' read -r _id _repo _axes; do
  _id=${_id//[[:space:]]/}
  case $_id in ''|\#*) continue ;; esac
  _repo=${_repo//[[:space:]]/}; [ -n "$_repo" ] || _repo=.
  _axes=${_axes#"${_axes%%[![:space:]]*}"}; _axes=${_axes%"${_axes##*[![:space:]]}"}
  LANE_REPO[$_id]=$_repo
  if [ "$_repo" = . ]; then LANE_CWD[$_id]=$SHOKUNIN_ROOT
  else LANE_CWD[$_id]=$SHOKUNIN_ROOT/$_repo; fi
  LANE_AXES[$_id]=$_axes
done <<EOF
$LANES
EOF
[ ${#LANE_CWD[@]} -gt 0 ] || die "no lanes parsed from LANES in $CONF"
# deterministic per-tick lane order (dossier Low: assoc-array order is random)
mapfile -t LANE_LIST < <(printf '%s\n' "${!LANE_CWD[@]}" | LC_ALL=C sort)
mkdir -p "$UFO/state" "$UFO/prompts" "$UFO/reports"

# round_of — bootstrap missing, empty, or corrupt state at round 1. Parse
# validated digits as base 10 so values such as 08 never enter octal arithmetic.
round_of() { # lane
  local lane="$1" n normalized
  n=$(cat "$UFO/state/$lane.round" 2>/dev/null) || { printf '1\n'; return; }
  case $n in
    '') printf '1\n' ;;
    *[!0-9]*)
      log "state-corrupt $lane :: invalid .round; treating as round 1"
      printf '1\n'
      ;;
    *)
      normalized=$((10#$n))
      [ "$normalized" -gt 0 ] || normalized=1
      printf '%s\n' "$normalized"
      ;;
  esac
}

# Report lifecycle identity uses report bytes, never modification times.
report_digest() { # report path; a missing report is the empty byte stream
  local f="$1" out digest
  if [ -f "$f" ]; then
    out=$(sha256sum < "$f") || return 1
  else
    out=$(printf '' | sha256sum) || return 1
  fi
  digest=${out%% *}
  [[ "$digest" =~ ^[[:xdigit:]]{64}$ ]] || return 1
  printf '%s\n' "$digest"
}

record_report_baseline() { # lane round; atomically save the current report digest
  local lane="$1" n="$2" f="$UFO/reports/round-$2/$1.md"
  local state="$UFO/state/$1.report-baseline" digest tmp
  digest=$(report_digest "$f") || {
    log "report-baseline-fail $lane round=$n :: cannot hash report"
    return 1
  }
  tmp="$state.tmp.$$"
  if ! printf '%s %s\n' "$n" "$digest" > "$tmp"; then
    rm -f -- "$tmp"
    log "report-baseline-fail $lane round=$n :: cannot write state"
    return 1
  fi
  if ! mv -fT -- "$tmp" "$state"; then
    rm -f -- "$tmp"
    log "report-baseline-fail $lane round=$n :: cannot replace state"
    return 1
  fi
}

# report_of — content check, not existence (H5): a real report carries a SHONEN
# heading or bold-list marker and >= MIN_REPORT_BYTES. A same-round launch/gate
# baseline suppresses unchanged bytes by digest; mtime is never a completion signal.
# Spell out ASCII case variants under C locale, plus both macron bytes, for locale-independent matching.
report_of() {
  local f="$UFO/reports/round-$2/$1.md"
  local baseline="$UFO/state/$1.report-baseline"
  local baseline_round='' baseline_digest='' extra='' digest
  local shonen='[Ss][Hh]([Oo]|Ō|ō)[Nn][Ee][Nn]'
  [ -f "$f" ] || return 1
  if [ -e "$baseline" ] || [ -L "$baseline" ]; then
    [ -f "$baseline" ] || return 1
    IFS=' ' read -r baseline_round baseline_digest extra < "$baseline" || return 1
    case $baseline_round in ''|*[!0-9]*) return 1 ;; esac
    [[ "$baseline_digest" =~ ^[[:xdigit:]]{64}$ ]] || return 1
    baseline_digest=${baseline_digest,,}
    [ -z "$extra" ] || return 1
    if [ "$baseline_round" = "$2" ]; then
      digest=$(report_digest "$f") || return 1
      [ "$digest" != "$baseline_digest" ] || return 1
    fi
  fi
  LC_ALL=C grep -qE "^#+[[:space:]]*${shonen}([^[:alnum:]_]|$)|^[[:space:]]*-[[:space:]]+\\*\\*${shonen}\\*\\*([[:space:]]|$)" "$f" || return 1
  [ "$(wc -c < "$f")" -ge "$MIN_REPORT_BYTES" ]
}

# render_prompt — lane n -> writes .ufo/prompts/<lane>-round-<n>.md (M1, M2).
# Pure-bash literal string substitution: no sed/awk, so / & \ | in axes or
# paths are just bytes and can never corrupt the expression. The legacy
# '<{{LANE}}-repo>' placeholder (and the full '.../<{{LANE}}-repo>' form the
# template ships) is replaced with the lane's real repo path BEFORE {{LANE}}
# expands — it contains {{LANE}} as a substring.
render_prompt() {
  local lane="$1" n="$2" out="$UFO/prompts/$1-round-$2.md" t
  [ -f "$TEMPLATE" ] || return 1
  shopt -u patsub_replacement 2>/dev/null || true   # '&' must stay literal
  t=$(cat -- "$TEMPLATE") || return 1
  t=${t//"{{FLEET_ROOT}}/<{{LANE}}-repo>"/"${LANE_CWD[$lane]}"}
  t=${t//"<{{LANE}}-repo>"/"${LANE_REPO[$lane]:-}"}
  t=${t//"{{LANE_REPO}}"/"${LANE_REPO[$lane]:-}"}
  t=${t//"{{LANE}}"/"$lane"}
  t=${t//"{{ROUND}}"/"$n"}
  t=${t//"{{AXES}}"/"${LANE_AXES[$lane]:-}"}
  t=${t//"{{FLEET_ROOT}}"/"$SHOKUNIN_ROOT"}
  printf '%s\n' "$t" > "$out"
}

# launch_lane — substrate-neutral (C1): the conf's SUBSTRATE_CMD decides how a
# lane process starts; %C expands to the lane cwd, %P to the rendered prompt.
# The lane runs under setsid in its OWN process group (H4) tagged with
# SHOKUNIN_LANE/SHOKUNIN_ROUND in the environment (H3); .mission records the
# group leader pid. 'exit $?' as the last wrapper command keeps bash as the
# group leader (no implicit exec-into-agent).
launch_lane() {
  local lane="$1" n="$2" prompt pid run_cmd
  [ "$n" -le "$MAX_ROUNDS" ] || { log "cap $lane round=$n (ROUND_CAP=$MAX_ROUNDS)"; return 1; }
  [ -n "${SUBSTRATE_CMD:-}" ] || { log "launch-fail $lane round=$n :: SUBSTRATE_CMD unset"; return 1; }
  [ -d "${LANE_CWD[$lane]:-}" ] || { log "launch-fail $lane round=$n :: cwd missing: ${LANE_CWD[$lane]:-}"; return 1; }
  prompt="$UFO/prompts/${lane}-round-${n}.md"
  mkdir -p "$UFO/reports/round-$n"
  render_prompt "$lane" "$n" || { log "launch-fail $lane round=$n :: prompt render failed"; return 1; }
  run_cmd=${SUBSTRATE_CMD//%C/${LANE_CWD[$lane]}}
  run_cmd=${run_cmd//%P/$prompt}
  record_report_baseline "$lane" "$n" || {
    log "launch-fail $lane round=$n :: report baseline unavailable; not spawning"
    return 1
  }
  # A lane must not keep the driver's singleton lock alive after a crash.
  # Close it in the child subshell before execing the isolated process group.
  (
    if [[ ${LOCKFD:-} =~ ^[0-9]+$ ]]; then
      exec {LOCKFD}>&-
    fi
    export SHOKUNIN_LANE="$lane" SHOKUNIN_ROUND="$n"
    # shellcheck disable=SC2016  # $1/$2 expand in the inner shell, by design
    exec setsid bash -c 'cd -- "$1" || exit 1; eval "$2"; exit $?' \
      _ "${LANE_CWD[$lane]}" "$run_cmd"
  ) >> "$UFO/state/${lane}.out" 2>&1 &
  pid=$!
  echo "$pid" > "$UFO/state/${lane}.mission"
  echo "$n" > "$UFO/state/${lane}.round"
  log "launch $lane round=$n pgid=$pid"
}

# mission_of — the recorded process-group leader of a lane's live round, or empty.
mission_of() { cat "$UFO/state/$1.mission" 2>/dev/null || true; }

# mission_live — a .mission pid counts only if it names a live process whose
# environ carries OUR SHOKUNIN_LANE tag (H3). A dead pid, a non-numeric value,
# '0' (which would match our own group under kill -0), or a recycled pid owned
# by an unrelated process all read as dead.
mission_live() { # lane mid
  local mid="$2"
  case $mid in ''|*[!0-9]*) return 1 ;; esac
  [ "$mid" -gt 0 ] || return 1
  kill -0 "$mid" 2>/dev/null || return 1
  tr '\0' '\n' < "/proc/$mid/environ" 2>/dev/null | grep -qxF "SHOKUNIN_LANE=$1"
}

# wait_group_exit — bounded wait for a lane's process group, reaping its leader
# when possible. TERM gets 5s; kill_mission escalates to KILL and waits again.
wait_group_exit() { # pgid
  local pgid="$1" attempt
  for ((attempt=0; attempt<50; attempt++)); do
    if ! kill -0 -- "-$pgid" 2>/dev/null; then
      wait "$pgid" 2>/dev/null || true
      return 0
    fi
    sleep 0.1
  done
  return 1
}

# kill_mission — report landed while the lane still runs (H4): TERM then, if
# needed, KILL the whole verified lane group. Return success only after exit.
kill_mission() { # lane mid
  local lane="$1" mid="$2"
  case $mid in ''|*[!0-9]*) return 1 ;; esac
  [ "$mid" -gt 0 ] || return 1
  if ! kill -0 -- "-$mid" 2>/dev/null; then
    wait "$mid" 2>/dev/null || true
    return 0
  fi
  if kill -0 "$mid" 2>/dev/null; then
    # leader alive → it must carry our tag; refuse a recycled pid
    tr '\0' '\n' < "/proc/$mid/environ" 2>/dev/null \
      | grep -qxF "SHOKUNIN_LANE=$lane" || return 1
  fi
  if ! kill -TERM -- "-$mid" 2>/dev/null; then
    if ! kill -0 -- "-$mid" 2>/dev/null; then
      wait "$mid" 2>/dev/null || true
      return 0
    fi
    log "kill-fail $lane pgid=$mid :: TERM refused; not advancing"
    return 1
  fi
  wait_group_exit "$mid" && return 0
  log "kill-escalate $lane pgid=$mid :: group survived TERM; sending KILL"
  if ! kill -KILL -- "-$mid" 2>/dev/null &&
     kill -0 -- "-$mid" 2>/dev/null; then
    log "kill-fail $lane pgid=$mid :: KILL refused; not advancing"
    return 1
  fi
  if wait_group_exit "$mid"; then return 0; fi
  log "kill-timeout $lane pgid=$mid :: group remains after KILL; not advancing"
  return 1
}

# lane_git / commit_evidence — driver-authored commits carry the lane identity
# (attribution, not decoration); the round's rendered prompt is committed as
# dispatch evidence, pathspec-limited so only that file is staged.
lane_git() {
  git -C "$SHOKUNIN_ROOT" -c "user.name=${1}-shokunin" -c "user.email=${1}@shokunin.local" "${@:2}"
}
commit_evidence() { # lane n
  local lane="$1" f=".ufo/prompts/$1-round-$2.md"
  git -C "$SHOKUNIN_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  [ -f "$SHOKUNIN_ROOT/$f" ] || return 0
  lane_git "$lane" add -- "$f" >/dev/null 2>&1 || return 0
  lane_git "$lane" commit -q -m "round-$2: ${lane} dispatch evidence" -- "$f" >/dev/null 2>&1 || true
}

# report_sources_conformance — Sources & frontier is a conformance item, not a
# pass/fail marker. Log absence but never make it a reason to relaunch a round.
report_sources_conformance() { # lane n
  local lane="$1" n="$2" report="$UFO/reports/round-$2/$1.md"
  if [ "${LANE_REPO[$lane]:-}" = . ]; then
    if LC_ALL=C grep -Fq -- 'SOURCES: unchanged — main-repo lanes hold no corpus/' "$report"; then
      return 0
    fi
    log "sources-conformance-defect $lane round=$n :: missing main-repo unchanged marker"
  elif LC_ALL=C grep -qiE '^#{1,6}[[:space:]]+Sources[[:space:]]*&[[:space:]]*frontier([[:space:]]|$)' "$report"; then
    return 0
  else
    log "sources-conformance-defect $lane round=$n :: missing Sources & frontier heading"
  fi
  return 1
}

# sources_gate — validate existing lane registries through the census tool.
# Fleet-root lanes are exempt; rc 1 blocks, while rc 2 means unusable/missing
# registry and is a warning that must not prevent round advancement.
sources_gate() { # lane
  local lane="$1" census="$SHOKUNIN_ROOT/scripts/sources-census.sh" rc out
  if [ "${LANE_REPO[$lane]:-}" = . ]; then
    log "sources-gate-skip $lane :: fleet-root lane"
    return 0
  fi
  if [ ! -x "$census" ]; then
    log "sources-gate-warn $lane :: census instrument missing/unexecutable ($census); skipping"
    return 0
  fi
  out=$("$census" validate --root "$SHOKUNIN_ROOT" "$lane" 2>&1); rc=$?
  case $rc in
    0) return 0 ;;
    1) log "sources-gate-fail $lane :: $(printf '%s' "$out" | head -3 | tr '\n' ' ')"
       return 1 ;;
    *) log "sources-gate-warn $lane :: census rc=$rc :: $(printf '%s' "$out" | head -1); skipping"
       return 0 ;;
  esac
}

# advance — lane n report landed with real content: commit dispatch evidence,
# check the non-blocking §2c conformance item, then validate before respawning.
advance() { # lane n [live process-group id]
  local lane="$1" n="$2" mid="${3:-}"
  commit_evidence "$lane" "$n"
  report_sources_conformance "$lane" "$n" || true
  if [ -f "$UFO/fleet-wrap" ]; then
    if [ -n "$mid" ] && ! kill_mission "$lane" "$mid"; then
      log "advance-blocked $lane round=$n :: lane process group did not exit"
      return 1
    fi
    log "wrap $lane round=$n landed; NOT respawning (fleet-wrap)"
  elif [ "$n" -lt "$MAX_ROUNDS" ]; then
    if sources_gate "$lane"; then
      if [ -n "$mid" ] && ! kill_mission "$lane" "$mid"; then
        log "advance-blocked $lane round=$n :: lane process group did not exit"
        return 1
      fi
      log "complete $lane round=$n; advancing to round=$((n+1))"
      launch_lane "$lane" $((n+1))
    else
      log "advance-blocked $lane round=$n :: sources closure failed; retry same round"
      if ! record_report_baseline "$lane" "$n"; then
        log "advance-blocked $lane round=$n :: report baseline unavailable; NOT retrying"
        return 1
      fi
      [ -n "$mid" ] || launch_lane "$lane" "$n"
    fi
  else
    if [ -n "$mid" ] && ! kill_mission "$lane" "$mid"; then
      log "advance-blocked $lane round=$n :: lane process group did not exit"
      return 1
    fi
    log "cap $lane round=$n reached ROUND_CAP=$MAX_ROUNDS"
  fi
}

main() {
  # singleton lock (H1): one driver per fleet root; a second instance exits.
  exec {LOCKFD}>"$UFO/.watchdog.lock" || die "cannot open lock file $UFO/.watchdog.lock"
  flock -n "$LOCKFD" || die "driver already running (lock: $UFO/.watchdog.lock)"

  local tick=0 lane n mid live
  while :; do
    tick=$((tick+1))
    for lane in "${LANE_LIST[@]}"; do
      n=$(round_of "$lane"); mid=$(mission_of "$lane")
      live=0; mission_live "$lane" "$mid" && live=1
      if [ "$live" -eq 1 ]; then
        if report_of "$lane" "$n"; then
          advance "$lane" "$n" "$mid"
        fi
        continue
      fi
      if report_of "$lane" "$n"; then
        advance "$lane" "$n"
      elif [ -f "$UFO/reports/round-$n/$lane.md" ]; then
        log "lane-report-not-accepted $lane round=$n :: unchanged baseline or failed freshness/content checks; NOT advancing"
        launch_lane "$lane" "$n"
      else
        log "lane-dead-no-report $lane round=$n; retry same round"
        launch_lane "$lane" "$n"
      fi
    done
    log "tick=$tick"
    sleep "$INTERVAL"
  done
}

# Sourced for testing → definitions only; executed → run the driver.
if [ "${BASH_SOURCE[0]:-}" = "$0" ]; then
  main "$@"
fi
