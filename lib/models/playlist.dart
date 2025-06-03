import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final List<Song> songs;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    List<Song>? songs,
    DateTime? createdAt,
  }) : songs = songs ?? [],
       createdAt = createdAt ?? DateTime.now();

  bool containsSong(String videoId) => songs.any((s) => s.videoId == videoId);

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'],
      name: map['name'],
      songs:
          (map['songs'] as List?)
              ?.map((s) => Song.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
