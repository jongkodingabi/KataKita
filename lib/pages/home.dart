import 'package:flutter/material.dart';
import 'package:katakita_new/loading_screen.dart';
import 'package:katakita_new/pages/favorite.dart';
import 'package:katakita_new/pages/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoved = false;

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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KataKita',
          style: TextStyle(
              fontFamily: 'Fredoka',
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/logoWhite.png',
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/kataKita_splash.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Konten Utama
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Baris pertama kartu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildCard(
                          icon: Icons.favorite,
                          text: Text(
                            'Favorit',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          color: Colors.blueAccent,
                          iconColor: Colors.red,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FavoritePage()));
                          },
                        ),
                        const SizedBox(width: 16),
                        buildCard(
                          icon: Icons.book,
                          text: Text(
                            'Cari kata',
                            style: TextStyle(
                                fontFamily: 'fredoka',
                                fontWeight: FontWeight.bold),
                          ),
                          color: Colors.white,
                          iconColor: Colors.blueAccent,
                          onTap: () {
                            void showLoadingAndNavigate(BuildContext context) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoadingScreen(),
                                  ));
                            }

                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SearchField(),
                                  ));
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    kataHariIniWidget(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({
    required IconData icon,
    required Widget text, // Ubah dari String ke Widget
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    TextStyle? textStyle, // Parameter opsional untuk mengubah style teks
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 40),
              const SizedBox(height: 8),
              text
            ],
          ),
        ),
      ),
    );
  }

  Widget kataHariIniWidget() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kata_hari_ini')
          .doc('hari_ini')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        if (snapshot.hasError) {
          return const Text(
            'Error loading data',
            style: TextStyle(color: Colors.black),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text(
            'Data tidak ditemukan',
            style: TextStyle(color: Colors.black, fontFamily: 'Fredoka'),
          );
        }

        // Pengambilan data dari Firestore
        var data = snapshot.data!;
        String tanggal = data['tanggal'] ?? 'Tanggal tidak tersedia';
        String kata = data['kata'] ?? 'Kata tidak tersedia';
        String jenis = data['jenis'] ?? 'Jenis tidak tersedia';
        String arti = data['arti'] ?? 'Arti tidak tersedia';

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          color: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Kata Hari Ini",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tanggal,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  kata,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  jenis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isLoved = !isLoved;
                      if (isLoved) {
                        // simpan kata sebagai favorit
                        saveFavorite(kata);
                      } else {
                        // hapus kata dari favorit
                        removeFavorite(kata);
                      }
                    });
                  },
                  icon: Icon(
                    isLoved ? Icons.favorite : Icons.favorite_outline_outlined,
                    color: isLoved ? Colors.red : Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    arti,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
