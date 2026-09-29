#!/usr/bin/env bash
# kimi-shokunin plugin installer — sanity checks + install instructions.
# Does NOT install the plugin itself; use Kimi Code CLI (see below).
set -eu
STAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
usage() {
  cat <<'EOF'
Usage: install.sh [--help]
Sanity-checks the plugin tree (required files, mint-kit shape, script syntax,
manifest JSON) and prints the install instructions. Does not modify host config.
  /plugins install https://github.com/VeigaPunk/kimi-shokunin
  /reload
Local dev: /plugins install /path/to/kimi-shokunin, then /reload.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    *) echo "ERROR: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done
fail() { echo "ERROR: $*" >&2; exit 1; }
echo "[kimi-shokunin] Sanity checks"
# protocol/ + templates/ have their own owners; gate them here so a partial
# tree fails loudly before install.
for f in kimi.plugin.json README.md LICENSE .gitignore commands/shokunin.md \
         skills/shokunin/SKILL.md scripts/shokunin-watchdog.sh scripts/mint-agent.sh \
         templates/round-prompt.md templates/MANIFEST.schema.json templates/shokunin.conf.example; do
  [ -f "$STAGE_DIR/$f" ] || fail "missing required file: $f"
done
[ -d "$STAGE_DIR/templates/mint" ] || fail "missing dir: templates/mint"
kit_files=$(find "$STAGE_DIR/templates/mint" -maxdepth 1 -type f | wc -l)
[ "$kit_files" -eq 7 ] || fail "templates/mint must contain exactly 7 files (found $kit_files)"
echo "[kimi-shokunin] required files OK (mint kit: 7 files)"
for s in scripts/shokunin-watchdog.sh scripts/mint-agent.sh; do
  bash -n "$STAGE_DIR/$s" || fail "$s failed bash -n"
done
echo "[kimi-shokunin] script syntax OK"
if command -v python3 >/dev/null 2>&1; then
  python3 -c "import json,sys; json.load(open('$STAGE_DIR/kimi.plugin.json'))" \
    || fail "kimi.plugin.json is not valid JSON"
elif command -v node >/dev/null 2>&1; then
  node -e "JSON.parse(require('fs').readFileSync('$STAGE_DIR/kimi.plugin.json','utf8'))" \
    || fail "kimi.plugin.json is not valid JSON"
else
  fail "python3 or node required for the JSON check"
fi
echo "[kimi-shokunin] manifest JSON OK"
cat <<'EOF'
[kimi-shokunin] Install the plugin from Kimi Code CLI with:
  /plugins install https://github.com/VeigaPunk/kimi-shokunin
  /reload
[kimi-shokunin] Local dev: /plugins install /path/to/kimi-shokunin, then /reload
EOF
