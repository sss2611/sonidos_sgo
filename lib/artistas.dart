// Importa los paquetes necesarios para construir la interfaz y reproducir audio.
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// Esta es la clase principal de la pantalla llamada 'ArtistasPage'
class ArtistasPage extends StatefulWidget {
  @override
  State<ArtistasPage> createState() => _ArtistasPageState();
}

// Esta clase maneja el estado de la pantalla (si se está reproduciendo o no, etc.)
class _ArtistasPageState extends State<ArtistasPage> {
  // Crea una instancia del reproductor de audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Guarda la URL del audio que se está reproduciendo actualmente
  String? _reproduciendo;

  // Variable booleana que indica si hay audio en reproducción
  bool _estaReproduciendo = false;

  // Se ejecuta al iniciar la pantalla
  @override
  void initState() {
    super.initState();

    // Escucha el estado del reproductor para saber si terminó o está reproduciendo
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _estaReproduciendo = state.playing;
          // Si el audio terminó, limpiamos la variable de URL
          if (state.processingState == ProcessingState.completed) {
            _reproduciendo = null;
          }
        });
      }
    });
  }

  // Se ejecuta al cerrar la pantalla. Libera el reproductor.
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Función para reproducir un audio desde una URL
  Future<void> reproducir(String url) async {
    try {
      // Si ya se está reproduciendo el mismo audio, se pausa
      if (_reproduciendo == url && _estaReproduciendo) {
        await pausar();
        return;
      }

      // Detenemos el audio anterior, cargamos el nuevo y lo reproducimos
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();

      // Actualiza el estado
      setState(() {
        _reproduciendo = url;
        _estaReproduciendo = true;
      });
    } catch (e) {
      // Muestra un error si algo falla
      print('Error al reproducir $url: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reproducir audio: $e')),
        );
      }
    }
  }

  // Función para pausar el audio
  Future<void> pausar() async {
    await _audioPlayer.pause();
    setState(() => _estaReproduciendo = false);
  }

  // Función para detener el audio
  Future<void> detener() async {
    await _audioPlayer.stop();
    setState(() {
      _estaReproduciendo = false;
      _reproduciendo = null;
    });
  }

  // Construye la interfaz visual de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artistas'),
        backgroundColor: const Color.fromARGB(255, 182, 80, 215),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta del primer artista
          buildArtistaCard(
            nombre: 'Néstor Garnica',
            descripcion: 'Violinista y cantante de folclore argentino.',
            imagen: 'lib/assets/images/nestor.png',
            audio: 'https://relaxed-boba-618c06.netlify.app/audio/nestor.mp3',
          ),
          const SizedBox(height: 10),
          buildArtistaCard(
            nombre: 'Dany Hoyos',
            descripcion: 'Es marca registrada en el género de la guaracha.',
            imagen: 'lib/assets/images/dani.png',
            audio: 'https://relaxed-boba-618c06.netlify.app/audio/dani.mp3',
          ),
          const SizedBox(height: 10),
          buildArtistaCard(
            nombre: 'Monde Flos.',
            descripcion:
                'Una fusión única de ritmos santiagueños y melodías francesas.',
            imagen: 'lib/assets/images/monde.png',
            audio: 'https://relaxed-boba-618c06.netlify.app/audio/monde.mp3',
          ),
        ],
      ),
    );
  }

  // Función que crea una tarjeta visual para mostrar un artista
  Widget buildArtistaCard({
    required String nombre,
    required String descripcion,
    required String imagen,
    required String audio,
  }) {
    // Verifica si este audio es el que se está reproduciendo actualmente
    final bool estaReproduciendoEste =
        _reproduciendo == audio && _estaReproduciendo;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del artista
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),

            // Descripción del artista
            Text(
              descripcion,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),

            // Imagen con botones de reproducción
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
                    color: const Color.fromARGB(153, 0, 0, 0),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón de reproducción / pausa
                      IconButton(
                        icon: Icon(
                          estaReproduciendoEste
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: estaReproduciendoEste
                              ? const Color.fromARGB(255, 23, 221, 63)
                              : Colors.white,
                          size: 36,
                        ),
                        onPressed: () => reproducir(audio),
                      ),
                      const SizedBox(width: 10),

                      // Botón de detener audio
                      IconButton(
                        icon: const Icon(
                          Icons.stop_circle,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: detener,
                      ),
                      const SizedBox(width: 10),

                      // Ícono que aparece solo si el audio se está reproduciendo
                      AnimatedOpacity(
                        opacity: estaReproduciendoEste ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(
                          Icons.graphic_eq,
                          color: Colors.greenAccent,
                          size: 28,
                        ),
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
