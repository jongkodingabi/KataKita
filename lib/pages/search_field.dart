import 'package:flutter/material.dart';
import 'package:katakita_new/pages/home.dart';
import 'package:katakita_new/pages/result.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController placeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Cari kata',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
                onPressed: () {},
                icon: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home(),
                        ));
                  },
                )),
            backgroundColor: Colors.blueAccent,
          ),
          backgroundColor: Colors.blueAccent,
          body: Center(
              child: Container(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logoWhite.png',
                  width: 200,
                  height: 200,
                ),
                TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Masukkan sebuah kata',
                      hintStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Fredoka',
                          fontSize: 16.0),
                      prefixIcon: const Icon(Icons.search)),
                  controller: placeController,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Result(
                        place: placeController.text,
                      );
                    }));

                    print(placeController.text);
                  },
                  child: const Text('Cari'),
                )
              ],
            ),
          ))),
    );
  }
}
