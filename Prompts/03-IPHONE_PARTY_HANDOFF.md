# 03 — Handoff: party na iPhonu

> Cíl: rozběhat party na reálném iPhonu a build nasadit přímo na telefon.
> Tento stroj má málo paměti na build, proto se v předchozí session nic neopravilo ani nebuildovalo.
> Výchozí stav: `main` @ 9f04705 (v1.2.1). Začni novou větví, např. `fix/iphone-party-bugs`.
> Každou opravu dej do vlastního commitu.

## Stav

| Věc | Stav |
|---|---|
| Relay `https://djfy.ol1n.com` | Běží na JODA, veřejně ověřený tok: healthz, PWA, session, SSE hosta, 401, DELETE |
| Přehrávání v appce | Nespuštěno, oprav body níže |
| Oprava bugů č. 1–3 | Nezačatá, žádný kód se nezměnil |
| AirPlay na Sonos | Nikdy netestováno |

Podrobný popis bugů č. 1–3 je na jiné větvi, do `main` se nedostal:

```sh
git show origin/chore/store-screenshots:Prompts/02-BUGFIX_HANDOFF.md
```

Na stejné větvi je `integration_test/store_screenshots_test.dart` a `tool/store_screenshots.sh`.
Ta větev zároveň mění `release-android.yml`, proto ji nemerguj celou.

## Build na telefon

- SoundCloud klíče jsou nutné: bez `SC_CLIENT_ID` a `SC_CLIENT_SECRET` nefunguje hledání ani přehrávání.
- `lib/core/constants.dart` je čte přes `String.fromEnvironment`, takže build potřebuje
  `--dart-define-from-file=env.json` nebo `--dart-define=…`.
- `env.json` na Macu s tímto handoffem ty dva klíče vůbec nemá a ostatní hodnoty kromě
  `TOKEN_PROXY_URL` jsou prázdné. Doplň je z vlastního zdroje. GitHub Secrets jdou jen zapsat, ne přečíst.
- `env.json` není v `.gitignore` a je untracked. **Nikdy ho necommituj.** Přidej ho do `.gitignore`.
- Mac s tímto handoffem má Xcode 26.2 a iPhone 12 mini iOS 27.0.1. Handoff 02 vznikl s Xcode 27.1.
  Na stroji pro build ověř, že Xcode daný iOS podporuje.
- Relay URL netřeba zadávat, výchozí hodnota je produkční.

## Opravy podle priority

### 1. iOS release build nemá klíče (P0, ověřeno v kódu)

`.github/workflows/release-ios.yml:91` volá `flutter build ios --release --no-codesign` bez dart-define.
TestFlight build v1.2.1 proto klíče nemá. Stejně je na tom `release-macos.yml:33`.
Oprav to stejně jako `release-android.yml` (ř. 62, 71 a jejich `env:`). Secrets na GitHubu existují.

Přímý build na telefon tohle neblokuje, další TestFlight ano.

### 2. Tiché selhání načtení skladby (P0, ověřeno v kódu, v handoffu 02 není)

- `AudioEngine._loadViaSoLoud` chybu chytí a vrátí `false`.
- `AudioEngine.loadTrack` tedy při selhání SoLoudu **nepřejde na just_audio**, i když to dokumentace projektu slibuje.
- `PartyPlayer._load` návratovou hodnotu ignoruje a vrací `true`.
- Výsledek: party hlásí „hraje“, deck je prázdný, `onFailed` se nezavolá a další skladba se nezkusí.

Oprava:
- Po selhání SoLoudu v `loadTrack` zavolej `_loadViaJustAudio(deckId, hlsUrl)`.
  Pozor: `streamsFor` dává `fallback = progressive`, takže `hlsUrl` je pak stejná URL. Na skutečný
  fallback je potřeba použít `_getStreamUrl`, tedy HLS.
- `loadTrack` dnes vrací `hasDsp`, ne úspěch. Chyba just_audio se má propagovat do `_load`.
- Zkontroluj, jestli ruční decky (`DeckCubit.loadTrack`) spoléhají na stejné chování.

### 3. Bug č. 1: start party trvá 8 minut (P0)

Změřeno jen v simulátoru. Ověřeno v kódu:
- `PartyPlayer._load`, `AudioEngine.loadTrack` ani `SoLoud.loadUrl` nemají timeout.
- `_advance` zkouší až 3 skladby, takže se čekání sčítá.

Hypotézy, ještě neověřené:
- `SoLoud.loadUrl` stahuje celý soubor, než se vrátí.
- URL v logu obsahuje `/playlist/`, takže „progressive“ může být ve skutečnosti HLS, které SoLoud neumí.

Postup:
1. Změř na iPhonu čas `streamsFor`, `loadTrack` a zvolenou cestu (SoLoud nebo just_audio).
2. Oprav příčinu. V party DSP není potřeba, takže nejjednodušší varianta je hrát přes just_audio se streamem.
   Než to uděláš, ověř v `audio_engine.dart`, že `setCrossfadeGain` a `setSpeed` fungují i bez SoLoudu, kvůli Auto-DJ.
3. Dej do `_load` timeout ~15 s. Po něm `onFailed`, toast hostiteli a další skladba.

Hotovo, když první skladba hraje do ~5 s na reálném iPhonu a mrtvý stream se přeskočí do ~15 s.

### 4. Bug č. 2: emit po zavření cubitu (P2)

`_advance` pokračuje po `await` i po `end()`. Oprava podle handoffu 02: příznak `_disposed` v `PartyPlayer`
a `if (isClosed) return;` v `_onStarted`, `_onFailed`, `_takeNext` v `PartyCubit`. Přidej unit test s `Completer`.
Pozor: `end()` volá `stop()`, po kterém může následovat nová party, takže příznak musí jít při startu resetovat.

### 5. Bug č. 3: dva decky přetékají na telefonu (P3)

`lib/features/deck/deck_screen.dart:50-51` a řádek přehrávání v `deck_widget.dart` (~ř. 406, `Spacer`).
Nesouvisí s party. Doporučení z handoffu 02: `LayoutBuilder`, pod ~600 pt jeden deck na šířku.

## Ověření před party

`flutter analyze` a `flutter test` musí být čisté. Pak na reálném iPhonu:

1. Založ party, otevři QR na druhém telefonu mimo Wi-Fi hostitele.
2. Host navrhne skladbu a hlasuje, změna se objeví na obou stranách.
3. První skladba hraje do ~5 s.
4. Přeskočení, Auto-DJ crossfade, zamčený telefon (hraje dál na pozadí).
5. Výstup na Sonos přes AirPlay, včetně crossfadu.
6. Ukončení party během načítání skladby: bez výjimky a ticho.

## Relay

Nasazení: `services/djfy/deploy/deploy.sh` z Macu, stačí znovu spustit (tunel a DNS už existují).
Kontejnery `djfy-relay` a `djfy-cloudflared` na JODA v `~/deploy/DJfy/relay`.
Při změně relay ověř `go test -race ./...` ve `services/djfy`.
