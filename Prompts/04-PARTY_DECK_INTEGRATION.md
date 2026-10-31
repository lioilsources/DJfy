# 04 — Handoff: party hraje na decích, přechody bez závodů

> Handoff pro Claude Code (Opus). Výchozí stav: větev `fix/iphone-party-bugs` (PR #4),
> na ní jsou opravy z handoffu 03. Začni novou větví z ní, např. `feat/party-on-decks`.
> Každý bod níže = vlastní commit. Nejdřív reprodukuj (část 0), pak oprav.
>
> Co uživatel vidí na iPhonu: **v party se zobrazuje jiná skladba, než hraje**,
> **tlačítko Next se nechová podle očekávání** a **party je oddělená od decků** –
> chce, aby se právě hrající skladba točila na prvním decku.

## Jak to dnes funguje (a proč je to špatně)

`PartyPlayer` (`lib/features/party/party_player.dart`) hraje na skrytých enginových
decích **201/202**. Decky v UI (`DeckCubit` 1–6) o party nic nevědí. Party obrazovka
(`party_screen.dart`) má vlastní „Teď hraje“ kartu a progress bar. Zvuk a UI se tak
drží pohromadě jen přes callbacky `onStarted`/`onNeedNext`, a ty se volají v jiných
okamžicích, než se mění zvuk. Odtud všechny tři stížnosti.

## Nalezené chyby (ověřeno v kódu, na zařízení nereprodukováno)

Řazeno podle toho, jak přímo vysvětlují, co uživatel vidí.

### A. Zobrazená ≠ hrající skladba

1. **`playNow` nekontroluje `_transitioning`** (`party_player.dart:73`). Když hostitel
   zvolí „Hrát hned“ během automatického přechodu (`_advance` zrovna načítá další
   skladbu), běží dva loady **na tentýž `_idle` deck**. `AudioEngine._loadViaJustAudio`
   dělá `stop()` + `setAudioSource()` na stejném playeru, takže jeden load přepíše
   druhý. Oba pak zavolají `_swapTo` → `onStarted`. Pořadí není dané: UI může
   skončit na skladbě N, zatímco deck hraje P. Navíc `finally` v `playNow` shodí
   `_transitioning` na `false`, i když `_advance` ještě běží.
2. **Auto-DJ: `_swapTo` se volá na začátku crossfadu** (`_mix`, řádek ~200).
   `nowPlaying` (host UI, snapshot pro hosty, progress bar) ukazuje příchozí skladbu
   8 s dřív, než ji je slyšet. Hosté i hostitel vidí „hraje B“, zatímco slyší A.
3. **`_takeNext` mutuje frontu před načtením** (`party_cubit.dart:311`): odebere
   entry, zavolá `_pushHistory()` a nastaví `_nextEntry` **před** `_load`. Když load
   selže (timeout 15 s, mrtvý stream), smyčka v `_advance` zavolá `_takeNext` znovu:
   `_pushHistory()` přidá tutéž skladbu do historie **podruhé** (rozbije artist
   cooldown), ztracená skladba z fronty tiše zmizí a `_nextEntry` se přepíše.
   Uživatel vidí: „skladba zmizela z fronty, hraje jiná, toast říkal něco třetího“.
4. **`PartyState.copyWith` neumí vynulovat `nowPlaying` ani `nowPlayingEntry`**
   (`party_state.dart:78-79`). Když `_onStarted` nenajde odpovídající entry, zůstane
   předchozí → karta ukazuje „přidal(a) X“ od minulé skladby. A po `_advance(force)`
   s prázdnou frontou zůstane `nowPlaying` nastavené, přestože nic nehraje.
5. **`_NowPlayingCard.buildWhen` ignoruje `nowPlayingEntry`** (`party_screen.dart:228`)
   → „přidal(a)“ se nepřekreslí, dokud se nezmění něco jiného.

### B. Next (skip)

6. **Next je během Auto-DJ přechodu mrtvé 8–18 s.** `_mix` drží `_transitioning`
   po celý crossfade (8 s) **a navíc po celý glide tempa** (20 × 500 ms = 10 s,
   řádek ~221). `_advance` začíná `if (_transitioning) return;` (řádek 161), takže
   stisk Next se tiše zahodí. Žádná zpětná vazba v UI.
7. **Next při zapnutém Auto-DJ = plný 8 s crossfade**, ne střih. Uživatel čeká
   okamžitou reakci.
8. **Next během načítání se zahodí** (stejný guard). Druhý stisk = nic. Mělo by
   zrušit běžící load a začít nový.
9. **Přechod se spouští příliš pozdě.** `_poll` volá `_advance()` až při
   `remaining <= crossfade` (8 s) resp. 300 ms, a teprve *pak* se resolvuje stream a
   načítá (3–10 s). Výsledek: bez Auto-DJ několikasekundová mezera (žádný „gapless“),
   s Auto-DJ začne crossfade, až když odcházející skladba dohrála → fade z ticha.
   Chybí **preload** další skladby.
10. **Prázdná fronta na konci skladby:** `_advance()` bez `force` jen vrátí, `_playing`
    zůstane `true`, `_poll` volá `_advance` každých 250 ms a `_takeNext` emituje
    `isPlaying:false` 4×/s (spam stavů). Play na dohraném just_audio playeru bez
    `seek(0)` nic neudělá.
11. **`togglePlay` emituje `isPlaying` hned po `skip()`**, kdy je `_playing` při
    pomalém loadu ještě `false` → ikona skočí na ▶ a po `_onStarted` zpět. Kosmetické,
    ale přispívá k dojmu „tlačítko nefunguje“.

### C. Oddělení od decků

12. Party hraje na 201/202; `DeckScreen` zobrazuje jen decky 1–6. Žádný vinyl, jog,
    seek ani crossfader party neodráží. `MixerCubit` řídí crossfade decků 1/2, party
    má vlastní `setCrossfadeGain` na 201/202.
13. `DeckCubit` vznikají v `GridView.builder` (`deck_screen.dart:64`) a
    `DeckCubit.close()` volá `_engine.dispose(deckId)` (`deck_cubit.dart:348`).
    Jakmile party pojede na decích 1/2, musí být cubity app-level, jinak odscrollování
    nebo zavření decku zabije zvuk party.

## Cílový návrh

**Party hraje na decích 1 a 2.** Zvuk, vinyl, progress a crossfader mají jeden zdroj
pravdy: engine deck → `DeckCubit` stav. Party vrstva (fronta, hlasy, snapshot) se na
něj jen dívá.

- **Role decků:** A/B se střídají (jako dnes), ale UI je řadí **hrající první** a
  označí je `PARTY · LIVE` / `PARTY · NEXT`. Tím se splní „hrající skladba se točí na
  prvním decku“ bez přenášení zvuku mezi decky. Při party nelze na tyto decky
  přetáhnout jiný track ani je zavřít (zámek), ostatní decky 3–6 zůstávají volné.
- **Streamování přes just_audio** (bez DSP) zůstává výchozí pro party: start do pár
  sekund i na špatné síti. `DeckWidget` už umí `hasDsp=false` (EQ/FX šedé). Vinyl,
  jog, seek, speed, volume a crossfader fungují. SoLoud s preloadem jako volitelný
  „DJ režim“ nechat na později (pozn. v závěru).
- **Crossfader je skutečný.** `_mix` hýbe `MixerCubit.setCrossfade(x)` (slider se
  pohybuje), střih nastaví crossfader na druhou stranu okamžitě. Přímé
  `setCrossfadeGain` z `PartyPlayer` zmizí.
- **Jedna fronta přechodů s rušením.** `skip`, `playNow` i auto-advance jdou přes
  jediný serializovaný `_transition(...)`; uživatelská akce **zruší** rozběhlý
  přechod (generation token, který už máš jako `_session` – rozšířit na per-transition),
  nikdy se tiše nezahodí.
- **Preload.** Po startu skladby (nebo při `remaining <= 45 s`) se top entry fronty
  resolvuje a načte na idle deck. Před přechodem se ověří, že je to stále top entry
  (fronta se mění hlasy/vetem); jinak se přenačte. Přechod začíná přesně při
  `remaining <= crossfade`.
- **Konec skladby z `processingState == completed`** just_audio playeru, ne z
  heuristiky „8 ticků bez pohybu“. `_poll` zrušit; pozice/délka z deck streamů.
- **`nowPlaying` se přepne, až když je příchozí deck dominantní** (crossfade ≥ 50 %,
  u střihu ihned). Během přechodu má stav `transition: (from, to, progress)`, UI může
  ukázat „A → B“.
- **Next = rychlý střih** (~1 s equal-power fade v obou režimech; při pauze okamžitě).
  Během načítání ukazuje deck „načítám…“, Next má spinner, a druhý stisk zruší a
  přeskočí dál.

## Postup (každý bod = commit)

### 0. Reprodukce a logy (nejdřív!)
- `flutter run --profile -d <iPhone>` s `--dart-define` klíči, filtr `[Party]`.
- Dočasně zaloguj: `_takeNext` (co odebral, délku fronty), `_load` (deck, track,
  session), `_swapTo` (deck, track), `onStarted`, `playNow`, `skip`, vstup/výstup
  `_advance` s `force`, `_transitioning` při odmítnutí. Zjisti, který z bodů A1–A3 /
  B6–B9 uživatel potkal; výsledek zapiš do commit message prvního fixu.

### 1. Decky app-level
- `DeckRegistry` (nebo `DecksCubit`) nad `AudioEngine`: vlastní `DeckCubit` 1–6
  (lazy), žije vedle `PartyCubit` v `MultiBlocProvider` v `app.dart`. `DeckScreen`
  si cubity bere z registru, neřeší jejich životní cyklus. Zavření decku uživatelem
  = `registry.release(id)` (dispose), ne `BlocProvider` dispose.
- `MixerCubit` app-level, stejně.
- `DeckCubit`: nový stav/flag `lockedBy: 'party'` → `DragTarget` odmítá, `onClose`
  skrytý, header ukazuje štítek. `DeckCubit.loadTrack(track, {bool streaming})`:
  `streaming: true` přeskočí `resolveProgressiveUrl` a jde přes just_audio;
  vrátí `Future<void>`, chybu propaguje (pro `_load` v party).

### 2. `PartyPlayer` na decích 1/2
- `deckA = 1`, `deckB = 2`; při `start` party registry zajistí oba decky,
  `DeckScreen` zobrazí dva (pokud byl jeden). Při `end` zámek pryč, decky zůstanou
  načtené (hostitel může dohrát ručně).
- Load přes `DeckCubit.loadTrack(streaming: true)`, přehrání přes `DeckCubit`
  (`togglePlayPause`/engine), pozice z `DeckCubit.stream`. Konec skladby z
  `playerStateStream` (`processingState == completed`).
- Crossfade přes `MixerCubit.setCrossfade`; `PartyPlayer` dostane mixer v konstruktoru.
- `PartyPlayer` přestane být vlastníkem `_progress` streamu – party UI čte
  aktivní `DeckCubit`.

### 3. Přechody
- Jediný `_transition(...)` s per-transition `CancelToken`/generací. `skip` a
  `playNow` ruší běžící přechod (včetně probíhajícího `_mix`: dokončí střihem).
- `_takeNext` → `_peekNext()` (nemutuje). Commit (odebrat z fronty, `_pushHistory`,
  `nowPlayingEntry`) teprve při přepnutí `nowPlaying`. Selhání loadu: entry zůstane
  ve frontě s `failed: true`/důvodem (šedá, host ji může vetovat) nebo se odebere
  s toastem – jedno z toho, ale deterministicky a bez duplicitní historie.
- `_mix`: glide tempa jako samostatný rušitelný task mimo `_transitioning`.
  `nowPlaying` přepnout v polovině fadu.
- Preload idle decku + re-validace před přechodem.
- `PartyState`: `clearNowPlaying`, `transition`, `loadingNext: bool`.
  `isPlaying` odvozovat z aktivního decku (jeden listener v cubitu), ne z
  `_player._playing`.
- Prázdná fronta: jedno `emit(isPlaying:false)` + pauza, `_poll` spam pryč.
  Play po dohrání = další skladba (ne `play()` na completed playeru).

### 4. UI
- `DeckScreen`: v party režimu řadí `[live, next, ...ostatní]`, štítky
  `PARTY · LIVE` / `NEXT`, zámek. Domovská obrazovka při živé party ukáže kompaktní
  lištu (fronta: N, Next, vstup do party obrazovky), aby hostitel nemusel přepínat
  kvůli jednomu tlačítku.
- `PartyScreen` `_NowPlayingCard`: `buildWhen` zahrne `nowPlayingEntry` a
  `transition`; během přechodu „A → B“; Next se spinnerem při `loadingNext`.
- Guest snapshot (`buildSnapshot`): `nowPlaying` se mění až s přepnutím (bod 3),
  `positionMs/durationMs` z aktivního decku. PWA (`services/djfy/web/app.js`)
  nemění formát, jen ověř, že `isPlaying` sedí.

### 5. Testy (`flutter test` čistý, `flutter analyze` čistý)
- `party_player_test.dart` (fake engine/deck s `Completer`):
  - skip během loadu zruší starý load a hraje nový; zobrazená == hrající;
  - `playNow` během auto-advance: finální `nowPlaying` == deck, který hraje;
  - selhaný load: historie bez duplicit, fronta deterministická;
  - Auto-DJ: `nowPlaying` se přepne v polovině fadu; skip během fadu skončí do ~1 s;
  - preload načte top entry a po změně fronty se přenačte;
  - prázdná fronta: jediný emit `isPlaying:false`.
- `deck_cubit_test.dart`: `lockedBy`, `loadTrack(streaming: true)`, externí
  přepnutí stavů.
- Widget test `DeckScreen` v party režimu (řazení, štítky, žádný overflow na
  iPhone mini – navazuje na `deck_layout_test.dart`).

### 6. Ověření na iPhonu (stejně jako handoff 03, část „Ověření před party“)
1. Party, QR na druhém telefonu mimo Wi-Fi. 2. Návrh + hlas z hosta.
3. První skladba hraje do ~5 s a **točí se na prvním decku**, karta i deck ukazují
   totéž. 4. Next → střih do 1 s, i opakovaně, i během Auto-DJ fadu.
5. Auto-DJ: crossfader na obrazovce jede, `nowPlaying` se přepne uprostřed, hosté
   vidí stejnou skladbu. 6. „Hrát hned“ během přechodu → bez nesouladu.
7. Zamčený telefon, AirPlay na Sonos. 8. Ukončení během načítání → ticho, decky
   odemčené.

## Poznámky a rozhodnutí k potvrzení s uživatelem

- **DSP pro party (SoLoud) ne teď.** SoLoud stahuje celý MP3 před prvním vzorkem;
  s preloadem by to na druhou a další skladbu stačilo, první by čekala na stažení
  (~4 MB; na špatné síti 10–30 s). Navrhuju přepínač „DJ režim (EQ/FX, stahuje
  skladby)“ jako navazující práci, výchozí zůstane streaming.
- **Střídání A/B vs. „hraje vždy deck 1“.** Přenést zvuk z decku 2 na deck 1 bez
  výpadku nejde; řazení „hrající první“ dává stejný vizuální výsledek. Pokud by
  uživatel trval na pevném čísle, alternativa je přejmenovat decky v party režimu na
  `LIVE`/`NEXT` místo čísel.
- **Co s rozjetou manuální skladbou na decku 1/2 při startu party?** Návrh: party ji
  nechá dohrát jako „current“ (přidá ji do `nowPlaying`), první skladba fronty se
  načte na druhý deck. Jednodušší varianta: při startu party decky 1/2 zastavit.
  Zvolit a napsat do commit message.
