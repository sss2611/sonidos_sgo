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

void launchMaps() async {
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
}

// Hexágono personalizado
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Botón con forma de hexágono
Widget hexButton(IconData icon, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(77, 0, 0, 0),
              blurRadius: 6,
              spreadRadius: 2,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Center(
            child: Icon(icon, size: 36, color: Colors.white),
          ),
        ),
      ),
    ),
  );
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
            fit: BoxFit.contain,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.58),

                  Align(
                    alignment: Alignment.center,
                    child: hexButton(Icons.person, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArtistasPage()),
                      );
                    }),
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  Align(
                    alignment: Alignment.center,
                    child: hexButton(Icons.schedule, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CronogramaPage()),
                      );
                    }),
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  Align(
                    alignment: Alignment.center,
                    child: hexButton(Icons.location_on, () {
                      launchMaps();
                    }),
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
