class Track {
  final String id;
  final String title;
  final String artist;
  final String? artworkUrl;
  final String? soundcloudStreamUrl;
  final String? soundcloudPermalinkUrl;
  final int? bpm;
  final List<String> tags;
  final double? similarity;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.artworkUrl,
    this.soundcloudStreamUrl,
    this.soundcloudPermalinkUrl,
    this.bpm,
    this.tags = const [],
    this.similarity,
  });

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? artworkUrl,
    String? soundcloudStreamUrl,
    String? soundcloudPermalinkUrl,
    int? bpm,
    List<String>? tags,
    double? similarity,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      soundcloudStreamUrl: soundcloudStreamUrl ?? this.soundcloudStreamUrl,
      soundcloudPermalinkUrl:
          soundcloudPermalinkUrl ?? this.soundcloudPermalinkUrl,
      bpm: bpm ?? this.bpm,
      tags: tags ?? this.tags,
      similarity: similarity ?? this.similarity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Track && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
