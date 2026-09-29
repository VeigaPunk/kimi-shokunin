#!/usr/bin/env bash
# mint-agent.sh — non-interactive lane mint (Kimi port of the upstream
# sibling-mint mechanic). Scaffolds <fleet-root>/<id>-shokunin/ from the
# canonical seed kit, wires git identity + shokunin.conf, prints probation.
#
#   scripts/mint-agent.sh --id <id> --domain "<domain>" --fleet-root <dir>
#
# Placeholders substituted in every seed file (sed): the templates/mint kit
# ships <name>, <lane> and <DOMAIN> tokens; {{LANE}}/{{DOMAIN}} are also
# honored for forward compatibility. <YYYY-MM-DD> is stamped with today.
# Other <...> fill-ins (evidence basis, integrator session, ...) stay in
# MINT.md for the minting orchestrator to complete — this script cannot
# fabricate the mint-bar evidence.
# The mint bar (two documented unplaceable demand instances or an operator
# directive) is enforced by the /shokunin orchestrator BEFORE this script
# runs; MINT.md in the seed kit carries the evidence record.
set -eu

PLUGIN_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEMPLATES=${MINT_TEMPLATES:-"$PLUGIN_ROOT/templates/mint"}

usage() {
  cat <<'EOF'
Usage: mint-agent.sh --id <id> --domain "<domain>" --fleet-root <dir>

  --id          lowercase lane id (^[a-z0-9]+(-[a-z0-9]+)*$), unique vs the
                shokunin.conf roster and existing <id>-shokunin/ dirs
  --domain      the province the lane owns (one domain per shokunin)
  --fleet-root  fleet root holding shokunin.conf + MANIFEST.json + lanes
EOF
}

ID=""; DOMAIN=""; FLEET_ROOT=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --id) ID=${2:---id needs a value}; shift 2 ;;
    --domain) DOMAIN=${2:---domain needs a value}; shift 2 ;;
    --fleet-root) FLEET_ROOT=${2:---fleet-root needs a value}; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "ERROR: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done
die() { echo "ERROR: $*" >&2; exit 1; }
[ -n "$ID" ] && [ -n "$DOMAIN" ] && [ -n "$FLEET_ROOT" ] || { usage >&2; exit 1; }

# --- validate ----------------------------------------------------------------
[[ "$ID" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "id must match ^[a-z0-9]+(-[a-z0-9]+)*$: $ID"
[ -d "$FLEET_ROOT" ] || die "fleet root not found: $FLEET_ROOT"
CONF="$FLEET_ROOT/shokunin.conf"
[ -f "$CONF" ] || die "roster config not found: $CONF"
[ -d "$TEMPLATES" ] || die "seed kit not found: $TEMPLATES"
kit_files=$(find "$TEMPLATES" -maxdepth 1 -type f | wc -l)
[ "$kit_files" -gt 0 ] || die "seed kit is empty: $TEMPLATES"
LANE_DIR="$FLEET_ROOT/${ID}-shokunin"
[ -e "$LANE_DIR" ] && die "lane dir already exists: $LANE_DIR"
grep -q "\<$ID\>" "$CONF" && die "id '$ID' already present in $CONF"
if [ -f "$FLEET_ROOT/MANIFEST.json" ] && grep -q "\"$ID\"" "$FLEET_ROOT/MANIFEST.json"; then
  die "id '$ID' already present in MANIFEST.json roster"
fi
if grep -qF "$DOMAIN" "$CONF"; then
  echo "WARN: domain '$DOMAIN' already appears in $CONF — contested scope needs an integrator ruling" >&2
fi

# --- scaffold + substitute <name>/<lane>/<DOMAIN> (+ {{LANE}}/{{DOMAIN}}) ----
mkdir -p "$LANE_DIR"
cp -R "$TEMPLATES/." "$LANE_DIR/"
dom_esc=$(printf '%s' "$DOMAIN" | sed -e 's/[&|]/\\&/g')
today=$(date +%F)
find "$LANE_DIR" -type f -exec sed -i \
  -e "s/{{LANE}}/$ID/g" -e "s/{{DOMAIN}}/$dom_esc/g" \
  -e "s/<name>/$ID/g" -e "s/<lane>/$ID/g" \
  -e "s/<DOMAIN>/$dom_esc/g" -e "s/<YYYY-MM-DD>/$today/g" {} +

# --- git identity at mint: <id>-shokunin <<id>@shokunin.local> ---------------
git -C "$LANE_DIR" init -q
git -C "$LANE_DIR" config user.name "${ID}-shokunin"
git -C "$LANE_DIR" config user.email "${ID}@shokunin.local"
git -C "$LANE_DIR" add -A
git -C "$LANE_DIR" commit -q -m "mint: seed ${ID}-shokunin (${DOMAIN})"

# --- register lane in shokunin.conf (LANES pipe-table row) -------------------
{
  printf '\n# minted %s by mint-agent.sh\n' "$(date -Is)"
  printf 'LANES="$LANES\\n%s|%s|%s"\n' "$ID" "${ID}-shokunin" "$DOMAIN"
} >> "$CONF"

echo "minted $LANE_DIR (seed commit: $(git -C "$LANE_DIR" rev-parse --short HEAD))"
cat <<EOF

Probation (shonen) checklist for ${ID}-shokunin:
  [ ] MINT.md names the cause, demand instances + evidence pointers, rejected roster fit, domain boundary
  [ ] round 1: verified one-axis-move round; report .ufo/reports/round-<N>/${ID}.md with real content
  [ ] round 2: verified one-axis-move round
  [ ] round 3: verified one-axis-move round
  [ ] probation recorded as a MANIFEST.json rounds[] entry of type "mint" — NO roster row before this
  [ ] every SHONEN.md box checked by a NAMED NON-AUTHOR verifier ([x] <verifier-id> + evidence pointer); self-marks are [~]
Only the operator adds the MANIFEST.json roster row after probation completes.
EOF
