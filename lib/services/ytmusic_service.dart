import 'package:dart_ytmusic_api/yt_music.dart';
import '../models/song.dart';

class YTMusicService {
  final YTMusic _ytMusic = YTMusic();
  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      await _ytMusic.initialize();
      _initialized = true;
    }
  }

  Future<List<Song>> searchSongs(String query) async {
    try {
      // Ensure the API is initialized
      await initialize();

      // Perform a search for songs only
      final songResults = await _ytMusic.searchSongs(query);

      // Map the results to Song objects
      return songResults.map((item) {
        return Song(
          title: item.name,
          artist: item.artist.name,
          videoId: item.videoId,
          thumbnailUrl:
              item.thumbnails.isNotEmpty ? item.thumbnails.first.url : '',
          highResThumbnailUrl:
              item.thumbnails.isNotEmpty ? item.thumbnails.last.url : '',
          thumbnails:
              item.thumbnails
                  .map(
                    (t) => ThumbnailFull(
                      url: t.url,
                      width: t.width,
                      height: t.height,
                    ),
                  )
                  .toList(),
        );
      }).toList();
    } catch (e) {
      print("Error during search: $e");
      return []; // Return an empty list if there's an error
    }
  }
}
