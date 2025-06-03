import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'stream_client.dart'; // Import your custom client

class YouTubeAudioSource extends StreamAudioSource {
  final String videoId;
  final String quality; // 'high' or 'low'
  final YoutubeExplode ytExplode = YoutubeExplode();
  final AudioStreamClient streamClient = AudioStreamClient();

  YouTubeAudioSource({required this.videoId, this.quality = 'high', super.tag});

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    int attempts = 0;
    const maxAttempts = 3;
    while (true) {
      try {
        final manifest = await ytExplode.videos.streamsClient.getManifest(
          videoId,
          ytClients: [
            YoutubeApiClient.androidVr,
          ], // Use the VR client to avoid rate limiting
        );
        final audioStreams = manifest.audioOnly.sortByBitrate();

        final audioStream =
            quality == 'high'
                ? audioStreams.lastOrNull
                : audioStreams.firstOrNull;

        if (audioStream == null) {
          throw Exception('No audio stream available for this video.');
        }

        start ??= 0;
        end ??= audioStream.size.totalBytes;
        if (end > audioStream.size.totalBytes) {
          end = audioStream.size.totalBytes;
        }

        // Use the custom stream client for robust streaming
        final stream = streamClient.getAudioStream(
          audioStream,
          start: start,
          end: end,
        );

        return StreamAudioResponse(
          sourceLength: audioStream.size.totalBytes,
          contentLength: end - start,
          offset: start,
          stream: stream,
          contentType: audioStream.codec.mimeType,
        );
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) {
          throw Exception(
            'Failed to load audio after $maxAttempts attempts: $e',
          );
        }
        // Optionally, add a short delay before retrying
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }
}
