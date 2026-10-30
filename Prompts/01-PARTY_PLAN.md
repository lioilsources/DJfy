# DJFY_PLAN.md — Plán, jak DJfy vyhraje tam, kde Spotify selhává

> Handoff pro Claude Code. Kontext: Ol1n (Go + Flutter, vlastní AI infra, Apple + Play dev účty). Navazuje na `DJ_DECK_PLAN.md` (6 decků, BPM matching, SoundCloud + Last.fm + GetSongBPM, bez backendu). DJfy = DJ_DECK + sdílená fronta pro party.

## 0. Teze

Spotify má ve chvíli, kdy hraje party, **architektonickou díru**: autoritou nad frontou je přehrávací zařízení (Sonos, TV, reproduktor), ne hostitel. Jakmile zařízení neumí obousměrný Jam protokol, Spotify frontu zablokuje ("Let DJ pick"). Spotify to nemůže snadno opravit — Connect je postaven na "zařízení je přehrávač, telefon je ovladač" a přepis na "telefon je přehrávač" by rozbil certifikace stovek partnerů.

**DJfy to otáčí:** *Telefon hostitele je DJ. Reproduktor je jen reproduktor.* Fronta, hlasování, BPM a crossfade žijí lokálně na hostitelově telefonu; zvuk jde ven přes AirPlay / Bluetooth / Cast / Sonos. Reproduktor nikdy nerozhoduje o tom, co hraje dál.

Realistický cíl: ne "zabít Spotify" (300M+ platících), ale **vyhrát jeden konkrétní moment — večírek, bar, svatbu** — kde Spotify ztrapní hostitele chybovou hláškou. Tenhle moment je sociální a virální (každý host se dívá na QR kód).

## 1. Proč to Spotify nezkopíruje (a proč na něm nestavět)

- **Spotify Web API je od 15. 5. 2025 prakticky uzavřené**: extended quota jen pro registrované firmy s 250k MAU; dev mode = 5–25 uživatelů. Write endpointy (playlisty) v dev módu nefungují. ⇒ DJfy **nikdy nestaví na Spotify jako backendu**. Spotify maximálně jako *import* (viz 4.4).
- Spotify Jam na Sonosu nefunguje ani s vlastním hardwarem partnera — to je důkaz, že problém je v protokolu, ne v Sonosu.
- Sonos sám odstranil frontu z nové aplikace (2024) a uživatelé zuří. Díra na obou stranách.

## 2. Produkt — tři vrstvy

### 2.1 Host (Flutter app, iOS + Android)
- Zakládá "Session" (party). Zobrazí QR + krátký link `djfy.ol1n.com/j/ABCD`.
- Přehrává hudbu **lokálně** (host je zdroj zvuku), výstup: AirPlay 2 / Bluetooth / Google Cast / Sonos.
- Vidí frontu, hlasy, BPM, energii; může přepnout "Auto-DJ" (BPM matching + crossfade z DJ_DECK).
- Má veto, "play now", "ban guest", "mood lock" (např. jen 120–128 BPM).

### 2.2 Guest (web, bez instalace, bez účtu)
- Otevře link z QR → PWA. Jméno (nebo anonymní emoji). Žádné přihlášení.
- Hledá skladby, navrhuje, hlasuje 👍/👎, vidí "co hraje" a "co bude".
- Rate limit: N návrhů / 10 min, hlasování 1× na skladbu. Host může povýšit hosta na co-DJ.
- Volitelně nativní appka později; MVP = web.

### 2.3 Relay (Go, na Ol1nově infra)
- Malý WebSocket/SSE relay: `session`, `proposals`, `votes`, `now_playing`. Stav drží host, relay jen přeposílá a cachuje poslední snapshot (hosté se připojují i když je host offline chvilku).
- Bez relay funguje LAN fallback (mDNS + lokální HTTP na telefonu hostitele) — pro bary bez internetu.
- Rozšiřuje existující Go stack (`services/djfy/`, port vybrat podle konvence v infrastructure.md).

## 3. Co hraje — katalog (klíčové rozhodnutí)

| Zdroj | Plné skladby? | Pro koho | Poznámka |
|---|---|---|---|
| **Apple Music (MusicKit)** | ano, 30s preview bez předplatného | hostitel s Apple Music | Oficiálně otevřené 3rd-party appkám, iOS i Android SDK. Potřebuje MusicKit token z Ol1nova Apple dev účtu. DRM ⇒ **nelze mixovat/crossfadovat** dva streamy, jen gapless přepínání. |
| **SoundCloud** | ano (HLS AAC) | všichni | Už v DJ_DECK. Plný DJ engine (crossfade, BPM, seek). |
| **Lokální soubory / vlastní knihovna** | ano | DJové, bary | Plný DJ engine. Import z Files/Drive. |
| **Spotify** | ne | — | Jen import playlistu ze share-linku (veřejný playlist → match na Apple Music / SoundCloud podle ISRC/název+interpret). Žádné API s uživatelským loginem. |
| YouTube Music | ne | — | ToS zakazují přehrávání na pozadí v 3rd-party; vynechat. |

**Strategie:** hostitel vybere "engine": *Apple Music mode* (nejširší katalog, fronta + hlasování, bez mixu) nebo *DJ mode* (SoundCloud + lokální, plný crossfade). Hosté hledají v obou současně; výsledky označené zdrojem.

Ověřit v Phase 0: MusicKit na Flutteru (`music_kit` package nebo vlastní platform channel), přehrávání na Sonos přes AirPlay při aktivní MusicKit session, chování fronty při přepnutí výstupu.

## 4. Výstup zvuku — jak obejít Connect

### 4.1 AirPlay 2 (iOS host) — **primární cesta pro Sonos**
Novější Sonos (One, Beam, Arc, Era, Five, Move…) umí AirPlay 2. Telefon je zdroj, fronta zůstává v DJfy. Přesně to, co uživatel ve výchozím problému chtěl. Flutter: `AVRoutePickerView` přes platform view, `AVAudioSession` kategorie `.playback`, `allowAirPlay`.

### 4.2 Bluetooth — funguje všude, nulová integrace.

### 4.3 Google Cast (Android host)
Cast SDK: telefon pošle URL streamu (SoundCloud HLS / lokální soubor přes lokální HTTP server). Apple Music přes Cast **nelze** (DRM) — v Cast režimu jen DJ mode.

### 4.4 Sonos nativně (Phase 4, volitelné)
- **Lokální UPnP** (SoCo-style, `AVTransport` + `Queue`): DJfy sám plní Sonos frontu URL skladeb (SoundCloud/lokální). Funguje jen pro non-DRM zdroje. Známý limit: když Sonos běží v session "Started from Spotify", UPnP fronta se nespustí — DJfy musí session nejdřív ukončit (`Stop` + clear queue).
- **Sonos Cloud Queue API** (oficiální): elegantní (player si sám stahuje okno skladeb z Ol1nova serveru), ale vyžaduje být registrovaný *content service partner* (SMAPI). Dlouhá cesta; zaparkovat, dokud DJfy nemá trakci.

## 5. DJ vrstva (z DJ_DECK)

- BPM waterfall: GetSongBPM → lokální FFT prvních 15 s → SQLite cache (hotovo v plánu DJ_DECK).
- **Smart queue**: skóre skladby = hlasy × čerstvost × BPM-kompatibilita s aktuální skladbou × "mood lock". Host vidí proč je skladba kde je.
- Auto-crossfade a beatmatch jen v DJ mode (SoundCloud/lokální). V Apple Music mode: gapless + "DJ přechod" = krátký jingle/TTS mezi skladbami.
- **AI DJ hlas** (differentiator, Phase 5): mezi skladbami krátká hláška generovaná Ol1novým LLM + TTS ("Tohle přidala Káťa, dejte jí 👍"). Běží na Sparku, host si stáhne 2–5 s klip před přechodem. Spotify AI DJ je anglický monolog bez kontextu party; DJfy mluví česky o lidech v místnosti.

## 6. Monetizace

- **Hosté vždy zdarma, bez účtu.** To je motor růstu.
- Host Free: 1 session, 8 hostů, bez AI DJ.
- Host Pro (měsíc/rok, IAP): neomezení hosté, Auto-DJ, AI hlas, Sonos nativně, export playlistu večera.
- **Bar/Venue plán** (B2B, přes olin.now/business): tablet u baru + QR na stolech, kuchyňský/barový veto, "žádný Despacito" blacklist, statistiky večera. První zákazník: U Chřestýše (viz RattleRamp — stejný tablet). Svatby: jednorázová licence.

## 7. Fáze

### Phase 0 — Reality check (1 týden)
1. Flutter + MusicKit: přehrát plnou skladbu s Apple Music předplatným na iOS i Androidu.
2. Přepnout výstup na Sonos přes AirPlay 2, přidat skladbu do lokální fronty, ověřit že nic nespadne. **Toto je demo, které zabíjí původní chybovou hlášku.**
3. Ověřit MusicKit ToS k "party/queue" use-case (mix a tempo změny zakázané — nedělat).
4. Rozhodnout: pokračovat / pouze DJ mode.

### Phase 1 — Host MVP (2–3 týdny)
- Session, lokální fronta, Apple Music + SoundCloud search, přehrávání, AirPlay/BT.
- Reuse DJ_DECK UI: jeden "deck" = now playing, fronta pod ním.

### Phase 2 — Guests (2 týdny)
- Go relay (`services/djfy`), PWA guest, QR join, návrhy + hlasy, rate limit, host veto.
- LAN fallback (mDNS) jako P2.

### Phase 3 — Smart queue + DJ mode (2 týdny)
- Skóre fronty, mood lock, BPM, crossfade pro SoundCloud/lokální.

### Phase 4 — Výstupy (2 týdny)
- Google Cast, Sonos UPnP, lokální HTTP server pro streamování souborů.

### Phase 5 — AI DJ hlas (1–2 týdny)
- LLM prompt z event kontextu (kdo přidal, hlasy, čas), TTS na Sparku, prefetch klipů.

### Phase 6 — Venue mode + launch
- Tablet UI, blacklist, statistiky; TestFlight/Play; pilot v baru; video "Spotify říká ne, DJfy hraje".

## 8. Rizika

- **MusicKit ToS** — Apple může zakázat crossfade/mix; proto mix jen na non-DRM zdrojích. Ověřit v Phase 0 před jakoukoli investicí.
- **Apple Music jen pro předplatitele** — bez předplatného 30s preview; hosté nic nepotřebují, hostitel ano.
- **Android host + Apple Music** — MusicKit Android SDK existuje, ale méně udržovaný; Android host primárně DJ mode + Cast.
- **AirPlay jen na novějším Sonosu** — starý Play:1/Play:3 nemá AirPlay ⇒ UPnP cesta (Phase 4).
- **Právní**: DJfy nehostuje hudbu, nestahuje, neobchází DRM. Veškeré přehrávání přes oficiální SDK nebo uživatelovy soubory. Veřejná produkce v baru = licence OSA/Intergram řeší provozovatel (upozornit ve Venue plánu).
- **"Zabije Spotify"** — ne. Cíl = stát se defaultní appkou pro moment "hoď to na QR", a tím být tam, kde Spotify nemá co nabídnout.

## 9. První commit

```
djfy/
  app/            # Flutter (host), reuse z DJ_DECK: audio engine, deck widget, BPM
  guest/          # PWA (Flutter web nebo lehký Svelte), join + search + vote
  services/djfy/  # Go relay: sessions, proposals, votes, snapshot cache
  docs/DJFY_PLAN.md
```

Začít Phase 0 bodem 2 — pětiminutové video, kde Spotify ukáže "Let DJ pick" a DJfy na tom samém Sonosu přidá skladbu do fronty. To je celý pitch.
