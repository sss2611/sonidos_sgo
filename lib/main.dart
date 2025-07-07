// 📦 Estas son las librerías que usamos para construir la app
import 'package:flutter/material.dart'; // Herramientas visuales de Flutter
import 'package:provider/provider.dart'; // Para manejar estado entre pantallas
import 'package:url_launcher/url_launcher.dart'; // Para abrir enlaces externos, como Google Maps

// 🔄 Importao pantallas que cree (estan en archivos .dart separados)
import 'artistas.dart';
import 'entradas.dart';


// 🚀 Aquí comienza la ejecución de la aplicación Flutter
void main() {
  runApp(const MyApp()); // Este método lanza la aplicación y muestra el widget MyApp
}


// 🏗️ Este es el widget principal (raíz) de toda la app
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor con clave opcional (recomendado para buenas prácticas)

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider( // 🔁 Esto permite compartir datos en la app si quiero usar Provider
      create: (context) => MyAppState(), // Instancia de un objeto de estado (vacío por ahora)
      child: MaterialApp( // Este widget me configura la app entera
        title: 'Sonidos SGO', // Nombre de la app
        theme: ThemeData( // Tema de colores y estilos
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(), // Página principal que se muestra al iniciar la app
        debugShowCheckedModeBanner: false, // Quita la banderita de "Debug" en la esquina
      ),
    );
  }
}


// 💾 Esta clase representa el estado global de la app
class MyAppState extends ChangeNotifier {}


// 📍 Esta función abre Google Maps con una ubicación
void launchMaps() async {
  final Uri uri = Uri.parse('https://maps.app.goo.gl/Z3GLp7XqevnKNBHQ6'); // URL del mapa
  try {
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw 'No se pudo abrir el mapa'; // Si falla, lanza un error
    }
  } catch (e) {
    print('Error al abrir el mapa: $e');
  }
}

// Definí una clase personalizada para recortar widgets en forma de hexágono
class HexagonClipper extends CustomClipper<Path> {
  // Este método genera la figura (Path) del hexágono que se usará para recortar
  @override
  Path getClip(Size size) {
    // Guarda el ancho total del widget que se va a recortar
    final w = size.width;

    // Guarda la altura total del widget que se va a recortar
    final h = size.height;

    // Calcula la mitad del ancho, que será el centro horizontal
    final dx = w / 2;

    // Calcula un cuarto de la altura, para definir la forma vertical del hexágono
    final dy = h / 4;

    // Aquí se crea el camino (Path) que forma el hexágono:
    return Path()
      // Mueve el punto inicial al vértice superior central
      ..moveTo(dx, 0)

      // Dibuja línea al vértice superior derecho
      ..lineTo(w, dy)

      // Dibuja línea hacia el vértice inferior derecho
      ..lineTo(w, dy * 3)

      // Línea al vértice inferior central
      ..lineTo(dx, h)

      // Línea al vértice inferior izquierdo
      ..lineTo(0, dy * 3)

      // Línea al vértice superior izquierdo
      ..lineTo(0, dy)

      // Cierra el camino uniendo el último punto con el primero
      ..close();
  }

  // Este método determina si se debe volver a recortar si algo cambia
  // En este caso no cambia, así que devuelve false para evitar recalcular
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Esta función crea un botón con forma de hexágono, ícono y texto
Widget hexButton(String label, IconData icon, VoidCallback onPressed,
    {bool textBeforeIcon = false}) {
  return GestureDetector( // Detecta toques en pantalla
    onTap: onPressed, // Ejecuta acción al tocar
    child: Row( // Organiza el texto e ícono en una fila
      mainAxisSize: MainAxisSize.min, //define cuánto espacio ocupa el widget en el eje principal(debe ocupar solo el espacio mínimo necesario para mostrar sus hijos)
      children: [
        if (textBeforeIcon) // Muestra texto antes del ícono si está activado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Color.fromARGB(255, 41, 19, 130),
                fontSize: 10,
                fontWeight: FontWeight.bold, //negrita
              ),
            ),
          ),
        ClipPath( // Recorta la forma del hexágono
          clipper: HexagonClipper(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color.fromARGB(0, 72, 73, 135),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 211, 199, 199).withAlpha(77),
                  blurRadius: 10,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 208, 5, 5).withAlpha(26),
              ),
              child: Center( // Centra el ícono dentro del hexágono
                child: Icon(
                  icon,
                  size: 36,
                  color: const Color.fromARGB(255, 189, 12, 12),
                ),
              ),
            ),
          ),
        ),
        if (!textBeforeIcon) // Muestra texto después del ícono si corresponde
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Color.fromARGB(255, 41, 19, 130),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    ),
  );
}


// Esta es la pantalla principal que ve el usuario al entrar en la app
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Lista con los botones del menú principal
    final List<Map<String, dynamic>> botones = [
      {
        'icon': Icons.person,
        'label': 'Artistas',
        'action': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ArtistasPage()), // Navega a la pantalla de artistas
            ),
        'textBeforeIcon': true,
      },
      {
        'icon': Icons.local_activity,
        'label': 'Entradas',
        'action': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CronogramaPage()), // Navega a cronograma/entradas
            ),
        'textBeforeIcon': false,
      },
      {
        'icon': Icons.location_on,
        'label': 'Ubicación',
        'action': () => launchMaps(), // Abre Google Maps
        'textBeforeIcon': true,
      },
    ];

    return Scaffold( // Define la estructura de la pantalla
      body: Stack( // Permite apilar widgets unos sobre otros
        children: [
          // Imagen de fondo
          SizedBox.expand(
            child: Image.asset(
              "lib/assets/images/festival3.png",
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Center(child: Text("Imagen no encontrada")),
              ),
            ),
          ),
          // Botones centrales (Artistas, Entradas, Ubicación)
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 1, left: 12, right: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: botones
                      .map((boton) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: hexButton(
                              boton['label'],
                              boton['icon'],
                              boton['action'],
                              textBeforeIcon: boton['textBeforeIcon'] ?? false,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          // Logo flotante en la esquina inferior derecha que abre la web del TP2 al tocarse
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse('https://sss2611.github.io/TP2_Programacion3/');
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
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
