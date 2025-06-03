import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistService extends ChangeNotifier {
  static const String _prefsKey = 'playlists';
  List<Playlist> _playlists = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      await _loadPlaylists();
      if (!_playlists.any((p) => p.name == 'Downloads')) {
        await createPlaylist('Downloads');
      }
      _initialized = true;
    }
  }

  Future<void> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getStringList(_prefsKey);
    if (json != null) {
      _playlists = json.map((e) => _playlistFromJson(e)).toList();
    }
  }

  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _playlists.map((e) => _playlistToJson(e)).toList(),
    );
    notifyListeners();
  }

  Playlist _playlistFromJson(String json) {
    final map = jsonDecode(json);
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

  String _playlistToJson(Playlist playlist) {
    return jsonEncode({
      'id': playlist.id,
      'name': playlist.name,
      'songs': playlist.songs.map((s) => s.toMap()).toList(),
      'createdAt': playlist.createdAt.toIso8601String(),
    });
  }

  Future<Playlist> createPlaylist(String name) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _playlists.add(playlist);
    await _savePlaylists();
    return playlist;
  }

  Future<void> addToPlaylist(String playlistId, Song song) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    if (!playlist.songs.any((s) => s.videoId == song.videoId)) {
      playlist.songs.add(song);
      await _savePlaylists();
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String videoId) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.songs.removeWhere((s) => s.videoId == videoId);
    await _savePlaylists();
  }

  List<Playlist> get playlists => List.unmodifiable(_playlists);
}
