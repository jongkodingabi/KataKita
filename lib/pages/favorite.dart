import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<String> favorites = [];

  // Fungsi untuk memuat daftar favorit dari SharedPreferences
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  // Fungsi untuk menghapus kata dari favorit
  Future<void> removeFavorite(String word) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites.remove(word);
      prefs.setStringList('favorites', favorites);
    });
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kata Favorit',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('Belum ada kata favorit.'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final word = favorites[index];
                return ListTile(
                  title: Text(word),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeFavorite(word),
                  ),
                );
              },
            ),
    );
  }
}
