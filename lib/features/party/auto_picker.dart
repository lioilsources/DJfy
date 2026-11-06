import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../core/smart_queue.dart';
import '../../models/party.dart';
import '../../models/track.dart';
import '../../services/lastfm_service.dart';
import '../../services/soundcloud_service.dart';

/// Picks a track to keep the party going once the queue runs dry.
///
/// Sources, first hit wins: Last.fm tracks similar to the last few played →
/// top tracks of those artists → a SoundCloud search by artist → replaying
/// something from earlier in the party. Last.fm has no audio, so every
/// suggestion has to be found on SoundCloud first.
class AutoPicker {
  static const seedCount = 3;

  /// How many of the best Last.fm suggestions are shuffled, so a party doesn't
  /// always walk the same path.
  static const _topSuggestions = 12;
  static const _maxLookups = 6;

  /// Tracks compared by BPM; each one may cost a GetSongBPM call.
  static const _maxMatches = 3;
  static const _replayGap = 5;

  static const _versionWords = ['remix', 'cover', 'live', 'karaoke', 'instrumental', 'edit', 'bootleg', 'nightcore'];

  final LastFmService _lastFm;
  final SoundCloudService _sc;
  final math.Random _random;

  AutoPicker(this._lastFm, this._sc, {math.Random? random}) : _random = random ?? math.Random();

  /// [recent] is what played, newest first. Never returns a track in [avoid]
  /// or outside [moodLock]; null when every source came up empty.
  Future<Track?> pick({
    required List<Track> recent,
    Set<String> avoid = const {},
    MoodLock? moodLock,
    required Future<Track> Function(Track) withBpm,
  }) async {
    if (recent.isEmpty) return null;
    final seeds = recent.take(seedCount).map(_identify).toList();
    final current = recent.first;
    final excluded = {...avoid, for (final t in recent) t.id};
    final heard = [for (final t in recent) _normalize(t.title)];

    Track? best(List<Track> tracks) => _closest(
          tracks.where((t) => moodLock == null || t.bpm == null || moodLock.contains(t.bpm!)),
          current.bpm,
        );

    final cooldown = {for (final s in seeds) _normalize(s.artist)};
    final similar = await _forEachSeed(seeds, (s) => _lastFm.getSimilarTracks(s.artist, s.title, limit: 30));
    similar.sort((a, b) => (b.similarity ?? 0).compareTo(a.similarity ?? 0));
    final suggestions = similar
        .where((t) => !cooldown.contains(_normalize(t.artist)) && !_wasHeard(t, heard))
        .take(_topSuggestions)
        .toList()
      ..shuffle(_random);
    var pick = best(await _findOnSoundCloud(suggestions, excluded, withBpm));
    if (pick != null) return pick;

    final top = await _forEachSeed(seeds, (s) => _lastFm.getSimilarArtistTracks(s.artist, limit: 20));
    final fresh = top.where((t) => !_wasHeard(t, heard)).toList()..shuffle(_random);
    pick = best(await _findOnSoundCloud(fresh, excluded, withBpm));
    if (pick != null) return pick;

    final byArtist = await _forEachSeed(seeds, (s) => _sc.searchTracks(s.artist, limit: 12));
    final unheard = byArtist
        .where((t) => !excluded.contains(t.id) && !_wasHeard(t, heard))
        .toList()
      ..shuffle(_random);
    pick = best(await Future.wait(unheard.take(_maxMatches).map(withBpm)));
    if (pick != null) return pick;

    final replay = recent.skip(_replayGap).where((t) => !avoid.contains(t.id)).toList()..shuffle(_random);
    return best(replay);
  }

  Future<List<Track>> _forEachSeed(
    List<({String artist, String title})> seeds,
    Future<List<Track>> Function(({String artist, String title})) source,
  ) async {
    final results = await Future.wait(seeds.map((s) async {
      try {
        return await source(s);
      } catch (e) {
        debugPrint('[AutoPicker] source failed: $e');
        return <Track>[];
      }
    }));
    return results.expand((r) => r).toList();
  }

  Future<List<Track>> _findOnSoundCloud(
    List<Track> suggestions,
    Set<String> excluded,
    Future<Track> Function(Track) withBpm,
  ) async {
    final found = <Track>[];
    for (final s in suggestions.take(_maxLookups)) {
      final hits = await _sc.searchTracks('${s.artist} ${s.title}', limit: 5);
      final hit = hits.where((h) => !excluded.contains(h.id) && _sameSong(s, h)).firstOrNull;
      if (hit == null) continue;
      found.add(await withBpm(hit));
      if (found.length == _maxMatches) break;
    }
    return found;
  }

  /// Closest tempo to [bpm]; tracks with an unknown tempo come last.
  Track? _closest(Iterable<Track> tracks, int? bpm) {
    Track? best;
    var bestDistance = double.infinity;
    for (final t in tracks) {
      final distance = bpm == null || t.bpm == null ? 1e6 : SmartQueue.bpmDistance(bpm, t.bpm!);
      if (best == null || distance < bestDistance) {
        best = t;
        bestDistance = distance;
      }
    }
    return best;
  }

  /// SoundCloud's artist is the uploader; the real one is often in the title,
  /// as "Artist - Title (Original Mix)". Last.fm needs the real one.
  ({String artist, String title}) _identify(Track t) {
    final title = t.title.replaceAll(RegExp(r'[(\[].*?[)\]]'), '').trim();
    final dash = title.indexOf(' - ');
    if (dash <= 0) return (artist: t.artist, title: title);
    return (artist: title.substring(0, dash).trim(), title: title.substring(dash + 3).trim());
  }

  static String _normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ').trim();

  static bool _wasHeard(Track t, List<String> heard) {
    final title = _normalize(_stripBrackets(t.title));
    return title.isNotEmpty && heard.any((h) => h.contains(title));
  }

  static String _stripBrackets(String s) => s.replaceAll(RegExp(r'[(\[].*?[)\]]'), '');

  /// Whether SoundCloud [hit] is really [wanted], not a remix or a namesake.
  static bool _sameSong(Track wanted, Track hit) {
    final title = _normalize(_stripBrackets(wanted.title));
    final hitTitle = _normalize(hit.title);
    if (title.isEmpty || !hitTitle.contains(title)) return false;
    final artist = _normalize(wanted.artist);
    if (!hitTitle.contains(artist) && !_normalize(hit.artist).contains(artist)) return false;
    final wantedWords = _normalize(wanted.title).split(' ');
    return !hitTitle
        .split(' ')
        .any((w) => _versionWords.contains(w) && !wantedWords.contains(w));
  }
}
