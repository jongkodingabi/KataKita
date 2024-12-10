import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:katakita_new/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:katakita_new/pages/home.dart'; // Pastikan mengimpor halaman Home

class Result extends StatefulWidget {
  final String place;

  const Result({super.key, required this.place});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  bool isLoved = false;

  Future<Map<String, dynamic>> getDataFromAPI() async {
    final response = await http.get(Uri.parse(
        'http://kateglo.lostfocus.org/api.php?format=json&phrase=${widget.place}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('kata tidak ditemukan');
    }
  }

  // Fungsi untuk menyimpan data ke SharedPreferences
  Future<void> saveFavorite(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    if (!favorites.contains(word)) {
      favorites.add(word);
      await prefs.setStringList('favorites', favorites);
    }
  }

  // Fungsi untuk menghapus kata yang favoritkan
  Future<void> removeFavorite(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    if (favorites.contains(word)) {
      favorites.remove(word);
      await prefs.setStringList('favorites', favorites);
    }
  }

  // Fungsi untuk memeriksa apakah kata sudah difavoritkan
  Future<void> checkIfLoved(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isLoved = favorites.contains(word);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Hasil kata',
            style: TextStyle(
                color: Colors.white,
                fontFamily: "Fredoka",
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(left: 70, right: 70),
          child: FutureBuilder(
            future: getDataFromAPI(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }

              if (snapshot.hasData) {
                final data = snapshot.data!['kateglo']; // non-nullables
                final phrase = data['phrase'] ?? 'N/A';
                final lexClass = data['lex_class_name'] ?? 'N/A';
                final definitions = data['definition'] as List;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      '$phrase',
                      style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Fredoka'),
                    ),
                    Text(
                      '$lexClass',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Fredoka'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isLoved = !isLoved;
                              if (isLoved) {
                                // simpan kata sebagai favorit
                                saveFavorite(phrase);
                              } else {
                                // hapus kata dari favorit
                                removeFavorite(phrase);
                              }
                            });
                          },
                          icon: Icon(
                            isLoved
                                ? Icons.favorite
                                : Icons.favorite_outline_outlined,
                            color: isLoved ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Arti Kata:',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: definitions.length,
                        itemBuilder: (context, index) {
                          final def = definitions[index];
                          final defNum = def['def_num'] ?? 'N/A';
                          final defText = def['def_text'] ?? 'N/A';
                          final sample = def['sample'] ?? 'N/A';

                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$defNum. $defText',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                if (sample != 'N/A')
                                  Text(
                                    'Contoh: $sample',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: Text('Kata tidak ditemukan'));
              }
            },
          ),
        ),
        // Tambahkan FloatingActionButton untuk navigasi ke halaman Home
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Arahkan ke halaman Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const Home()), // Pastikan Home sudah didefinisikan
            );
          },
          tooltip: 'Home',
          child: const Icon(Icons.home),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white, // Ikon Home
        ),
      ),
    );
  }
}
