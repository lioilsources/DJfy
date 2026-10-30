#!/usr/bin/env bash
# store_screenshots.sh — phone screenshots for the store page (olin.now): the
# host app in an iOS simulator, the guest PWA in headless Chrome, and a real
# party between them on a local relay.
#
#   tool/store_screenshots.sh <out-dir>
#
# integration_test/store_screenshots_test.dart drives the host app and prints
# `SHOT <name>` when a screen is ready; this script captures the simulator then.
# On `PARTY_CODE` it plays the guests: two in Chrome (search, propose, vote;
# Káťa's screens are captured), two more over plain HTTP (join, vote).
#
# Needs .env (API keys, see constants.dart), Go, Node >= 22, Chrome, and
# ol1n.now's scripts/shoot.mjs (SHOOT=..., default ../ol1n.now/scripts/shoot.mjs).
# LOG=<file> keeps the full flutter test output.
set -euo pipefail

OUT="$(mkdir -p "${1:?usage: $0 <out-dir>}" && cd "$1" && pwd)"
cd "$(dirname "$0")/.."
SHOOT="$(cd "$(dirname "${SHOOT:-../ol1n.now/scripts/shoot.mjs}")" && pwd)/$(basename "${SHOOT:-shoot.mjs}")"
export CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
SIM="DJfy-Shots-iPhone"
PORT=8097
RELAY="http://127.0.0.1:$PORT"
TMP="$(mktemp -d)"
[ -f .env ] || { echo "error: .env with the API keys is missing" >&2; exit 1; }
[ -f "$SHOOT" ] || { echo "error: shoot.mjs not found at $SHOOT" >&2; exit 1; }

# ---- relay ------------------------------------------------------------------
(cd services/djfy && go build -o "$TMP/relay" .)
DJFY_ADDR="127.0.0.1:$PORT" "$TMP/relay" > "$TMP/relay.log" 2>&1 &
relay_pid=$!
trap 'kill $relay_pid 2>/dev/null || true; rm -rf "$TMP"' EXIT
for _ in $(seq 1 50); do curl -s -o /dev/null "$RELAY/" && break; sleep 0.2; done

# ---- simulator --------------------------------------------------------------
udid="$(xcrun simctl list devices available | awk -v n="$SIM" -F '[()]' 'index($0, "    " n " (") == 1 { print $2; exit }')"
if [ -z "$udid" ]; then
  # newest iOS runtime that accepts the device type (a fresh beta may not)
  for runtime in $(xcrun simctl list runtimes available | awk '/^iOS/ { print $NF }' | sort -rV); do
    udid="$(xcrun simctl create "$SIM" "iPhone 18 Pro Max" "$runtime" 2>/dev/null)" && break
  done
  [ -n "$udid" ] || { echo "error: could not create $SIM" >&2; exit 1; }
fi
xcrun simctl boot "$udid" 2>/dev/null || true
xcrun simctl bootstatus "$udid" -b >/dev/null
xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 --dataNetwork wifi

# ---- guests -----------------------------------------------------------------
# chrome_guest <plan-name> <steps-json>
chrome_guest() { printf '{"steps":[%s]}' "$2" > "$TMP/$1.json"; node "$SHOOT" "$TMP/$1.json" >/dev/null; }

# http_guest <code> <guestId> <name> <message-json>
http_guest() {
  curl -s -o /dev/null -X POST "$RELAY/api/sessions/$1/messages" -H 'Content-Type: application/json' \
    -d "{\"guestId\":\"$2\",\"name\":\"$3\",$4}"
}

guests() {
  code="$1"; url="$RELAY/j/$code"
  join='{"click":"#name"},{"type":"%s"},{"click":"#join-form .primary"},{"wait":2500}'
  propose='{"click":"[data-tab=search]"},{"click":"#q"},{"type":"%s"},{"click":"#search-form .primary"},{"wait":7000}'

  # Lukáš proposes one track, quietly.
  chrome_guest lukas "{\"goto\":\"$url\"},{\"wait\":1500},$(printf "$join" 'Lukáš'),$(printf "$propose" 'Justice'),
    {\"click\":\"#results li:nth-child(2) .add\"},{\"wait\":1500}"

  # Tomáš and Eva only vote: thumbs up for the first three, Eva dislikes the fourth.
  http_guest "$code" guest-tomas '🕺 Tomáš' '"type":"join"'
  http_guest "$code" guest-eva '🦄 Eva' '"type":"join"'
  sleep 3
  ids="$(curl -s "$RELAY/api/sessions/$code" | python3 -c 'import sys, json
s = json.load(sys.stdin) or {}
print(" ".join(e["entryId"] for e in s.get("queue", [])))')"
  n=0
  for id in $ids; do
    n=$((n + 1))
    [ $n -le 3 ] && for g in 'tomas 🕺 Tomáš' 'eva 🦄 Eva'; do http_guest "$code" "guest-${g%% *}" "${g#* }" "\"type\":\"vote\",\"entryId\":\"$id\",\"value\":1"; done
    [ $n -eq 4 ] && http_guest "$code" guest-eva '🦄 Eva' "\"type\":\"vote\",\"entryId\":\"$id\",\"value\":-1"
  done

  # Káťa is the one on camera: join, propose two, vote.
  chrome_guest kata "{\"goto\":\"$url\"},{\"wait\":1500},{\"click\":\"#name\"},{\"type\":\"Káťa\"},
    {\"shot\":\"$OUT/guest-01-join.png\"},{\"click\":\"#join-form .primary\"},{\"wait\":2500},
    $(printf "$propose" 'Daft Punk'),{\"click\":\"#results li:nth-child(2) .add\"},{\"wait\":1200},
    {\"click\":\"#results li:nth-child(4) .add\"},{\"wait\":1500},{\"shot\":\"$OUT/guest-03-search.png\"},
    {\"click\":\"[data-tab=queue]\"},{\"wait\":1500},{\"click\":\"#queue li:nth-child(1) .vote.up\"},
    {\"wait\":2500},{\"shot\":\"$OUT/guest-02-queue.png\"}"
  echo "  guests done"
}

# ---- host -------------------------------------------------------------------
flutter test integration_test/store_screenshots_test.dart -d "$udid" \
  --dart-define-from-file=.env --dart-define=DJFY_RELAY_URL="$RELAY" 2>&1 | tee "${LOG:-/dev/null}" |
while IFS= read -r line; do
  case "$line" in
    *"SHOT "*)       name="${line##*SHOT }"
                     xcrun simctl io "$udid" screenshot --type=png "$OUT/$name.png" >/dev/null 2>&1
                     echo "  $name.png" ;;
    *"PARTY_CODE "*) guests "${line##*PARTY_CODE }" & ;;
    *"HOST_DONE"*)   wait ;;
    *"Some tests failed"*|*"[E]"*|*"EXCEPTION CAUGHT"*) echo "$line" >&2 ;;
  esac
done
echo "done -> $OUT"
