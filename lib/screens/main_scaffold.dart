import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';
import '../widgets/mini_audio_bar.dart';
import '../services/audio_manager.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  const MainScaffold({this.initialIndex = 0, super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniAudioBar(
              onTap: () {
                final audioManager = Provider.of<AudioManager>(
                  context,
                  listen: false,
                );
                if (audioManager.currentSong != null &&
                    !PlayerScreen.isCurrentScreen(context)) {
                  PlayerScreen.open(context);
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_rounded),
                  label: 'Library',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
