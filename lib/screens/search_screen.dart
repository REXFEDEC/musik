import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_manager.dart';
import '../services/ytmusic_service.dart';
import '../models/song.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _ytService = YTMusicService();
  List<Song> _songs = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  void _addToSearchHistory(String query) {
    if (query.isEmpty) return;
    setState(() {
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
    _saveSearchHistory();
  }

  void _removeFromHistory(String query) {
    setState(() {
      _searchHistory.remove(query);
    });
    _saveSearchHistory();
  }

  void _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _songs.clear();
    });

    _addToSearchHistory(query);

    try {
      final results = await _ytService.searchSongs(query);
      if (!mounted) return;
      setState(() {
        _songs = results;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching: ${e.toString()}'),
          backgroundColor: Colors.red[800],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search songs...',
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _songs.clear();
                              });
                            },
                          )
                          : null,
                ),
                onSubmitted: (_) => _search(),
                textInputAction: TextInputAction.search,
              ),
            ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _songs.isEmpty && _searchHistory.isNotEmpty
                      ? ListView.builder(
                        itemCount: _searchHistory.length,
                        itemBuilder: (context, index) {
                          final query = _searchHistory[index];
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(query),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeFromHistory(query),
                            ),
                            onTap: () {
                              _searchController.text = query;
                              _search();
                            },
                          );
                        },
                      )
                      : ListView.builder(
                        itemCount: _songs.length,
                        itemBuilder: (context, index) {
                          final song = _songs[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                song.thumbnailUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey[900],
                                      child: const Icon(
                                        Icons.music_note,
                                        color: Colors.white70,
                                      ),
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
                            ),
                            onTap: () async {
                              if (!mounted) return;
                              final audioManager = Provider.of<AudioManager>(
                                context,
                                listen: false,
                              );
                              try {
                                await audioManager.playSong(song);
                                if (mounted) {
                                  // Pop until we reach first route or player route
                                  Navigator.of(context).popUntil(
                                    (route) =>
                                        route.isFirst ||
                                        route.settings.name == '/player',
                                  );
                                  // Open player if not already open
                                  if (!PlayerScreen.isCurrentScreen(context)) {
                                    PlayerScreen.open(context);
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error playing song: ${e.toString()}',
                                      ),
                                      backgroundColor: Colors.red[800],
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
