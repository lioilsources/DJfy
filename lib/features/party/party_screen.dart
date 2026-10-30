import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/theme.dart';
import '../../core/smart_queue.dart';
import '../../models/party.dart';
import '../../models/track.dart';
import 'airplay_button.dart';
import 'party_cubit.dart';
import 'party_state.dart';

/// Host view of a party: QR to join, now playing, smart queue, guests.
class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PartyCubit, PartyState>(
      listenWhen: (a, b) => b.message != null && a.message != b.message,
      listener: (context, state) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!))),
      buildWhen: (a, b) => a.phase != b.phase,
      builder: (context, state) => switch (state.phase) {
        PartyPhase.idle || PartyPhase.starting => const _StartView(),
        PartyPhase.live => const _LiveView(),
        PartyPhase.error => _ErrorView(state.message ?? 'Chyba'),
      },
    );
  }
}

// ── Start ────────────────────────────────────────────────────────────────────

class _StartView extends StatefulWidget {
  const _StartView();

  @override
  State<_StartView> createState() => _StartViewState();
}

class _StartViewState extends State<_StartView> {
  final _name = TextEditingController(text: 'Party');

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final starting = context.select((PartyCubit c) => c.state.phase == PartyPhase.starting);
    return Scaffold(
      appBar: AppBar(title: const Text('PARTY')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.celebration, color: kNeonPurple, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Tvůj telefon je DJ. Reproduktor je jen reproduktor.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hosté naskenují QR, hledají a hlasují v prohlížeči – bez appky a bez účtu. '
            'Fronta žije u tebe, zvuk pošleš přes AirPlay nebo Bluetooth.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _name,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Název party'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: starting ? null : () => context.read<PartyCubit>().start(_name.text),
            icon: starting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.qr_code),
            label: const Text('ZALOŽIT PARTY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kNeonCyan,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView(this.message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PARTY')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(onPressed: () => context.read<PartyCubit>().end(), child: const Text('ZPĚT')),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Live ─────────────────────────────────────────────────────────────────────

class _LiveView extends StatelessWidget {
  const _LiveView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PartyCubit>();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<PartyCubit, PartyState>(
            buildWhen: (a, b) => a.code != b.code || a.relayConnected != b.relayConnected,
            builder: (context, s) => Row(
              children: [
                Icon(Icons.circle, size: 10, color: s.relayConnected ? Colors.greenAccent : Colors.orange),
                const SizedBox(width: 8),
                Text(s.code ?? ''),
              ],
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'QR pro hosty',
              icon: const Icon(Icons.qr_code_2),
              onPressed: () => _showJoin(context),
            ),
            IconButton(
              tooltip: 'Ukončit party',
              icon: const Icon(Icons.power_settings_new),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Ukončit party?'),
                    content: const Text('Hosté se odpojí a fronta se smaže.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('NE')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('UKONČIT')),
                    ],
                  ),
                );
                if (ok == true) cubit.end();
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: kNeonCyan,
            labelColor: kNeonCyan,
            unselectedLabelColor: Colors.white38,
            tabs: [Tab(text: 'FRONTA'), Tab(text: 'HOSTÉ'), Tab(text: 'HLEDAT')],
          ),
        ),
        body: const Column(
          children: [
            _NowPlayingCard(),
            Expanded(child: TabBarView(children: [_QueueTab(), _GuestsTab(), _SearchTab()])),
          ],
        ),
      ),
    );
  }

  static void _showJoin(BuildContext context) {
    final url = context.read<PartyCubit>().state.joinUrl ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardBg,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: QrImageView(data: url, size: 220),
            ),
            const SizedBox(height: 16),
            SelectableText(url, style: const TextStyle(color: kNeonCyan, fontSize: 16)),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('KOPÍROVAT ODKAZ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PartyCubit>();
    return BlocBuilder<PartyCubit, PartyState>(
      buildWhen: (a, b) =>
          a.nowPlaying != b.nowPlaying ||
          a.isPlaying != b.isPlaying ||
          a.autoDj != b.autoDj ||
          a.moodLock != b.moodLock ||
          a.queue.isEmpty != b.queue.isEmpty,
      builder: (context, s) {
        final t = s.nowPlaying;
        return Container(
          color: kCardBg,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Column(
            children: [
              Row(
                children: [
                  _Artwork(t?.artworkUrl, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t?.title ?? (s.queue.isEmpty ? 'Fronta je prázdná' : 'Připraveno – zmáčkni ▶'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          [
                            if (t != null) t.artist,
                            if (t?.bpm != null) '${t!.bpm} BPM',
                            if (s.nowPlayingEntry != null) 'přidal(a) ${s.nowPlayingEntry!.proposedByName}',
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(s.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 40, color: kNeonCyan),
                    onPressed: t == null && s.queue.isEmpty ? null : cubit.togglePlay,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: t == null ? null : cubit.skip,
                  ),
                ],
              ),
              StreamBuilder<({Duration position, Duration duration})>(
                stream: cubit.player.progress,
                builder: (context, snap) {
                  final p = snap.data;
                  final v = p == null || p.duration.inMilliseconds == 0
                      ? 0.0
                      : (p.position.inMilliseconds / p.duration.inMilliseconds).clamp(0.0, 1.0);
                  return LinearProgressIndicator(
                    value: v,
                    minHeight: 2,
                    color: kNeonCyan,
                    backgroundColor: Colors.white12,
                  );
                },
              ),
              Row(
                children: [
                  const Text('AUTO-DJ', style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1)),
                  Switch(value: s.autoDj, onChanged: cubit.setAutoDj, activeThumbColor: kNeonPurple),
                  ActionChip(
                    avatar: const Icon(Icons.lock_outline, size: 14),
                    label: Text(s.moodLock?.toString() ?? 'Mood lock', style: const TextStyle(fontSize: 11)),
                    onPressed: () => _editMoodLock(context, s.moodLock),
                  ),
                  const Spacer(),
                  const AirPlayButton(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _editMoodLock(BuildContext context, MoodLock? current) async {
    final cubit = context.read<PartyCubit>();
    var range = RangeValues(
      (current?.minBpm ?? 118).toDouble(),
      (current?.maxBpm ?? 130).toDouble(),
    );
    final result = await showDialog<Object>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Mood lock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${range.start.round()}–${range.end.round()} BPM'),
              RangeSlider(
                values: range,
                min: 60,
                max: 190,
                divisions: 130,
                onChanged: (v) => setState(() => range = v),
              ),
              const Text(
                'Skladby mimo rozsah zůstanou ve frontě, ale nezahrají se samy.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('VYPNOUT')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ZAMKNOUT')),
          ],
        ),
      ),
    );
    if (result == true) {
      cubit.setMoodLock(MoodLock(range.start.round(), range.end.round()));
    } else if (result == false) {
      cubit.setMoodLock(null);
    }
  }
}

class _QueueTab extends StatelessWidget {
  const _QueueTab();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PartyCubit>();
    return BlocBuilder<PartyCubit, PartyState>(
      buildWhen: (a, b) => a.ranked != b.ranked,
      builder: (context, s) {
        if (s.ranked.isEmpty) {
          return const Center(
            child: Text('Zatím nic. Přidej skladbu nebo ukaž hostům QR.', style: TextStyle(color: Colors.white38)),
          );
        }
        return ListView.builder(
          itemCount: s.ranked.length,
          itemBuilder: (context, i) {
            final se = s.ranked[i];
            return Dismissible(
              key: ValueKey(se.entry.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent.withAlpha(60),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Text('VETO', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
              onDismissed: (_) => cubit.veto(se.entry.id),
              child: _QueueTile(se),
            );
          },
        );
      },
    );
  }
}

class _QueueTile extends StatelessWidget {
  final ScoredEntry se;
  const _QueueTile(this.se);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PartyCubit>();
    final e = se.entry;
    return Opacity(
      opacity: se.blocked ? 0.45 : 1,
      child: ListTile(
        dense: true,
        leading: _Artwork(e.track.artworkUrl, size: 40),
        title: Text(e.track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${e.track.artist} · ${e.proposedByName} · 👍${e.upVotes} 👎${e.downVotes}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
            if (se.reasons.isNotEmpty)
              Text(se.reasons.join(' · '), style: const TextStyle(fontSize: 10, color: kNeonPurple)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) => switch (v) {
            'now' => cubit.playNow(e.id),
            'pin' => cubit.pin(e.id),
            _ => cubit.veto(e.id),
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'now', child: Text('Hrát hned')),
            PopupMenuItem(value: 'pin', child: Text(e.pinnedAt == null ? 'Hrát příští' : 'Odepnout')),
            const PopupMenuItem(value: 'veto', child: Text('Veto')),
          ],
        ),
      ),
    );
  }
}

class _GuestsTab extends StatelessWidget {
  const _GuestsTab();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PartyCubit>();
    return BlocBuilder<PartyCubit, PartyState>(
      buildWhen: (a, b) => a.guests != b.guests || a.banned != b.banned,
      builder: (context, s) {
        final guests = s.guests.values.where((g) => !s.banned.contains(g.id)).toList()
          ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
        if (guests.isEmpty) {
          return const Center(child: Text('Zatím nikdo nedorazil', style: TextStyle(color: Colors.white38)));
        }
        return ListView(
          children: [
            for (final g in guests)
              ListTile(
                dense: true,
                title: Text(g.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(g.isCoDj ? 'co-DJ · hlas ×${SmartQueue.coDjWeight}, může dát veto' : 'host'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: g.isCoDj ? 'Odebrat co-DJ' : 'Povýšit na co-DJ',
                      icon: Icon(Icons.headphones, color: g.isCoDj ? kNeonPurple : Colors.white38),
                      onPressed: () => cubit.toggleCoDj(g.id),
                    ),
                    IconButton(
                      tooltip: 'Zablokovat',
                      icon: const Icon(Icons.block, color: Colors.redAccent),
                      onPressed: () => cubit.ban(g.id),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SearchTab extends StatefulWidget {
  const _SearchTab();

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final _q = TextEditingController();
  List<Track> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _q.text.trim();
    if (q.length < 2) return;
    setState(() => _loading = true);
    final r = await context.read<PartyCubit>().searchTracks(q);
    if (mounted) setState(() => (_results = r, _loading = false));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PartyCubit>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _q,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: const InputDecoration(
              hintText: 'Hledat na SoundCloudu…',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
          ),
        ),
        if (_loading) const LinearProgressIndicator(color: kNeonCyan, minHeight: 2),
        Expanded(
          child: ListView(
            children: [
              for (final t in _results)
                ListTile(
                  dense: true,
                  leading: _Artwork(t.artworkUrl, size: 40),
                  title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                  subtitle: Text([t.artist, if (t.bpm != null) '${t.bpm} BPM'].join(' · ')),
                  trailing: IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: () {
                      cubit.addTrack(t);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('„${t.title}“ přidáno')));
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Artwork extends StatelessWidget {
  final String? url;
  final double size;
  const _Artwork(this.url, {required this.size});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: kSurface,
      child: const Icon(Icons.music_note, color: Colors.white24),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: url == null
          ? placeholder
          : CachedNetworkImage(
              imageUrl: url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => placeholder,
            ),
    );
  }
}
