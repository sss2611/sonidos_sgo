import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ArtistasPage extends StatefulWidget {
  @override
  State<ArtistasPage> createState() => _ArtistasPageState();
}

class _ArtistasPageState extends State<ArtistasPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _reproduciendo;

  @override
  void dispose() {
    // Asegúrate de detener cualquier reproducción y liberar los recursos del reproductor
    _audioPlayer.stop(); // Detener antes de disponer
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> reproducir(String path) async {
    try {
      // Detener cualquier audio que se esté reproduciendo actualmente
      await _audioPlayer.stop();
      // Actualizar el estado para reflejar el audio que se va a reproducir
      setState(() => _reproduciendo = path);
      // Iniciar la reproducción del audio desde los assets de la aplicación
      // IMPORTANTE: Asegúrate de que 'path' esté correctamente declarado en tu pubspec.yaml
      // bajo la sección 'assets:' (ej. - lib/audio/)
      await _audioPlayer.play(AssetSource(path));
      print('Reproduciendo $path');

      // Opcional: Escuchar cuando el audio termina para resetear el estado
      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _reproduciendo = null; // Reiniciar el estado cuando el audio termine
        });
        print('Reproducción de $path completada.');
      });
    } catch (e) {
      // Capturar y mostrar cualquier error que ocurra durante la reproducción
      print('Error al reproducir $path: $e');
    }
  }

  Future<void> pausar() async {
    // Pausar la reproducción del audio actual
    await _audioPlayer.pause();
    print('Audio pausado.');
  }

  Future<void> detener() async {
    // Detener completamente la reproducción y resetear el estado
    await _audioPlayer.stop();
    setState(() => _reproduciendo = null);
    print('Audio detenido.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Artistas'), // 'const' aquí es válido porque el texto es fijo.
        backgroundColor: Colors.blueAccent, // Pequeño ajuste de estilo
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildArtistaCard(
            nombre: 'Néstor Garnica',
            descripcion: 'Violinista y cantante de folclore argentino.',
            imagen: 'lib/assets/images/nestor.png',
            audio: 'lib/audio/nestor.mp3',
          ),
          const SizedBox(height: 10),
          buildArtistaCard(
            nombre: 'Dany Hoyos',
            descripcion: 'Es marca registrada en el género de la guaracha.',
            imagen: 'lib/assets/images/dani.png',
            audio: 'lib/audio/dani.mp3',
          ),
          const SizedBox(height: 10),
          buildArtistaCard(
            nombre: 'Monde Flos.',
            descripcion:
                'Una fusión única de ritmos santiagueños y melodías francesas.',
            imagen: 'lib/assets/images/monde.png',
            audio: 'lib/audio/monde.mp3',
          ),
        ],
      ),
    );
  }

  Widget buildArtistaCard({
    required String nombre,
    required String descripcion,
    required String imagen,
    required String audio,
  }) {
    final bool estaReproduciendo = _reproduciendo == audio;

    return Card(
      elevation: 6, // Un poco más de elevación
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)), // Bordes más redondeados
      margin: const EdgeInsets.symmetric(
          vertical: 8), // Margen para separar las tarjetas
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple), // Color para el título
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700]), // Estilo para la descripción
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 32,
                      maxHeight: 200,
                    ),
                    child: Image.asset(
                      imagen,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Icon(Icons.broken_image,
                              size: 50, color: Colors.grey[400]),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                        153, 0, 0, 0), // Reemplazo de .withOpacity(0.6)
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.play_circle_fill,
                          color: estaReproduciendo
                              ? const Color.fromARGB(255, 23, 221, 63)
                              : Colors.white,
                          size: 36,
                        ),
                        onPressed: () => reproducir(audio),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(
                          Icons.pause_circle_filled,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: pausar,
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(
                          Icons.stop_circle,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: detener,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
