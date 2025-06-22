import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'artistas.dart';
import 'entradas.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Sonidos de mi SGO',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "lib/assets/images/festival.png",
            width: screenWidth,
            height: screenHeight,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.58),
                  Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: buildTextLink(context, 'Artistas', ArtistasPage()),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight * 0.03, right: screenWidth * 0.06),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: buildTextLink(
                          context, 'Cronograma', CronogramaPage()),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight * 0.03, right: screenWidth * 0.11),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: buildTextLink(context, 'Ubicación', null,
                          launchMaps: true),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildTextLink(
  BuildContext context,
  String label,
  Widget? page, {
  bool launchMaps = false,
  bool launchPayment = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: GestureDetector(
      onTap: () async {
        if (launchMaps) {
          final Uri uri = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=Hipódromo+Santiago+del+Estero',
          );
          try {
            if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
              throw 'No se pudo abrir el mapa';
            }
          } catch (e) {
            print('Error al abrir el mapa: $e');
          }
        } else if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 17,
          color: const Color.fromARGB(255, 234, 250, 19),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
