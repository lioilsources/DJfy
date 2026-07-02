# DJ_DECK — Flutter Mobile App Plan

> Mobilní DJ appka s chytrým playlistem. Last.fm doporučení, GetSongBPM metadata, SoundCloud streaming. Žádný backend — vše řeší klient.

---

## Přehled aplikace

Uživatel zadá kapelu nebo song → appka stáhne podobné tracky z Last.fm → dohledá BPM z GetSongBPM → vyhledá audio na SoundCloud → zobrazí smart playlist seřazený podle BPM proximity. Tracky lze přetáhnout na vinyl deck (1–6 decků), kde lze každý deck ovládat samostatně (seek, speed, volume). Více decků hraje zároveň.

---

## Architektura

```
lib/
├── main.dart
├── app/
│   ├── app.dart                  # MaterialApp, theme, routing
│   └── theme.dart                # Dark DJ theme, barvy, fonty
│
├── features/
│   ├── search/                   # Vyhledávání kapely/songu
│   │   ├── search_screen.dart
│   │   ├── search_cubit.dart
│   │   └── search_state.dart
│   │
│   ├── playlist/                 # Smart playlist panel
│   │   ├── playlist_screen.dart
│   │   ├── playlist_cubit.dart
│   │   ├── playlist_state.dart
│   │   └── track_list_item.dart  # Draggable track tile
│   │
│   └── deck/                     # DJ deck(y)
│       ├── deck_screen.dart      # Layout 1–6 decků
│       ├── deck_widget.dart      # Jeden deck (vinyl + kontroly)
│       ├── vinyl_painter.dart    # CustomPainter vinyl kotouč
│       ├── deck_cubit.dart       # State jednoho decku
│       └── deck_state.dart
│
├── services/
│   ├── lastfm_service.dart       # Last.fm API wrapper
│   ├── soundcloud_service.dart   # SoundCloud API wrapper
│   ├── bpm_service.dart          # GetSongBPM API wrapper
│   └── audio_engine.dart        # just_audio instance manager
│
├── models/
│   ├── track.dart                # Datový model tracku
│   ├── deck_config.dart          # Konfigurace decku
│   └── playlist_result.dart     # Výsledek smart search
│
└── core/
    ├── constants.dart            # API klíče, base URLs
    ├── cache_service.dart        # SQLite BPM cache
    └── extensions.dart           # Dart extensions
```

### State management: flutter_bloc (Cubit)

Každý deck má vlastní `DeckCubit` napojený na dedikovanou `just_audio` instanci. `PlaylistCubit` je sdílený přes celou appku.

---

## Datový model

```dart
class Track {
  final String id;
  final String title;
  final String artist;
  final String? artworkUrl;
  final String? soundcloudStreamUrl;   // HLS AAC URL
  final String? soundcloudPermalinkUrl;
  final int? bpm;                       // z GetSongBPM nebo null
  final List<String> tags;             // z Last.fm
  final double? similarity;            // Last.fm similarity score (0.0–1.0)
}
```

---

## API Integrace

### 1. Last.fm

**Endpoints použité:**
- `track.getSimilar` — podobné tracky ke seed songu (vrací similarity score + tagy)
- `artist.getSimilar` — pokud uživatel hledá kapelu, ne song
- `track.search` — resolve přesného názvu před getSimilar

**Auth:** Pouze API klíč appky v query parametru. Žádný user login.

**Příklad flow:**
```
GET https://ws.audioscrobbler.com/2.0/
  ?method=track.getSimilar
  &artist=Rage+Against+the+Machine
  &track=Killing+in+the+Name
  &limit=20
  &api_key=LASTFM_API_KEY
  &format=json
```

Vrátí max 20 podobných tracků seřazených Last.fm algoritmem. Z nich vybereme 3–5 nejblíže BPM seed tracku po obohacení BPM daty.

---

### 2. GetSongBPM

**Endpoint:** `https://api.getsong.co/search/` + `https://api.getsong.co/song/`

**Auth:** API klíč appky. Žádný user login. Podmínka: backlink na getsongbpm.com v appce (např. v About sekci nebo pod BPM hodnotou).

**Flow:**
```
1. GET /search/?api_key=KEY&type=song&lookup=Killing+in+the+Name&artist=Rage+Against+the+Machine
   → vrátí song ID
2. GET /song/?api_key=KEY&id=SONG_ID
   → vrátí { bpm: 138, key: "E Minor", ... }
```

**BPM fallback waterfall:**
```
GetSongBPM API hit (~50ms)
  → miss (indie track)
    → lokální FFT z prvních 15s SoundCloud HLS streamu (~3s)
      → výsledek uložit do SQLite cache
```

**BPM proximity algoritmus (smart playlist):**
```dart
// Po získání BPM seed tracku vyfiltruj podobné tracky:
final sorted = similarTracks
  .where((t) => t.bpm != null)
  .toList()
  ..sort((a, b) => 
    (a.bpm! - seedBpm).abs().compareTo((b.bpm! - seedBpm).abs()));

final bestMatches = sorted.take(3).toList();
// Výsledek: 3 tracky s nejbližším BPM (ideálně ±5 BPM pro DJ mix)
```

---

### 3. SoundCloud

**Auth:** Client Credentials flow — `client_id` + `client_secret` appky, žádný user login pro veřejné tracky.

**Token získání (při startu appky):**
```
POST https://api.soundcloud.com/oauth2/token
  grant_type=client_credentials
  client_id=CLIENT_ID
  client_secret=CLIENT_SECRET

→ { access_token: "...", expires_in: 3600 }
```

Token cachovat v paměti, obnovovat 60s před expirací.

**Track vyhledávání:**
```
GET https://api.soundcloud.com/tracks?
  q=Killing+in+the+Name+Rage+Against+the+Machine
  &filter=streamable
  &limit=5
Authorization: OAuth ACCESS_TOKEN
```

**Stream URL:**
```
GET https://api.soundcloud.com/tracks/{id}/streams
→ { hls_aac_160_url: "https://...playlist.m3u8", ... }
```

HLS AAC 160k je primární formát (od konce 2025, MP3 odstraněno). `just_audio` podporuje HLS nativně.

**Poznámka k registraci:** SoundCloud vyžaduje Artist Pro účet pro registraci developer appky. Jeden sdílený `client_id` pro všechny uživatele appky.

---

## Audio Engine

```dart
// audio_engine.dart — singleton správce všech deck instancí

class AudioEngine {
  static final instance = AudioEngine._();
  final Map<int, AudioPlayer> _players = {};  // deckId → player

  AudioPlayer playerFor(int deckId) {
    return _players.putIfAbsent(deckId, () => AudioPlayer());
  }

  Future<void> loadTrack(int deckId, String hlsUrl) async {
    final player = playerFor(deckId);
    await player.setAudioSource(HlsAudioSource(Uri.parse(hlsUrl)));
  }

  // Seek přes vinyl drag gesture
  Future<void> seekTo(int deckId, Duration position) async {
    await playerFor(deckId).seek(position);
  }

  // Speed: rozsah 0.5x – 2.0x (just_audio setSpeed)
  Future<void> setSpeed(int deckId, double speed) async {
    await playerFor(deckId).setSpeed(speed);
  }

  // Volume: 0.0 – 1.0
  Future<void> setVolume(int deckId, double volume) async {
    await playerFor(deckId).setVolume(volume);
  }

  void dispose(int deckId) {
    _players.remove(deckId)?.dispose();
  }
}
```

`just_audio` instance jsou na sobě nezávislé → libovolný počet simultánních přehrávání (limit prakticky dán HW a sítí).

---

## Deck Widget

### Vinyl kotouč — CustomPainter

```dart
class VinylPainter extends CustomPainter {
  final double progressAngle;    // 0.0 – 2π, odvozeno z playback position
  final Color accentColor;
  final String? artworkUrl;
  
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Vnější kroužky (groove rings)
    // 2. Artwork uprostřed (DecorationImage)
    // 3. Progress arc (tenká barevná čára)
    // 4. Středový label
  }
}
```

**Seek gesture:**
```dart
GestureDetector(
  onPanUpdate: (details) {
    // atan2 z bodu gesta relativně ke středu kotouče
    final center = Offset(size.width / 2, size.height / 2);
    final angle = atan2(
      details.localPosition.dy - center.dy,
      details.localPosition.dx - center.dx,
    );
    // Mapovat úhel → pozice v tracku
    final position = Duration(
      milliseconds: (angle / (2 * pi) * totalDuration.inMilliseconds).round(),
    );
    audioEngine.seekTo(deckId, position);
  },
)
```

### Deck layout (jeden deck):

```
┌─────────────────────────────────┐
│  [×]  Song Title          [BPM] │  ← header, zavřít deck
│                                 │
│       ╭─────────────╮           │
│       │   ◉ vinyl   │           │  ← VinylPainter, GestureDetector
│       │   kotouč    │           │
│       ╰─────────────╯           │
│                                 │
│  ◀◀  ▶/⏸  ▶▶    00:42 / 03:21  │
│                                 │
│  ⚡ Speed  [━━●━━━━]  1.00×    │  ← Slider 0.7–1.3×
│  🔊 Volume [━━━━●━━]  80%      │
└─────────────────────────────────┘
```

---

## Deck Layout Manager

### Responsive grid decků:

| Počet decků | Layout |
|-------------|--------|
| 1 | Fullscreen |
| 2 | Horizontálně vedle sebe (landscape) nebo nad sebou (portrait) |
| 3–4 | 2×2 grid |
| 5–6 | 2×3 grid (scroll pokud obrazovka nestačí) |

```dart
class DeckScreen extends StatelessWidget {
  final List<int> activeDeckIds;  // 1–6 ID aktivních decků

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Smart playlist panel (collapsible, výchozí otevřený)
      PlaylistPanel(),
      
      // Deck grid
      Expanded(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: activeDeckIds.length <= 2 ? 1 : 2,
            childAspectRatio: /* podle počtu */,
          ),
          itemBuilder: (ctx, i) => DeckWidget(deckId: activeDeckIds[i]),
        ),
      ),
      
      // Tlačítko přidat deck (max 6)
      if (activeDeckIds.length < 6)
        AddDeckButton(onAdd: () { /* přidat nový DeckCubit */ }),
    ]);
  }
}
```

---

## Smart Playlist Panel

### UI:

```
┌─────────────────────────────────┐
│ 🔍 [Rage Against the Machine  ] │  ← TextField + search button
├─────────────────────────────────┤
│ Seed:                           │
│  ♫ Killing in the Name  138 BPM │  ← seed track (tučně)
│                                 │
│ Podobné (±BPM):                 │
│  ♫ Bulls on Parade      136 BPM │  ← Draggable<Track>
│  ♫ Bombtrack            141 BPM │
│  ♫ Wake Up              133 BPM │
│  ♫ Guerrilla Radio      140 BPM │
│  ...                            │
│                                 │
│ [Přidat deck]                   │
└─────────────────────────────────┘
```

### Drag & Drop:

```dart
// Track tile je Draggable
Draggable<Track>(
  data: track,
  feedback: TrackDragFeedback(track: track),   // vizuál při dragu
  childWhenDragging: TrackTileGhost(),          // průhledný placeholder
  child: TrackListItem(track: track),
)

// Vinyl deck je DragTarget
DragTarget<Track>(
  onAccept: (track) {
    context.read<DeckCubit>().loadTrack(track);
  },
  builder: (ctx, candidates, rejected) {
    final isHovering = candidates.isNotEmpty;
    return DeckWidget(isDropTarget: isHovering);
  },
)
```

---

## BPM Cache (SQLite)

Pro tracky kde GetSongBPM neuspěje a BPM se detekuje lokálně — výsledek uložit aby se analýza neopakovala.

```dart
// cache_service.dart
class CacheService {
  late Database _db;

  Future<void> init() async {
    _db = await openDatabase('bpm_cache.db', onCreate: (db, v) {
      db.execute('''CREATE TABLE bpm_cache (
        artist TEXT,
        title  TEXT,
        bpm    INTEGER,
        PRIMARY KEY (artist, title)
      )''');
    });
  }

  Future<int?> getBpm(String artist, String title) async { ... }
  Future<void> saveBpm(String artist, String title, int bpm) async { ... }
}
```

---

## Pubspec závislosti

```yaml
dependencies:
  flutter_bloc: ^8.1.4        # State management
  just_audio: ^0.9.36         # Audio playback + HLS
  dio: ^5.4.3                 # HTTP klient
  sqflite: ^2.3.2             # SQLite BPM cache
  path_provider: ^2.1.2       # DB cesta
  get_it: ^7.6.7              # Service locator (singleton AudioEngine)

dev_dependencies:
  bloc_test: ^9.1.5
  mocktail: ^1.0.3
```

`just_audio` na iOS vyžaduje přidání do `Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict><key>NSAllowsArbitraryLoads</key><true/></dict>
```
(SoundCloud HLS streamy nejsou vždy přes HTTPS s platným cert chainí)

---

## Konfigurace API klíčů

```dart
// lib/core/constants.dart
// Klíče vložit přes --dart-define při buildu (necommitovat do gitu!)

const kLastFmApiKey     = String.fromEnvironment('LASTFM_API_KEY');
const kSoundCloudId     = String.fromEnvironment('SC_CLIENT_ID');
const kSoundCloudSecret = String.fromEnvironment('SC_CLIENT_SECRET');
const kGetSongBpmKey    = String.fromEnvironment('GETSONGBPM_KEY');
```

Build příkaz:
```bash
flutter run \
  --dart-define=LASTFM_API_KEY=xxx \
  --dart-define=SC_CLIENT_ID=xxx \
  --dart-define=SC_CLIENT_SECRET=xxx \
  --dart-define=GETSONGBPM_KEY=xxx
```

---

## Registrace API účtů (co zaregistrovat)

| Služba | Kde | Podmínky |
|--------|-----|----------|
| Last.fm | last.fm/api/account/create | Zdarma, stačí email |
| SoundCloud | developers.soundcloud.com | Vyžaduje Artist Pro účet |
| GetSongBPM | getsongbpm.com/api | Zdarma, backlink povinný |

Uživatelé appky se nikam přihlašovat nemusí. Jeden sdílený app credential pro každou službu.

---

## Implementační fáze

### Fáze 1 — API vrstva + modely (2–3 dny)
- `Track` model
- `LastFmService` — getSimilar, search
- `SoundCloudService` — token, search, streams
- `BpmService` — GetSongBPM search + song lookup
- `CacheService` — SQLite init + get/save
- Unit testy služeb s mocktail

### Fáze 2 — Smart playlist UI (2 dny)
- `SearchScreen` + `PlaylistCubit`
- BPM waterfall (GetSongBPM → lokální FFT → cache)
- BPM proximity sort
- `TrackListItem` + `Draggable<Track>`

### Fáze 3 — Deck widget (3 dny)
- `VinylPainter` CustomPainter
- Seek gesture (atan2)
- `DeckCubit` + `AudioEngine`
- Speed/volume sliders
- `DragTarget<Track>` na deck

### Fáze 4 — Multi-deck layout (1–2 dny)
- `DeckScreen` grid (1–6)
- Přidání/odebrání decku
- Responsive layout (portrait/landscape)

### Fáze 5 — Polish (1–2 dny)
- Dark DJ téma (barvy, vinyl animace)
- GetSongBPM backlink v UI
- Error states (SoundCloud track není streamovatelný)
- Lokální FFT fallback implementace

---

## Otevřené otázky / rozhodnutí

- **Lokální FFT knihovna:** `fftea` (čistý Dart) vs. nativní platform channel — závisí na přesnosti požadované pro mixování
- **Počet Last.fm výsledků:** limit=20 a pak BPM sort, nebo limit=5 a preferovat Last.fm pořadí?
- **UI téma:** Dark DJ aesthetic (černá, neonová akcentová barva) — finální barvy dle tvé volby
- **Offline mode:** Aktuálně žádný — vše vyžaduje síť. Cache jen BPM hodnoty.
- **SoundCloud track not found:** Fallback — zobrazit "Poslechnout na SoundCloud" link místo play tlačítka
