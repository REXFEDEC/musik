import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';
import 'youtube_audio_source.dart';

class AudioManager extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(
    children: [],
  );
  final List<Song> _queue = [];
  Song? currentSong;
  int? _currentIndex;

  AudioPlayer get player => _player;
  List<Song> get queue => List.unmodifiable(_queue);
  int? get currentIndex => _currentIndex;
  bool get isPlaying => _player.playing;

  AudioManager() {
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _queue.length) {
        _currentIndex = index;
        currentSong = _queue[index];
        notifyListeners();
      }
    });
  }

  MediaItem _createNotificationMediaItem(Song song) {
    // Use direct YouTube thumbnail URL format for reliability
    final thumbnailUrl = 'https://i.ytimg.com/vi/${song.videoId}/hqdefault.jpg';

    return MediaItem(
      id: song.videoId,
      title: song.title,
      artist: song.artist,
      artUri: Uri.parse(thumbnailUrl),
      // Remove extras that might interfere with notification display
      artHeaders: const {'User-Agent': 'Mozilla/5.0'},
    );
  }

  Future<void> playSong(Song song) async {
    await _player.stop();
    _playlist.clear();
    _queue.clear();
    _queue.add(song);
    await _playlist.add(
      YouTubeAudioSource(
        videoId: song.videoId,
        quality: 'high',
        tag: _createNotificationMediaItem(song), // Use the new method
      ),
    );
    _currentIndex = 0;
    currentSong = song;
    await _player.setAudioSource(_playlist);
    await _player.play();
    notifyListeners();
  }

  Future<void> addToQueue(Song song) async {
    // Always add to the end of the queue
    _queue.add(song);
    await _playlist.add(
      YouTubeAudioSource(
        videoId: song.videoId,
        quality: 'high',
        tag: _createNotificationMediaItem(song), // Use the new method
      ),
    );
    notifyListeners();
  }

  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    await _player.stop();
    _playlist.clear();
    _queue.clear();

    // Add all songs to queue
    _queue.addAll(songs);

    // Add all songs to playlist
    for (final song in songs) {
      await _playlist.add(
        YouTubeAudioSource(
          videoId: song.videoId,
          quality: 'high',
          tag: _createNotificationMediaItem(song), // Use the new method
        ),
      );
    }

    // Set current song and index
    _currentIndex = startIndex;
    currentSong = songs[startIndex];

    // Set source and play
    await _player.setAudioSource(_playlist, initialIndex: startIndex);
    await _player.play();
    notifyListeners();
  }

  Future<void> skipNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> skipPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    await _player.play();
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
    super.dispose();
  }

  Future<void> ensureSongIsPlaying(Song song) async {
    // If already playing this song, do nothing
    if (currentSong?.videoId == song.videoId) return;

    // Check if song exists in queue
    final existingIndex = _queue.indexWhere((s) => s.videoId == song.videoId);

    if (existingIndex != -1) {
      // If found in queue, play it from there
      await _player.seek(Duration.zero, index: existingIndex);
    } else {
      // If not found, add to queue and play
      await addToQueue(song);
      await _player.seek(Duration.zero, index: _queue.length - 1);
    }
  }

  // Add this method to ensure proper queue navigation
  Future<void> playFromQueue(int index) async {
    if (index >= 0 && index < _queue.length) {
      await _player.seek(Duration.zero, index: index);
    }
  }
}
