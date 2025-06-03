import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/playlist_service.dart';

class PlaylistManagerWidget extends StatelessWidget {
  final Song? song;

  const PlaylistManagerWidget({super.key, this.song});

  @override
  Widget build(BuildContext context) {
    final playlistService = Provider.of<PlaylistService>(context);
    final playlists = playlistService.playlists;

    return AlertDialog(
      title: Text(song == null ? 'Manage Playlists' : 'Add to Playlist'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (song != null) ...[
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Create new playlist'),
                onTap:
                    () => _showCreatePlaylistDialog(context, playlistService),
              ),
              const Divider(),
            ],
            ...playlists
                .map(
                  (playlist) =>
                      _buildPlaylistTile(context, playlist, playlistService),
                )
                .toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  ListTile _buildPlaylistTile(
    BuildContext context,
    Playlist playlist,
    PlaylistService service,
  ) {
    final isInPlaylist = song != null && playlist.containsSong(song!.videoId);

    return ListTile(
      leading: Icon(isInPlaylist ? Icons.check : Icons.playlist_play),
      title: Text(playlist.name),
      subtitle: Text('${playlist.songs.length} songs'),
      onTap: () async {
        if (song == null) {
          Navigator.pop(context);
          return;
        }

        if (isInPlaylist) {
          await service.removeFromPlaylist(playlist.id, song!.videoId);
          _showSnackBar(context, 'Removed from ${playlist.name}');
        } else {
          await service.addToPlaylist(playlist.id, song!);
          _showSnackBar(context, 'Added to ${playlist.name}');
        }
        Navigator.pop(context);
      },
    );
  }

  Future<void> _showCreatePlaylistDialog(
    BuildContext context,
    PlaylistService service,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Playlist'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter playlist name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Name cannot be empty' : null,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.pop(context, controller.text);
                  }
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.pop(context, controller.text);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty && song != null) {
      try {
        final playlist = await service.createPlaylist(result);
        await service.addToPlaylist(playlist.id, song!);
        _showSnackBar(context, 'Created "$result" and added song');
      } catch (e) {
        _showSnackBar(context, 'Failed to create playlist: ${e.toString()}');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
