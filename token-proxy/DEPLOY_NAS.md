# DEPLOY_NAS — runbook for Claude on the NAS

You are Claude Code running on the NAS. The DJfy repo has just been pulled.
Your job: deploy `token-proxy/` and expose it at **https://vault.ol1n.com** via
the existing Cloudflare Tunnel (same pattern as `sonarr.ol1n.com`).

Work only inside `token-proxy/`. Do the steps in order. Stop and ask the human
at any **⛔ CHECKPOINT** — do not guess secrets or invent hostnames.

## What the human must provide before you start

- `SC_CLIENT_ID` and `SC_CLIENT_SECRET` — the (rotated) SoundCloud app creds.
- `PROXY_API_KEY` — the shared key. **It must be byte-for-byte identical to the
  value compiled into the DJfy app's `env.json`.** If the human hasn't picked
  one yet, generate `openssl rand -hex 32`, print it, and tell them to also put
  it in the app's `env.json` → `PROXY_API_KEY`. ⛔ CHECKPOINT: confirm the app
  side uses the same value, otherwise the app gets 401 from the proxy.

Never commit `.env`. Never print `SC_CLIENT_SECRET` back out. Never add these to git.

## Step 1 — configure secrets

```bash
cd token-proxy
cp -n .env.example .env
# Fill SC_CLIENT_ID, SC_CLIENT_SECRET, PROXY_API_KEY in .env (chmod 600 .env)
chmod 600 .env
```

## Step 2 — build & run

```bash
docker compose up -d --build
docker compose ps          # dj-token-proxy should be "healthy" after ~10s
docker compose logs --tail=20
```

## Step 3 — verify locally (on the NAS)

```bash
# health (no auth)
curl -fsS http://127.0.0.1:8080/healthz            # → ok

# token mint (auth) — expect JSON with access_token + expires_in
curl -fsS -H "X-Proxy-Key: $(grep '^PROXY_API_KEY=' .env | cut -d= -f2)" \
  http://127.0.0.1:8080/sc/token
```

- 200 + `access_token` → SoundCloud creds are good.
- 502 `upstream token error` → check `docker compose logs`; likely the SC creds
  are invalid/rejected (SoundCloud API is closed to new apps — ⛔ CHECKPOINT,
  report this to the human, it is NOT a proxy bug).
- 401 → the `X-Proxy-Key` doesn't match `.env`.

## Step 4 — expose via Cloudflare Tunnel (vault.ol1n.com)

Do NOT reinvent the setup — **mirror exactly how `sonarr.ol1n.com` reaches its
container.** First discover the existing tunnel:

```bash
# find the cloudflared setup and how sonarr is wired
docker ps --format '{{.Names}}\t{{.Image}}' | grep -i cloudflare
find / -name 'config.yml' 2>/dev/null | xargs grep -l 'sonarr' 2>/dev/null
docker inspect <cloudflared-container> 2>/dev/null | grep -iA3 'network\|token\|config'
```

Then add `vault.ol1n.com` the same way sonarr was added:

**Case A — locally-managed tunnel (there is a `config.yml` with `ingress:`):**
Add an ingress rule *above* the catch-all `http_status:404`, pointing at the
proxy. If cloudflared and dj-token-proxy share a docker network, use the
service name; otherwise use the host.

```yaml
ingress:
  - hostname: vault.ol1n.com
    service: http://dj-token-proxy:8080   # same docker network
    # service: http://host.docker.internal:8080   # if cloudflared reaches host ports
  # ... existing sonarr rule ...
  - service: http_status:404
```
Put dj-token-proxy on the cloudflared network if needed (mirror sonarr), then:
```bash
# add the DNS route + reload
cloudflared tunnel route dns <tunnel-name> vault.ol1n.com   # if not already routed
docker restart <cloudflared-container>
```

**Case B — dashboard-managed tunnel (cloudflared runs with a `--token`, no local config):**
The public hostname is added in the Cloudflare Zero-Trust dashboard, not on the
NAS filesystem. ⛔ CHECKPOINT: either ask the human to add
`vault.ol1n.com → http://dj-token-proxy:8080` (or `http://<nas-ip>:8080`) as a
public hostname on the existing tunnel, or, if `CLOUDFLARE_API_TOKEN` is
available, add it via the CF API mirroring the sonarr entry.

> TLS is terminated at the Cloudflare edge — vault.ol1n.com is HTTPS
> automatically, so the compose file binding to `127.0.0.1:8080` is correct and
> safe. Do **not** put Cloudflare Access (interactive login) in front of this
> hostname — the app can't log in interactively; the `X-Proxy-Key` is the auth.
> (A CF Access *service token* is an optional hardening, but only if you also
> wire that token into the app.)

## Step 5 — verify externally

```bash
curl -fsS https://vault.ol1n.com/healthz                       # → ok
curl -fsS -H "X-Proxy-Key: <PROXY_API_KEY>" \
  https://vault.ol1n.com/sc/token                              # → JSON token
```

## Step 6 — report back

Tell the human:
- container status (healthy?),
- local + external verification results,
- whether SoundCloud mint returned a real token or 502 (creds closed/invalid),
- confirm the `PROXY_API_KEY` value the app must match (already known if they
  provided it; otherwise the one you generated in Step 1).

## Guardrails

- `.env` stays on the NAS, `chmod 600`, never committed, never logged.
- Only `vault.ol1n.com` and the local `:8080` should reach the proxy.
- If a step fails twice, stop and report — don't loop.
