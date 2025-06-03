import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_manager.dart';
import '../screens/player_screen.dart';
import '../widgets/song_queue.dart';

class MiniAudioBar extends StatelessWidget {
  final VoidCallback? onTap;
  const MiniAudioBar({this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final song = audioManager.currentSong;
    final queue = audioManager.queue;
    final currentIndex = audioManager.currentIndex;

    if (song == null) return const SizedBox.shrink();

    return WillPopScope(
      onWillPop: () async {
        if (PlayerScreen.isCurrentScreen(context)) {
          return true;
        }
        return false;
      },
      child: GestureDetector(
        onTap: onTap ?? () => PlayerScreen.open(context),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              constraints: const BoxConstraints(minHeight: 56, maxHeight: 64),
              padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          song.highResThumbnailUrl ?? song.thumbnailUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.white70,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Wrap play/pause button in GestureDetector
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (audioManager.isPlaying) {
                            audioManager.pause();
                          } else {
                            audioManager.resume();
                          }
                        },
                        child: IconButton(
                          icon: Icon(
                            audioManager.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () {
                            if (audioManager.isPlaying) {
                              audioManager.pause();
                            } else {
                              audioManager.resume();
                            }
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                      ),
                      if (queue.length > 1)
                        // Wrap queue button in GestureDetector
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder:
                                  (_) => SafeArea(
                                    child: Container(
                                      margin: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: SongQueue(
                                        queue: queue,
                                        currentIndex: currentIndex,
                                        showQueue: true,
                                        onToggle: () {},
                                        onSongTap: (idx) async {
                                          await audioManager.playFromQueue(idx);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: IconButton(
                            icon: const Icon(
                              Icons.queue_music,
                              color: Colors.white,
                              size: 28,
                            ),
                            tooltip: 'Show Queue',
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder:
                                    (_) => SafeArea(
                                      child: Container(
                                        margin: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.95),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: SongQueue(
                                          queue: queue,
                                          currentIndex: currentIndex,
                                          showQueue: true,
                                          onToggle: () {},
                                          onSongTap: (idx) async {
                                            await audioManager.playFromQueue(
                                              idx,
                                            );
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ),
                              );
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                        ),
                    ],
                  ),
                  StreamBuilder<Duration>(
                    stream: audioManager.player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration =
                          audioManager.player.duration ?? Duration.zero;
                      final progress =
                          duration.inMilliseconds > 0
                              ? position.inMilliseconds /
                                  duration.inMilliseconds
                              : 0.0;

                      return LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.5),
                        ),
                        minHeight: 1,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
