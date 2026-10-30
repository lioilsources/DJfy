# djfy relay

Small Go relay for DJfy party mode (stdlib only). The host phone owns the party
state; the relay forwards guest messages to the host, fans host snapshots out to
guests, and caches the latest snapshot so guests can still join while the host
briefly drops offline. It also serves the guest PWA at `/j/<CODE>`.

```bash
go test -race ./...
DJFY_ADDR=:8097 go run .            # DJFY_TRUST_PROXY=1 behind Caddy/nginx (X-Forwarded-For)
```

Sessions live in memory and are dropped after 12 h idle; a restart ends all parties.

## API

| Method | Path | Auth | |
|---|---|---|---|
| POST | `/api/sessions` | – | → `{code, hostToken}` (20/h per IP) |
| GET | `/api/sessions/{code}` | – | cached snapshot (`null` before the first one) |
| DELETE | `/api/sessions/{code}` | host | end the party; guests get `ended` |
| GET | `/api/sessions/{code}/host/events` | host | SSE `guest` events; queued messages flush on connect |
| POST | `/api/sessions/{code}/host/snapshot` | host | broadcast + cache (≤256 KB) |
| POST | `/api/sessions/{code}/host/send` | host | `{guestId, data}` → that guest's `private` event |
| POST | `/api/sessions/{code}/host/ban` | host | `{guestId}`; the relay rejects them from then on |
| GET | `/api/sessions/{code}/events?guest=ID` | – | SSE: `snapshot`, `private`, `banned`, `ended` |
| POST | `/api/sessions/{code}/messages` | – | guest `join`/`search`/`propose`/`vote`/`veto` |

Host auth = `Authorization: Bearer <hostToken>`. Guest limits per guest id:
5 proposals / 10 min, 30 searches / min, 60 votes+vetoes / min (→ 429).

Guests only ever send ids (`trackId` from the host's search results, `entryId`
from the snapshot). Tracks and stream URLs are resolved on the host phone.
