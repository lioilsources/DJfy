# dj-token-proxy

Tiny Go service that holds the SoundCloud **client_secret** on the NAS and hands
the DJfy app short-lived access tokens. The secret never enters the app binary,
so it can't be extracted from a release artifact (unlike a `--dart-define`,
which ends up as a plaintext string in the compiled app).

```
DJfy app  ──GET /sc/token (X-Proxy-Key)──▶  dj-token-proxy ──client_credentials──▶  SoundCloud
          ◀──── { access_token, expires_in } ───────────────────────────────────
```

The app then talks to `api.soundcloud.com` directly using that short-lived
token. Only a `PROXY_API_KEY` is shipped in the app — it grants nothing but
access to this proxy and is trivially rotated/rate-limited.

## Endpoints

| Method | Path         | Auth              | Returns                              |
|--------|--------------|-------------------|--------------------------------------|
| GET    | `/sc/token`  | `X-Proxy-Key`     | `{ "access_token": "...", "expires_in": N }` |
| GET    | `/healthz`   | none              | `ok`                                 |

`/sc/token` accepts the key as either `X-Proxy-Key: <key>` or
`Authorization: Bearer <key>`. The token is cached in-process and refreshed
before expiry, so SoundCloud sees at most one token request per hour regardless
of app traffic.

## Configuration (env)

| Var                | Required | Default                                        |
|--------------------|----------|------------------------------------------------|
| `SC_CLIENT_ID`     | yes      | —                                              |
| `SC_CLIENT_SECRET` | yes      | —                                              |
| `PROXY_API_KEY`    | yes      | — (`openssl rand -hex 32`)                     |
| `LISTEN_ADDR`      | no       | `:8080`                                        |
| `SC_TOKEN_URL`     | no       | `https://api.soundcloud.com/oauth2/token`      |

```bash
cp .env.example .env      # then fill in the values
```

## Deploy A — Docker Compose (Synology/QNAP/TrueNAS)

```bash
docker compose up -d --build
docker compose logs -f
curl -s -H "X-Proxy-Key: $PROXY_API_KEY" http://127.0.0.1:8080/sc/token
```

The compose file binds to `127.0.0.1:8080` and expects TLS to be terminated by
the NAS reverse proxy in front of it. If the app reaches the NAS over a trusted
network (Tailscale/WireGuard), drop the `127.0.0.1:` prefix in the port mapping.

## Deploy B — systemd (bare-metal Linux NAS)

```bash
go build -trimpath -ldflags="-s -w" -o /opt/dj-token-proxy/dj-token-proxy .
sudo install -Dm600 .env /etc/dj-token-proxy.env
sudo cp deploy/dj-token-proxy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now dj-token-proxy
journalctl -u dj-token-proxy -f
```

## App-side change (DJfy)

The app no longer needs `SC_CLIENT_ID` / `SC_CLIENT_SECRET`. Swap those two
dart-defines for the proxy URL + key, and change `authenticate()` in
`lib/services/soundcloud_service.dart` to fetch the token from the proxy:

```dart
// constants.dart
const kTokenProxyUrl = String.fromEnvironment('TOKEN_PROXY_URL');
const kProxyApiKey   = String.fromEnvironment('PROXY_API_KEY');

// soundcloud_service.dart — authenticate()
final res = await _dio.get(
  '$kTokenProxyUrl/sc/token',
  options: Options(headers: {'X-Proxy-Key': kProxyApiKey}),
);
_accessToken = res.data['access_token'] as String?;
final expiresIn = (res.data['expires_in'] as num?)?.toInt() ?? 3600;
_tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
```

```jsonc
// env.json — SC secret is gone from the client
{
  "TOKEN_PROXY_URL": "https://nas.example.net",
  "PROXY_API_KEY": "<same value as on the NAS>"
}
```

## Hardening notes

- **Always put TLS in front** (NAS reverse proxy or Tailscale). The proxy key
  travels in a header — don't send it over plain HTTP on an untrusted network.
- Logs never contain the key, token, or secret — only method/path/status.
- Rotate `PROXY_API_KEY` by updating `.env` (or `/etc/dj-token-proxy.env`) and
  the app's dart-define; no code change needed.
