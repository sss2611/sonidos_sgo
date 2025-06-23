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
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> reproducir(String path) async {
    await _audioPlayer.stop();
    setState(() => _reproduciendo = path);
    await _audioPlayer.play(AssetSource(path));
  }

  Future<void> pausar() async {
    await _audioPlayer.pause();
  }

  Future<void> detener() async {
    await _audioPlayer.stop();
    setState(() => _reproduciendo = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Artistas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildArtistaCard(
            nombre: 'Néstor Garnica',
            descripcion: 'Violinista y cantante de folclore argentino.',
            imagen: 'lib/assets/images/nestor.png',
            audio: 'audio/nestor.mp3',
          ),
          SizedBox(height: 10),
          buildArtistaCard(
            nombre: 'Dany Hoyos',
            descripcion: 'Es marca registrada en el género de la guaracha.',
            imagen: 'lib/assets/images/dani.png',
            audio: 'audio/dani.mp3',
          ),
          SizedBox(height: 10),
          buildArtistaCard(
            nombre: 'Monde Flos.',
            descripcion:
                'Una fusión única de ritmos santiagueños y melodías francesas.',
            imagen: 'lib/assets/images/monde.png',
            audio: 'audio/monde.mp3',
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nombre,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(descripcion),
            SizedBox(height: 12),
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
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.play_arrow,
                          color: estaReproduciendo
                              ? Colors.greenAccent
                              : Colors.white,
                        ),
                        onPressed: () => reproducir(audio),
                      ),
                      IconButton(
                        icon: Icon(Icons.pause, color: Colors.white),
                        onPressed: pausar,
                      ),
                      IconButton(
                        icon: Icon(Icons.stop, color: Colors.white),
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
