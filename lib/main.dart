import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'artistas.dart';
import 'entradas.dart';

void main() {
  runApp(const MyApp());
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
    final dx = w / 2;
    final dy = h / 4;

    return Path()
      ..moveTo(dx, 0) // top center
      ..lineTo(w, dy) // top right
      ..lineTo(w, dy * 3) // bottom right
      ..lineTo(dx, h) // bottom center
      ..lineTo(0, dy * 3) // bottom left
      ..lineTo(0, dy) // top left
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Botón hexagonal con ícono y acción
Widget hexButton(IconData icon, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.transparent, 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              blurRadius: 10,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
           color: Colors.white.withAlpha(26),
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

    // Lista de íconos y sus respectivas acciones
    final List<Map<String, dynamic>> botones = [
      {
        'icon': Icons.person,
        'action': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ArtistasPage()),
            )
      },
      {
        'icon': Icons.schedule,
        'action': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CronogramaPage()),
            )
      },
      {'icon': Icons.location_on, 'action': () => launchMaps()},
    ];

 return Scaffold(
  body: Stack(
    children: [
      Image.asset(
        "lib/assets/images/festival.png",
        width: double.infinity,
        height: screenHeight,
        fit: BoxFit.cover,
      ),
      SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(botones.length, (i) {
                final offsetX = (i % 2 == 0) ? 0.0 : 30.0; // crea la forma >
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Transform.translate(
                    offset: Offset(offsetX, 0),
                    child: hexButton(
                      botones[i]['icon'],
                      botones[i]['action'],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    ],
  ),
);
  }
}