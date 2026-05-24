import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/track.dart';

class TrackListItem extends StatelessWidget {
  final Track track;
  final bool isSeed;

  const TrackListItem({super.key, required this.track, this.isSeed = false});

  @override
  Widget build(BuildContext context) {
    return Draggable<Track>(
      data: track,
      feedback: Material(
        color: Colors.transparent,
        child: _TrackTile(track: track, isSeed: isSeed, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _TrackTile(track: track, isSeed: isSeed),
      ),
      child: _TrackTile(track: track, isSeed: isSeed),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final Track track;
  final bool isSeed;
  final bool isDragging;

  const _TrackTile({
    required this.track,
    this.isSeed = false,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSeed
            ? kNeonCyan.withAlpha(20)
            : (isDragging ? kCardBg : kSurface),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSeed
              ? kNeonCyan.withAlpha(80)
              : Colors.white.withAlpha(10),
          width: isSeed ? 1.5 : 1,
        ),
        boxShadow: isDragging
            ? [BoxShadow(color: kNeonCyan.withAlpha(60), blurRadius: 12)]
            : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: _Artwork(url: track.artworkUrl),
        title: Text(
          track.title,
          style: TextStyle(
            color: isSeed ? kNeonCyan : Colors.white,
            fontWeight: isSeed ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          track.artist,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: track.bpm != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: kNeonPurple.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kNeonPurple.withAlpha(80)),
                ),
                child: Text(
                  '${track.bpm}',
                  style: const TextStyle(
                    color: kNeonPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : (track.soundcloudStreamUrl == null
                ? const Icon(Icons.link_off, size: 14, color: Colors.white24)
                : null),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final String? url;
  const _Artwork({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.music_note, size: 18, color: Colors.white38),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorWidget: (ctx, url, err) =>
            const Icon(Icons.music_note, size: 18, color: Colors.white38),
      ),
    );
  }
}
