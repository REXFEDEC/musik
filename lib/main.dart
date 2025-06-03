import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'screens/main_scaffold.dart';
import 'services/audio_manager.dart';
import 'services/playlist_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background audio
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.musik.channel.audio',
    androidNotificationChannelName: 'Music Playback',
    androidNotificationOngoing: true,
  );

  // Initialize playlist service
  final playlistService = PlaylistService();
  await playlistService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioManager>(create: (_) => AudioManager()),
        ChangeNotifierProvider<PlaylistService>(create: (_) => playlistService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YT Music App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF23272A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF23272A),
          brightness: Brightness.dark,
          background: Colors.black,
          primary: const Color(0xFF23272A),
          secondary: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: GoogleFonts.rubikTextTheme(ThemeData.dark().textTheme),
        iconTheme: const IconThemeData(color: Colors.white),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Color(0xFF23272A),
          unselectedItemColor: Colors.white70,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/main': (context) => MainScaffold(),
      },
    );
  }
}
