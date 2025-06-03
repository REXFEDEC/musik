import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_manager.dart';
import '../widgets/song_queue.dart';
import '../widgets/animated_album_background.dart';
import '../widgets/playlist_manager_widget.dart';

class PlayerScreen extends StatefulWidget {
  static bool isCurrentScreen(BuildContext context) {
    return ModalRoute.of(context)?.settings.name == '/player';
  }

  static void open(BuildContext context) {
    if (!isCurrentScreen(context)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/player'),
          builder: (_) => const PlayerScreen(),
        ),
      );
    }
  }

  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showQueue = false;
  bool _isChangingTrack = false;

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final player = audioManager.player;
    final currentSong = audioManager.currentSong;
    final queue = audioManager.queue;
    final currentIndex = audioManager.currentIndex;

    if (currentSong == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = player.duration ?? Duration.zero;

        return Scaffold(
          extendBodyBehindAppBar: true, // ✅ Fullscreen background
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Now Playing'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.playlist_add),
                color: Colors.white,
                onPressed:
                    () => showDialog(
                      context: context,
                      builder:
                          (context) => PlaylistManagerWidget(
                            song: audioManager.currentSong,
                          ),
                    ),
              ),
            ],
          ),
          body: Stack(
            children: [
              AnimatedAlbumBackground(imageUrl: currentSong.bestThumbnailUrl),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height - kToolbarHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: player.playing ? 300 : 280,
                          width: player.playing ? 300 : 280,
                          curve: Curves.easeInOut,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              currentSong.bestThumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    color: Colors.grey,
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          currentSong.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentSong.artist,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Slider(
                          value: position.inMilliseconds.toDouble().clamp(
                            0,
                            duration.inMilliseconds.toDouble(),
                          ),
                          min: 0,
                          max:
                              duration.inMilliseconds > 0
                                  ? duration.inMilliseconds.toDouble()
                                  : 1,
                          onChanged:
                              (val) => player.seek(
                                Duration(milliseconds: val.toInt()),
                              ),
                          activeColor: Colors.white,
                          inactiveColor: Colors.grey,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _format(position),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              _format(duration),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous, size: 36),
                              color: Colors.white,
                              onPressed:
                                  player.hasPrevious && !_isChangingTrack
                                      ? () async {
                                        setState(() => _isChangingTrack = true);
                                        await audioManager.skipPrevious();
                                        setState(
                                          () => _isChangingTrack = false,
                                        );
                                      }
                                      : null,
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: Icon(
                                player.playing
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                size: 64,
                              ),
                              color: Colors.white,
                              onPressed:
                                  _isChangingTrack
                                      ? null
                                      : () {
                                        // Remove the mounted check since we're already on PlayerScreen
                                        if (PlayerScreen.isCurrentScreen(
                                          context,
                                        )) {
                                          if (player.playing) {
                                            audioManager.pause();
                                          } else {
                                            audioManager.resume();
                                          }
                                        }
                                      },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.skip_next, size: 36),
                              color: Colors.white,
                              onPressed:
                                  player.hasNext && !_isChangingTrack
                                      ? () async {
                                        setState(() => _isChangingTrack = true);
                                        await audioManager.skipNext();
                                        setState(
                                          () => _isChangingTrack = false,
                                        );
                                      }
                                      : null,
                            ),
                          ],
                        ),
                        if (queue.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: SongQueue(
                              queue: queue,
                              currentIndex: currentIndex,
                              showQueue: _showQueue,
                              onToggle: () {
                                setState(() => _showQueue = !_showQueue);
                              },
                              onSongTap: (index) async {
                                if (index != currentIndex) {
                                  setState(() => _isChangingTrack = true);
                                  await audioManager.playFromQueue(index);
                                  setState(() => _isChangingTrack = false);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}';
  }
}
