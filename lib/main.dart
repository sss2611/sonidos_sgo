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
        title: 'Sonidos SGO',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

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

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final dx = w / 2;
    final dy = h / 4;

    return Path()
      ..moveTo(dx, 0)
      ..lineTo(w, dy)
      ..lineTo(w, dy * 3)
      ..lineTo(dx, h)
      ..lineTo(0, dy * 3)
      ..lineTo(0, dy)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget hexButton(IconData icon, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: const Color.fromARGB(0, 72, 73, 135),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 79, 3, 3).withAlpha(77),
              blurRadius: 10,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 208, 5, 5).withAlpha(26),
          ),
          child: Center(
            child: Icon(icon,
                size: 36, color: const Color.fromARGB(255, 189, 12, 12)),
          ),
        ),
      ),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          SizedBox.expand(
            child: Image.asset(
              "lib/assets/images/festival3.png",
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 0.03, left: 0.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(botones.length, (i) {
                    final offsetX = (i % 2 == 0) ? 0.1 : 40.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.4),
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
// BOTON DE ENLACE AL TP2
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                final Uri url =
                    Uri.parse('https://sss2611.github.io/TP2_Programacion3/');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  throw 'No se pudo abrir $url';
                }
              },
              child: Image.asset(
                'lib/assets/logos/lohany.jpg',
                width: 60,
                height: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
