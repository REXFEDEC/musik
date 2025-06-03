import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';
import '../widgets/playlist_manager_widget.dart';
import '../services/audio_manager.dart';
import 'player_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistService = Provider.of<PlaylistService>(context);
    final playlists = playlistService.playlists;
    final audioManager = Provider.of<AudioManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 28,
            onPressed:
                () => showDialog(
                  context: context,
                  builder: (context) => const PlaylistManagerWidget(),
                ),
          ),
        ],
      ),
      body:
          playlists.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.queue_music_rounded,
                      size: 80,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No playlists yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed:
                          () => showDialog(
                            context: context,
                            builder: (context) => const PlaylistManagerWidget(),
                          ),
                      child: const Text('Create one'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Material(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.queue_music_rounded,
                              color: Colors.grey[400],
                            ),
                          ),
                          title: Text(
                            playlist.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${playlist.songs.length} songs',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          children: [
                            if (playlist.songs.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'No songs in this playlist',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              )
                            else
                              ...playlist.songs.map(
                                (song) => ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child:
                                        song.thumbnailUrl.isNotEmpty
                                            ? Image.network(
                                              song.thumbnailUrl,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) => Container(
                                                    width: 40,
                                                    height: 40,
                                                    color: Colors.grey[800],
                                                    child: const Icon(
                                                      Icons.music_note,
                                                      size: 20,
                                                    ),
                                                  ),
                                            )
                                            : Container(
                                              width: 40,
                                              height: 40,
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                Icons.music_note,
                                                size: 20,
                                              ),
                                            ),
                                  ),
                                  title: Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    song.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 22,
                                    ),
                                    onPressed: () async {
                                      await playlistService.removeFromPlaylist(
                                        playlist.id,
                                        song.videoId,
                                      );
                                    },
                                  ),
                                  onTap: () async {
                                    await audioManager.playQueue(
                                      playlist.songs,
                                      startIndex: playlist.songs.indexOf(song),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PlayerScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
