# 05 — Handoff: nativní scratch deck a dokončení FX ve stylu Pacemaker

> Handoff pro Claude Code (Opus). Výchozí stav: `main` po PR #6 (v1.3.0, party hraje
> na decích 1/2, nekončící party). Začni novou větví z `main`, např. `feat/scratch-deck`.
> Každý očíslovaný krok v části 6 = vlastní commit (nebo PR, kde je to řečeno).
> Nejdřív udělej spike v části 2 – rozhoduje, kterou cestou půjde zvuk.
>
> Co uživatel chce: deck má být **skutečný gramofon** (talíř se točí, dotyk ho zastaví,
> tažení scratchuje dopředu i dozadu, po puštění se roztočí jako motor), ne jen
> „zobrazovač odehraného času“. A **FX pad má dojít do stavu Pacemakeru**: efekt na
> každém decku včetně party, echo s dozvukem, roll bez cvaknutí, pad nad talířem.

## 1. Jak deck při přehrávání funguje dnes (ověřeno v kódu)

Soubory: `lib/features/deck/deck_widget.dart`, `vinyl_painter.dart`, `deck_cubit.dart`,
`lib/services/audio_engine.dart`, `lib/core/beat_clock.dart`, `lib/features/deck/fx_pad.dart`.

### Talíř je zobrazovač průběhu

- `VinylPainter(progressFraction)` kreslí statické drážky, **oblouk průběhu** a jednu
  tečku na úhlu `2π·progress`. Talíř tedy udělá **jednu otáčku za celou skladbu**,
  ne 33⅓ ot./min. Při pauze tečka zmizí. Nic se netočí „jako gramofon“.
- Překresluje se jen při změně pozice: SoLoud pozice se **polluje po 200 ms**
  (`AudioEngine._startPositionPolling`), just_audio posílá pozici také zhruba po 200 ms.
  Mezi polly stojí. `BeatClock.estimatedPosition` sice extrapoluje, ale UI ho nepoužívá.
- Pozice z `positionSync` je u just_audio jen cache posledního pollu.

### „Scratch“ je sled seeků

`_JogWheel` (deck_widget.dart:272) počítá úhel prstu kolem středu a volá
`DeckCubit.jogStart/jogBy/jogEnd`:

- `jogBy` přičítá úhel k cílové pozici (1 otáčka = 1,8 s, správně 33⅓ rpm) a každých
  **33 ms** volá `engine.seekTo`. Zvuk tedy **dál hraje normální rychlostí** a jen
  skáče – slyšitelné cvakání, žádná změna výšky tónu, žádné zpomalení.
- Dotyk **nezastaví talíř** (není „vinyl mode“); směr dozadu je také jen skok;
  po puštění žádný rozjezd motoru. `GestureDetector.onPanStart` navíc přijde až po
  překonání prahu tažení (~18 px), takže pouhé položení prstu nic neudělá.
- Reverz není ani možný: SoLoud `setRelativePlaySpeed` vrací `INVALID_PARAMETER` pro
  `speed <= 0` (`src/soloud/src/core/soloud_core_voiceops.cpp:35` v balíčku
  `flutter_soloud-3.5.4`); just_audio záporné `setSpeed` také nepodporuje.
- Rychlost: slider 0,7–1,3× (`_Controls`), bez nudge/pitch bend, bez key locku.
- V party je jog povolený na obou decích (`enabled: config.track != null`); na
  `NEXT` decku seekuje přednačtenou skladbu – neškodné, ale nesmyslné.

### Dva enginy, DSP jen na jednom

- Progressive MP3 → `SoLoud.loadUrl` (stáhne celý soubor, timeout 10 s) → filtry
  (EQ, biquad, echo, freeverb, lofi) aktivované před `play()`. HLS nebo party
  (streaming) → just_audio, **bez DSP, bez FX, bez scratch**.
- `streamsFor()` už vrací `progressive` URL; party ji jen nepředává (`deck_cubit.dart:112`).

### FX pad dnes

Šest efektů (`lib/models/fx.dart`): HI-LO (biquad LP/HP s mrtvou zónou), ECHO
(delay 1/4–1 beat, buffer pevně 1 s), REVERB, 8-BIT (lofi, bitdepth pevně 5), ROLL
(Dart `Timer` + `seekTo` na kotvu), BEATSKIP (seek o ±1/2/4 beaty). Efekt zní jen
při držení prstu (momentary), `fxUpdate` throttlovaný na 16 ms, engage fade 40 ms.

Co chybí nebo nesedí proti Pacemakeru:

1. **FX jen na DSP decku** – párty skladby nemají nic, HI-LO/ECHO na nich nejde.
2. **Echo po puštění utne dozvuk**: `clearFx` fadeuje `wet` na 0 za 50 ms.
   Pacemaker nechá ozvěnu doznít.
3. **Roll cvaká a plave**: seek na kotvu bez crossfadu + jitter Dart timeru (jednotky
   ms); při 1/16 (≈ 30 ms při 128 BPM) je to slyšet. Beat grid je ukotvený v čase 0
   (`BeatClock.quantizeToBeat`), skladba s předtaktem rolluje mimo beat.
4. **Pad vytlačí talíř** (`_showFx` přepíná `_VinylArea` ↔ `FxSection`): nelze
   scratchovat a držet efekt současně, ani vidět, kde skladba je.
5. **Bez latch** (držení efektu bez prstu) a bez beat-kvantizovaného zapnutí.
6. **8-BIT má pevný bitdepth**, Y osa jen mix; Pacemaker „Crush“ mění oba parametry.
7. Chybí efekty, které gramofonová fyzika dává zadarmo: **Brake** (dojezd talíře),
   **Spin/Backspin**; a beat-synchronní **Loop** (in/out 1–8 beatů).
8. Roll a Beatskip nemají testy (timery), existují jen testy `FxParamMapper` a
   `BeatClock`.

## 2. Spike (krok 0, max. 1 den) – rozhoduje o architektuře zvuku

Cíl: zjistit, zda jde dělat skutečný scratch (reverz, variabilní rychlost, bez
cvakání) v Dartu nad SoLoud `BufferStream`, nebo je potřeba nativní kód.

Ověřeno v `flutter_soloud-3.5.4` (`lib/src/soloud.dart`):

- `setBufferStream({sampleRate, channels, format: f32le|s16le, bufferingTimeNeeds,
  bufferingType: preserved|released, maxBufferSizeBytes})` + `addAudioDataStream(source,
  Uint8List)` + `getBufferSize(source)`. Na zdroj jdou stejné filtry jako dnes
  (`source.filters.*`), takže FX zůstanou.
- Pozor: s `BufferingType.released` je `getPosition` vždy 0 – pozici musí držet náš
  playhead (což chceme tak jako tak, zbavíme se 200 ms pollu).
- `readSamplesFromMem(bytes, numSamplesNeeded, {startTime, endTime, average})` je
  `@experimental` a stavěné na waveform (redukuje počet vzorků). **Ověř**, zda
  s `numSamplesNeeded == počet framů` vrátí PCM v plné kvalitě a zda stereo, nebo
  mix do mono. Když ne, dekódovat MP3 jinak (viz níže).
- `fadeRelativePlaySpeed(handle, to, time)` existuje – hodí se pro variantu A.

Měř na **iPhone 12 mini a Pixel 8a** (ne v simulátoru):

1. **Latence BufferStream**: vytvoř stream f32le 44,1 kHz stereo, z Dartu posílej
   bloky po 256–512 framech, hledej nejmenší `bufferingTimeNeeds` + předstih bez
   výpadků (sleduj `getBufferSize` a `onBuffering`). Zapiš dosaženou latenci
   dotyk→zvuk (odhad: předstih + `bufferingTimeNeeds` + výstupní buffer zařízení).
   Cíl < 60 ms. Změř i s Dart producentem v samostatném `Isolate`.
2. **PCM dekódování**: 6minutová skladba stereo 44,1 kHz jako `Int16List` = 63 MB,
   `Float32List` = 127 MB. Změř čas dekódování a paměť. Varianty: a) `readSamplesFromMem`
   (viz výše), b) `loadMem` + čtení přes `readSamplesFromFile` z temp souboru,
   c) vlastní FFI binding na `dr_mp3`/miniaudio – zdrojáky jsou už v balíčku
   (`src/soloud/...`), ale nejde je volat bez forku; samostatný C soubor přibalený
   k appce (CMake + CocoaPods, `ffigen`) je schůdnější.
3. **Filtry na BufferStream**: aktivuj echo a biquad na stream source a ověř, že
   `wet(soundHandle:)` reaguje stejně jako dnes.

Rozhodnutí podle výsledku:

| Výsledek spiku | Cesta |
|---|---|
| latence < 60 ms, PCM dekódování OK | **B – Dart `ScratchVoice` nad BufferStream** (cílová) |
| latence 60–120 ms | B pro scratch v Dartu je použitelná jen „na hraní“; udělej **C-lite**: resampler v jednom C++ souboru (FFI), který plní BufferStream přímo z nativního vlákna. Dart posílá jen rychlost a cíl. |
| BufferStream nestabilní | **A – jen rychlost** (`setRelativePlaySpeed` 0,05–4×, reverz nahraď seekem), talíř a gesta podle části 3 zůstávají |

Část 3 (model talíře, gesta, UI) je stejná pro všechny tři cesty – začni jí, než
dojde spike, a cestu zapoj až pod ni.

## 3. Cílový návrh: deck jako gramofon

### 3.1 `lib/core/platter.dart` – čistě dartový model, s testy

```dart
enum PlatterMode { motor, touched, braking, spinningUp }

class Platter {
  static const rpm = 100 / 3;                 // 33⅓
  static const nominalRadPerSec = 2 * pi * rpm / 60;   // ≈ 3.49 rad/s
  static const secondsPerRevolution = 1.8;    // = DeckCubit.jogSecondsPerRevolution

  double angle;            // rad, pro vykreslení
  double angularVelocity;  // rad/s, signed
  PlatterMode mode;
  double speed;            // nastavení slideru (0.7–1.3), násobí nominal

  double get rate => angularVelocity / nominalRadPerSec;  // signed, 1.0 = normální

  void tick(Duration dt);                 // motor: ω → speed·nominal, exponenciálně (τ ≈ 150–300 ms)
  void touch();                           // mode = touched, ω = 0 (vinyl mode)
  void drag(double deltaAngle, Duration dt); // ω z průměru posledních ~3 událostí (low-pass)
  void release();                         // spinningUp → motor
  void brake(Duration time);              // braking: ω → 0 za `time`, pak pause
  void nudge(double ratio, Duration dt);  // pitch bend ±4–8 % po dobu držení
}
```

- Tick 60 Hz přes `Ticker` ve widgetu (vsync); výstup `rate` jde do enginu, `angle`
  do `VinylPainter`. Mezi ticky engine nic nedostává – rychlost drží poslední hodnotu.
- Slip mode (volitelně, přepínač): při dotyku si pamatuj „kde by skladba byla“ a po
  puštění se vrať tam (jako `_stopRoll` dělá dnes pro roll).
- Testy: motor dojede na nominal; dotyk zastaví; drag udává ω podle úhlu/čas; release
  se vrátí na nominal za τ; brake za zadaný čas; rate je záporný při tažení zpět.

### 3.2 Gesta

- Nahraď `GestureDetector` za `Listener` (`onPointerDown/Move/Up/Cancel`): bez prahu,
  dotyk zastaví talíř okamžitě. Druhý prst ignoruj (jen první `pointer` id).
- Úhel počítej jako dnes (`atan2`, unwrap ±π). Časové razítko z `PointerEvent.timeStamp`.
- Tap bez pohybu < 150 ms = stop/start (jako u gramofonu „stop“ tlačítko)? Ne –
  ponech tlačítko Play; tap pouze zastaví a release roztočí.
- V party: scratch na `PARTY · LIVE` decku povolen, na `NEXT` zakázán (role už je
  v `DeckConfig.partyRole`).

### 3.3 Vykreslení

- `VinylPainter` dostane `angle` (rotace drážek, labelu a jednoho „markeru“ na okraji)
  a dál `progressFraction` pro oblouk. Repaint při každém ticku jen tohoto painteru
  (`RepaintBoundary` kolem talíře, nespouštět rebuild celého `DeckWidget`).
- Pod talíř **waveform strip**: peaky z PCM (1 sloupec ≈ 50 ms), beat grid ticky z
  `BeatClock` (po doplnění offsetu, část 5.3), playhead uprostřed, tažením scrub.
  Nahrazuje nebo doplňuje `_SeekSlider`. Bez PCM (just_audio) zůstane slider.
- Pitch bend tlačítka `−`/`+` vedle rychlosti (držení = nudge), tlačítko Brake.

### 3.4 Engine API (`AudioEngine`)

```dart
/// Signed rychlost přehrávání; 1.0 = normálně, 0 = stojí, < 0 = pozpátku.
void setRate(int deckId, double rate);
bool get scratchable(int deckId);   // PCM playhead k dispozici
Stream<Duration> positionStream(int deckId);  // u PCM decku 60 Hz z playheadu
```

- Cesta A: `rate` ořezat na 0,05–4; `rate <= 0` → `setPause(true)`, reverz nahradit
  seekem po 33 ms jako dnes (talíř se točí správně, zvuk couvá skokově).
- Cesta B/C: `ScratchVoice` (viz 4) dostane `rate`, hraje i normální přehrávání
  (jeden playhead → žádné přepínání mezi SoLoud voice a streamem).
- `DeckCubit`: `jogStart/jogBy/jogEnd` nahradit `platterTouch/platterDrag/platterRelease`
  a `setRate` z ticku; `BeatClock.anchor` z playheadu.

## 4. `ScratchVoice` (cesta B, případně C-lite)

`lib/services/scratch_voice.dart` (+ `scratch_producer.dart` v `Isolate`):

- **Vstup**: `Int16List` interleaved stereo 44,1 kHz (PCM z dekodéru; `Float32List`
  je 2× větší – nebrat). Načtení: progressive MP3 stáhnout Dio (máme; progres,
  zrušení přes `CancelToken`, limit velikosti), pak dekódovat podle výsledku spiku.
  Stejné bajty použij pro waveform. Pokud dekódování selže → dnešní `loadUrl`
  cesta (cesta A).
- **Playhead** `double frame` (ne `int`), `rate` signed. Každý blok (256–512 framů):
  pro každý výstupní frame čti vstup s lineární (později kubickou) interpolací,
  `frame += rate`; za hranicemi ticho. Při `|rate| < 0.01` posílej ticho (prst drží).
- **Roll/Loop sample-accurate**: `loopStart/loopEnd` ve framech, při přechodu 2 ms
  crossfade – nahradí Dart timer (část 5.2).
- **Volume gate** pro budoucí Gate FX (LFO na amplitudu v producentu).
- **Výstup**: `addAudioDataStream` na `setBufferStream(format: s16le, sampleRate: 44100,
  channels: stereo, bufferingTimeNeeds: <ze spiku>, bufferingType: released,
  maxBufferSizeDuration: ~2 s)`. Producent běží v `Isolate`, drží předstih
  `targetAhead` (ze spiku; začni na 60 ms) podle `getBufferSize`. Dart → isolate posílá
  jen příkazy (`rate`, `seek`, `loop`, `stop`), isolate → Dart posílá pozici 60 Hz.
- **Paměť**: PCM mód max. pro **2 decky** současně (126 MB); další decky cesta A.
  Uvolňuj při `eject`/`dispose`.
- **C-lite**: tentýž algoritmus v `native/scratch_voice.cpp`, vlákno plní
  BufferStream přes exportovanou C funkci; Dart posílá příkazy přes FFI. Dekódování
  tam přes `dr_mp3.h` (single header, public domain). Zapoj přes `ffigen` +
  `android/app/CMakeLists.txt` + `ios/Runner.podspec`/Xcode target.

## 5. FX – dokončení do stylu Pacemaker

### 5.1 FX na všech decích včetně party

- `DeckCubit.loadTrack(streaming: true)` předá `streams.progressive` do enginu (jediná
  změna řádku ~118) → party skladba hraje přes SoLoud/PCM = DSP, scratch i FX.
  HLS-only skladby zůstanou na just_audio bez FX (dnešní tooltip „DSP nedostupné“).
- Pozor na start party: `PartyPlayer.loadTimeout` 15 s; progressive stahování celé
  skladby může trvat déle než HLS start. Preload 45 s to kryje, u `Next` a první
  skladby zobraz progres a při překročení ~8 s spadni na HLS (dnešní fallback).

### 5.2 Roll a Loop bez cvaknutí

- Cesta B/C: `ScratchVoice.setLoop(start, end)`; `fxEnd` → `clearLoop` a skok na
  virtuální pozici (dnešní `_stopRoll` logika zůstane v cubitu).
- Cesta A: ponech timer, ale přidej na seek 5 ms fade `setVolume` 0→1 (`fadeVolume`),
  aby to necvakalo; jitter nevyřešíš.
- Nový efekt **LOOP** (`FxType.loop`): X = délka 1/2/4/8 beatů, tap = in na beatu,
  druhý tap = out, latch defaultně (viz 5.5).

### 5.3 Beat grid s offsetem

- `BeatClock.offset` (Duration): fáze prvního beatu. Z PCM detekuj onsety (energy
  flux po 10 ms oknech, autokorelace kolem známého BPM) a vyber fázi; bez PCM
  nabídni tlačítko **TAP** (klepnutí na beat nastaví offset na aktuální pozici).
- `quantizeToBeat` a `_skipBeats` počítají s offsetem. Test: při 120 BPM (beat 500 ms)
  a offsetu 120 ms leží grid na 0,12 / 0,62 / 1,12 / 1,62 s; pozice 1,30 s se
  kvantizuje na 1,12 s, pozice 1,40 s na 1,62 s.

### 5.4 Echo dozvuk

- `clearFx(echo)`: místo fade `wet` → 0 za 50 ms nech `wet` a fadeuj `decay` → 0
  přes `max(2 × delay, 600 ms)`, pak teprve `wet` → 0. Zní to jako dozvuk, ne střih.
- Delay buffer je pevný 1 s (nastavuje se při prvním audio callbacku): 1 beat při
  < 60 BPM ořezat (dnes `clamp(0.001, 1.0)` – ponech, zdokumentuj).

### 5.5 Pad nad talířem, latch

- `FxSection` ne jako náhrada `_VinylArea`, ale **překryv přes dolní polovinu talíře**
  (poloprůhledný, `Stack`) nebo bottom sheet přes celou kartu decku s talířem
  zmenšeným nahoře. Hlavní je: talíř viditelný, obě ruce mohou pracovat.
- **Latch**: dvojklep na padu = efekt drží s posledními x/y (ikona zámku), klep =
  pustit. `DeckConfig.fxLatched`. Roll latchnutý = loop.
- Volitelně kvantizace zapnutí na nejbližší beat (Pacemaker „sync“): zapínej efekt
  až na hranici beatu z `BeatClock`, přepínač v nastavení.

### 5.6 Parametry a nové efekty

- 8-BIT → **CRUSH**: X samplerate (dnes), Y bitdepth 2–8 (lofi `bitdepth`), mix pevně 1.
- **BRAKE**: X = délka dojezdu 0,25–2 s (`Platter.brake`), po dojezdu pauza; pustit =
  roztočit. **SPIN**: Y nahoru = backspin (ω záporné, dojezd).
- Kandidáti ze SoLoud filtrů (ověř zvuk): `flangerFilter` (FLANGER: X delay, Y wet),
  `bassboostFilter`. **GATE** (trance gate 1/4–1/16 beatu) jen na cestě B/C
  (volume LFO v producentu).
- Nepřidávej víc než 2–3 nové efekty, dokud nejsou staré bez chyb.

### 5.7 Testy

- `platter_test.dart` (část 3.1), `scratch_voice_test.dart` (čistě dartový
  resampler: rate 1 → kopie, rate −1 → pozpátku, rate 0,5 → interpolace, loop
  crossfade bez skoku), `beat_clock_test.dart` doplnit offset.
- `deck_cubit_test.dart`: dotyk → `setRate(0)`, release → rate roste k 1; v party na
  NEXT decku se gesta ignorují. `FakeAudioEngine` dostane `setRate` a `rates` log.
- Echo dozvuk a roll crossfade jen manuálně na zařízení (checklist).

## 6. Postup (každý bod = commit; PR po krocích 1, 3, 5)

0. **Spike** (část 2) – výsledky zapiš na konec tohoto souboru (čísla, zařízení,
   rozhodnutí A/B/C). Kód spiku do `tool/spike/`, ne do appky.
1. `Platter` model + testy; `VinylPainter` s úhlem; `Listener` gesta; `AudioEngine.setRate`
   cesta A; `DeckCubit` přepojený z jog na platter; party lock na NEXT. → PR #7
   „deck se točí a dá se zastavit“ – uživatel to může vyzkoušet i bez B.
2. `ScratchVoice` + producent (B nebo C-lite podle spiku), PCM načítání s Dio a
   fallbackem, pozice 60 Hz z playheadu, limit 2 PCM decky.
3. Waveform strip + beat offset (TAP + detekce) + nudge/brake tlačítka. → PR #8
4. FX: progressive do party (5.1), roll/loop sample-accurate (5.2), echo dozvuk (5.4).
5. FX: pad jako překryv + latch (5.5), CRUSH/BRAKE/SPIN, případně FLANGER (5.6). → PR #9
6. `CLAUDE.md`: sekce Audio – nový engine, dvě cesty, limity paměti; aktualizuj
   „never await just_audio play()“ pozn. zůstává.

Pravidla jako v minulých handoffech: nespouštěj `dart format` na existující soubory;
`flutter analyze` a `flutter test` čisté před každým commitem; žádné klíče do repa
(`.env` je gitignored); build na zařízení přes `flutter build ios --profile` +
`flutter install --profile -d 00008101-001175D90AA0001E` (iPhone 12 mini) a
`adb -s 46201JEKB03641 install -r build/app/outputs/flutter-apk/app-release.apk`
(Pixel 8a; `adb` je v `~/Library/Android/sdk/platform-tools/`).

## Stav implementace (2026-11-13)

Hotovo na větvi `feat/scratch-deck`: kroky 0–6. Odchylky od plánu:
- PR je jeden za celou větev (po commitech), ne tři – telefon nebyl k dispozici,
  takže mezikroky nešlo nechat vyzkoušet.
- Brake je dlouhý stisk Play i efekt BRAKE na padu; nudge −/+ jsou vedle pitch slideru;
  SLIP je přepínač na talíři.
- FX pad je pod zmenšeným talířem (sloupec), ne poloprůhledný překryv.
- FLANGER, GATE a kvantizované zapnutí efektu (5.5 „sync“) nejsou udělané.
- Paměťový limit: 4 PCM decky (ne 2), protože dnešní záloha `loadUrl` drží PCM
  jako float a bere víc.

## 7. Checklist na zařízení (pro uživatele)

- Talíř se točí při hraní (≈ 1 otáčka za 1,8 s), stojí při pauze.
- Položení prstu zastaví zvuk okamžitě (bez prahu), tažení dopředu/dozadu je slyšet
  jako scratch (výška tónu sleduje rychlost prstu), bez cvakání.
- Puštění: zvuk se roztočí do normální rychlosti do ~0,3 s, bez skoku v pozici.
- Nudge −/+ při držení mění tempo o pár procent a vrátí se.
- Brake: dojezd podle X, Play znovu roztočí.
- Roll 1/16 při 128 BPM drží beat a necvaká; po puštění skladba pokračuje na gridu.
- Echo po puštění doznívá, neutne se.
- V party: na LIVE decku jde scratch i HI-LO/ECHO, na NEXT decku nic.
- Dva decky v PCM módu + party nepadají na paměť (iPhone 12 mini, 4 GB RAM).
- AirPlay/Sonos: latence není pro scratch použitelná – jen informovat, ne řešit.

## 8. Rozhodnutí uživatele (2026-11-13, závazná)

1. **Vinyl mode je default**, slip mode jako přepínač.
2. **Hranice latence 60 ms**: když Dart cesta B na zařízení nedosáhne < 60 ms dotyk→zvuk, jde se na nativní C-lite.
3. **Scratch (kroky 1–3) před FX (4–5).**

### Původní otázky

1. Má se při scratch zvuk **mixovat se stojícím talířem** (vinyl mode, zvuk sleduje
   prst) – ano je default; nebo chceš i **slip mode** (po puštění skladba pokračuje,
   jako by scratch nebyl)? Navrhuji: vinyl default, slip jako přepínač.
2. Je **~100 ms latence** přijatelná pro první verzi (cesta B v Dartu), nebo rovnou
   nativní C-lite, pokud spike ukáže > 60 ms? Navrhuji: podle spiku, hranice 60 ms.
3. Priorita: scratch (kroky 1–3) před FX (4–5)? Navrhuji ano.

---

### Výsledky spiku (2026-11-13, Opus)

Telefony nebyly k dispozici (Pixel odpojený, iPhone 12 mini „unavailable“), měřeno
na **macOS (Apple Silicon, profile build)**. Skripty v `tool/spike/`, na telefonu
`flutter run -d <id> --profile -t tool/spike/buffer_stream_spike.dart`.

**BufferStream + producent v hlavním isolate** (timer 4 ms, bloky 256 framů,
„jank“ = 30 ms blokace isolate každých 400 ms):

| mixér (`init(bufferSize:)`) | předstih 20 ms | 40 ms | 60 ms | 90 ms |
|---|---|---|---|---|
| 2048 framů = 46 ms (dnešní default) | zasekne se | zasekne se (4,4 s z 5) | OK | OK |
| 512 framů = 11,6 ms | OK, s jankem zasekne | **OK i s jankem** | OK | OK |
| 256 framů = 5,8 ms | OK, s jankem zasekne | OK i s jankem | OK | OK |

- Podtečení **zasekne stream natrvalo**: SoLoud voice pauzuje a odpauzuje jen při
  dalším `addAudioDataStream`. → `ScratchVoice` po podtečení hned dotlačí data a
  zvýší předstih o 10 ms (max 120 ms). První „buffering“ po startu není podtečení.
- Data se musí poslat **až po `play()`**, jinak voice zůstane v počátečním bufferingu.
- Na BufferStream voice se nesmí volat `setPause` (SoLoud ho sám přepíná).
- Filtry (echo, biquad) na BufferStream zdroji fungují stejně jako na `loadUrl`.
- **Odhad latence dotyk→zvuk (cesta B): 40 ms předstih + 11,6 ms mixér + výstup
  zařízení** (macOS ~5–10 ms, telefony typicky 10–40 ms). Na hranici 60 ms.

**Dekódování**: `readSamplesFromMem` je nepoužitelné pro přehrávání (vrací jen levý
kanál, čte po jednom framu – `src/waveform/waveform.cpp`). Vlastní FFI balíček
`packages/djfy_decoder` (dr_mp3): 6 min stereo 192 kbit/s → 60 MiB s16 PCM za
**201 ms** (RSS +83 MiB), stereo ověřeno. Na telefonu odhad 1–1,5 s.

**End-to-end v `AudioEngine`** (`tool/spike/voice_spike.dart`): stažení + dekódování
20s skladby 19–30 ms, přehrávání, couvání (−1×), držení, sledování prstu, konec
skladby – vše funguje, bez podtečení, slyšená pozice zaostává ~30–40 ms.

**Rozhodnutí**: implementována **cesta B** (Dart producent, mixér 512 framů,
adaptivní předstih 40–120 ms). Podle pravidla uživatele (hranice 60 ms) je potřeba
**změřit na iPhonu 12 mini a Pixelu 8a**: spustit `buffer_stream_spike.dart`
a poslech scratch na zařízení. Když vyjde jank-safe předstih > ~40 ms nebo je
scratch slyšitelně opožděný, přejít na **C-lite** (producent v nativním vlákně,
`ScratchRenderer` přepsat do C v `packages/djfy_decoder/src`).
