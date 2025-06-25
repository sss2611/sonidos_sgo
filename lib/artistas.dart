import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ArtistasPage extends StatefulWidget {
  @override
  State<ArtistasPage> createState() => _ArtistasPageState();
}

class _ArtistasPageState extends State<ArtistasPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _reproduciendo;
  bool _estaReproduciendo = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _estaReproduciendo = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _reproduciendo = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> reproducir(String url) async {
    try {
      if (_reproduciendo == url && _estaReproduciendo) {
        await pausar();
        return;
      }

      await _audioPlayer.stop();
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();

      setState(() {
        _reproduciendo = url;
        _estaReproduciendo = true;
      });
    } catch (e) {
      print('Error al reproducir $url: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reproducir audio: $e')),
        );
      }
    }
  }

  Future<void> pausar() async {
    await _audioPlayer.pause();
    setState(() => _estaReproduciendo = false);
  }

  Future<void> detener() async {
    await _audioPlayer.stop();
    setState(() {
      _estaReproduciendo = false;
      _reproduciendo = null;
    });
  }

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

  Widget buildArtistaCard({
    required String nombre,
    required String descripcion,
    required String imagen,
    required String audio,
  }) {
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
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
                      IconButton(
                        icon: const Icon(
                          Icons.stop_circle,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: detener,
                      ),
                      const SizedBox(width: 10),
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
