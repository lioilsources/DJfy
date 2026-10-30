#!/usr/bin/env bash
# Deploy the relay from the Mac to JODA. Idempotent: tunnel and DNS are created once.
#
#   services/djfy/deploy/deploy.sh
#
# JODA: ~/deploy/DJfy/relay; cloudflared/ creds stay there.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
JODA=${JODA:-joda}
HOSTNAME_RELAY=djfy.ol1n.com

echo "== JODA: sync"
ssh "$JODA" 'mkdir -p ~/deploy/DJfy'
rsync -a --delete --exclude 'deploy/cloudflared/*.json' --exclude deploy/cloudflared/config.yml \
  "$ROOT/" "$JODA":deploy/DJfy/relay/

echo "== JODA: tunnel, compose up"
ssh "$JODA" HOSTNAME_RELAY="$HOSTNAME_RELAY" bash -s <<'REMOTE'
set -euo pipefail
cd ~/deploy/DJfy/relay/deploy
if [ ! -f cloudflared/config.yml ]; then
  # --config /dev/null: never fall back to ~/.cloudflared/config.yml (another tunnel).
  cf() { cloudflared tunnel --config /dev/null --origincert ~/.cloudflared/cert.pem "$@" 2>/dev/null; }
  tunnel_id() { cf list -o json | python3 -c \
    'import sys,json;print(next((t["id"] for t in json.load(sys.stdin) if t["name"]=="djfy"),""))'; }
  ID=$(tunnel_id)
  [ -n "$ID" ] || { cf create djfy >/dev/null; ID=$(tunnel_id); }
  [ -n "$ID" ] || { echo "tunnel djfy not created" >&2; exit 1; }
  # cloudflared runs as nonroot in the container: creds must be readable.
  install -m 644 ~/.cloudflared/"$ID".json cloudflared/"$ID".json
  sed "s/<TUNNEL-ID>/$ID/g" cloudflared/config.yml.example > cloudflared/config.yml
  cf route dns "$ID" "$HOSTNAME_RELAY"
  echo "tunnel djfy = $ID"
fi
docker compose up -d --build
docker compose ps
REMOTE

echo "== check"
curl -s -m 10 -o /dev/null -w "https://$HOSTNAME_RELAY/healthz → %{http_code}\n" \
  "https://$HOSTNAME_RELAY/healthz" || true
