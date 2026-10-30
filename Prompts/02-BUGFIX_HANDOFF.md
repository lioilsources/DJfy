# 02 — Bugfix handoff: chyby nalezené při focení store screenshotů

> Handoff pro Claude Code. Chyby se ukázaly při běhu `tool/store_screenshots.sh`
> (iOS simulátor „DJfy-Shots-iPhone", iOS 27.1, Xcode 27.1, lokální relay, 4 hosté).
> Každá chyba má reprodukci, podezření, návrh opravy a kritérium hotovo.
> Pořadí = priorita. Každou chybu řeš ve vlastním commitu.

## Jak reprodukovat

```sh
cd ~/Dev/GitHub/DJfy-shots            # větev chore/store-screenshots
LOG=/tmp/djfy-host.log SHOOT=../ol1n.now/scripts/shoot.mjs tool/store_screenshots.sh /tmp/djfy-shots
```

Plný výstup testu je v `$LOG`. Celý běh trvá ~15 min, z toho ~8 min je chyba č. 1.
Na rychlé ověření stačí integrační test bez skriptu (hosté nejsou potřeba pro č. 1 a č. 3).

---

## 1. Start párty visí ~8 minut (P1)

**Příznak.** `PartyCubit.togglePlay()` → `PartyPlayer.skip()` → `_advance()` → `_load()`
se vrátí až po 8 min 17 s (změřeno: přidání 4 skladeb 13:44:50, přehrávání 13:53:07).
Ruční deck (`DeckCubit.loadTrack`) stejnou dobu nečeká: `[Deck 1] load OK, hasDsp=false`
do pár sekund. Hosté mezitím vidí párty bez „Teď hraje".

**Podezření (ověřit, ne předpokládat).**
- `SoundCloudService.streamsFor()` vrací `progressive`, a pak `AudioEngine.loadTrack()`
  jde přes `_loadViaSoLoud()` → `SoLoud.instance.loadUrl(url)`, které stahuje **celý
  soubor** předtím, než vrátí. V logu je u party decku `resolved CDN url: …/playlist/…128.mp…`;
  zkontroluj, jestli to „progressive" URL není ve skutečnosti HLS playlist (`.m3u8`),
  na kterém SoLoud visí až do timeoutu.
- `_advance()` zkouší až 3 skladby za sebou; pokud každý pokus visí na síťovém timeoutu,
  sčítá se to.
- Nikde na téhle cestě není timeout (`_load`, `loadTrack`, `loadUrl`).

**Postup.**
1. Přidej `debugPrint` s časem kolem `streamsFor`, `loadTrack` a zvolené cesty
   (SoLoud vs just_audio) v `PartyPlayer._load` a zjisti, co přesně trvá.
2. Oprav příčinu (např. neposílat HLS do SoLoudu, rozpoznat `.m3u8` v `resolveProgressiveUrl`).
3. Přidej pojistku: `_load` s `timeout` (~15 s); při překročení `onFailed` a další skladba.
   Hostitel má dostat toast, ne ticho.
4. Ověř na **reálném iPhonu**, nejen v simulátoru. Simulátor může být pomalejší.

**Hotovo, když** první skladba párty hraje do ~5 s od `togglePlay()`, mrtvý stream
se přeskočí do ~15 s, a `integration_test/store_screenshots_test.dart` už nepotřebuje
25min timeout (vrať ho na 10 min a smaž komentář „first stream can take minutes").

---

## 2. Emit po zavření `PartyCubit` (P2)

**Příznak.** Po `party.end()` / zavření obrazovky spadne:

```
Bad state: Cannot emit new states after calling close
#0 BlocBase.emit
#1 PartyCubit._onStarted        (party_cubit.dart:332)
#2 PartyPlayer._swapTo          (party_player.dart:120)
#3 PartyPlayer._advance         (party_player.dart:161)
```

**Příčina.** `_advance()` je async; během `await _load(...)` párty skončí
(`end()` → `_teardown()` / `close()` → `_player.dispose()`), ale rozběhnutý `_advance`
po návratu z `await` pokračuje, zavolá `_swapTo` → `onStarted` → `emit` na zavřeném cubitu.
Stejně mohou dopadnout `onFailed` a `_takeNext` (`onNeedNext`).

**Oprava.**
- `PartyPlayer`: příznak `_disposed`, nastavený v `stop()`/`dispose()`; po každém `await`
  v `_advance`, `playNow`, `_mix` zkontroluj a skonči. Dispose zároveň zastaví
  právě načítaný deck, ať nezačne hrát po skončení párty.
- `PartyCubit`: v callbackách (`_onStarted`, `_onFailed`, `_takeNext`) `if (isClosed) return;`
  jako druhá pojistka.

**Hotovo, když** unit test (fake `AudioEngine`, `loadTrack` čeká na `Completer`) projde:
spustí `togglePlay()`, zavolá `end()`, dokončí `Completer` → žádná výjimka, nic nehraje.
Integrační test skončí bez „EXCEPTION CAUGHT … after the test had completed".

---

## 3. Dva decky vedle sebe přetékají na telefonu na výšku (P3)

**Příznak.** Po „PŘIDAT DECK" na iPhonu (šířka ~440 pt) je v debug buildu žlutočerný pruh:
`RIGHT OVERFLOWED BY 34 PIXELS` v řádku přehrávání a `BOTTOM OVERFLOWED BY 2.0 PIXELS`
dole v decku. V release buildu se obsah tiše ořízne (čas `00:00 / 03:0…`).

**Kde.** `lib/features/deck/deck_screen.dart`: `GridView` s
`crossAxisCount: _deckIds.length <= 1 ? 1 : 2` a pevným `childAspectRatio` (0.75 / 0.7),
bez ohledu na šířku. Řádek přehrávání v `deck_widget.dart` (~ř. 361–410): rewind + play 40 px
+ forward + `Spacer` + text času; pod ~200 pt šířky decku se nevejde.

**Možnosti (vyber jednu a zdůvodni v commitu).**
- a) `LayoutBuilder` v `DeckScreen`: na úzké šířce (< ~600 pt) decky pod sebou
  (`crossAxisCount: 1`), na tabletu/macOS dva vedle sebe.
- b) Kompaktní varianta decku pod určitou šířkou: čas pod tlačítky, menší vinyl,
  `FittedBox` / `Flexible` místo `Spacer` u textu času.
- c) `childAspectRatio` počítat z dostupné výšky, ne konstantou. Řeší jen spodní 2 px.

Doporučení: **a)** + pro jistotu `Flexible`/`overflow: TextOverflow.fade` u času.

**Hotovo, když** widget test s `tester.view.physicalSize` = iPhone (1206×2622 @3x)
i iPhone mini (1080×2340 @3x) a dvěma až šesti decky nehlásí overflow, a na macOS
zůstanou dva decky vedle sebe.

---

## Po opravách

- Store screenshot `02-decks` lze vrátit na dva decky + crossfader
  (`integration_test/store_screenshots_test.dart`, sekce „One deck…").
- Pustit `tool/store_screenshots.sh`, nové screenshoty zkopírovat do
  `ol1n.now/apps/djfy/screenshots/raw/mobile/ios/` (stejná jména) a nasadit.
- `flutter analyze` a `flutter test` čisté; `dart format -l 120`.
