import 'package:flutter/material.dart';
import '../models/song.dart';

class SongQueue extends StatelessWidget {
  final List<Song> queue;
  final int? currentIndex;
  final bool showQueue;
  final VoidCallback onToggle;
  final ValueChanged<int> onSongTap;

  const SongQueue({
    super.key,
    required this.queue,
    required this.currentIndex,
    required this.showQueue,
    required this.onToggle,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    if (queue.length <= 1) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min, // Add this line
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Queue (${queue.length})",
                  style: const TextStyle(color: Colors.white),
                ),
                Icon(
                  showQueue
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (showQueue)
          Flexible(
            // Change Container to Flexible
            child: Container(
              constraints: const BoxConstraints(
                // Add constraints
                maxHeight: 180, // Maximum height
              ),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.builder(
                shrinkWrap: true, // Add this line
                itemCount: queue.length,
                itemBuilder: (context, idx) {
                  final song = queue[idx];
                  final isCurrent = idx == currentIndex;
                  return ListTile(
                    leading:
                        isCurrent
                            ? const Icon(Icons.play_arrow, color: Colors.white)
                            : Text(
                              '${idx + 1}',
                              style: TextStyle(
                                color:
                                    isCurrent ? Colors.white : Colors.white70,
                              ),
                            ),
                    title: Text(
                      song.title,
                      style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.white70,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.white60,
                      ),
                    ),
                    onTap: () => onSongTap(idx),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
