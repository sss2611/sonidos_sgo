import 'package:flutter/material.dart';
import 'simulacion_pago.dart'; // Asegurate de importar tu archivo de pago

class CronogramaPage extends StatelessWidget {
  final Map<String, List<String>> cronograma = {
    'Viernes 15 de Noviembre': [
      '18:00 - Apertura de puertas',
      '19:30 - Banda de apertura folclore',
      '21:00 - Rock',
      '23:00 - DJ Electrónica',
    ],
    'Sábado 16 de Noviembre': [
      '17:00 - Apertura de puertas',
      '18:30 - Banda apertura Guaracha',
      '20:30 - Folclore',
      '23:30 - DJ Invitado',
    ],
  };

  final List<Map<String, String>> entradas = [
    {
      'tipo': 'Día 1',
      'precio': '\$8.000',
      'beneficio': 'Acceso completo al festival el día viernes.'
    },
    {
      'tipo': 'Día 2',
      'precio': '\$8.500',
      'beneficio': 'Acceso completo al festival el día sábado.'
    },
    {
      'tipo': 'Abono 2 días',
      'precio': '\$15.500',
      'beneficio':
          'Acceso completo a ambos días del festival (viernes y sábado).'
    },
    {
      'tipo': 'VIP',
      'precio': '\$18.500',
      'beneficio':
          'Acceso preferencial para ambos días, áreas exclusivas y beneficios especiales.'
    },
  ];

  final List<String> puntosVenta = [
    'Centro Cultural - Av. Libertad 439, Santiago del Estero',
    'Universidad Nacional de Santiago del Estero - Av. Belgrano Sur 1912, Santiago del Estero',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cronograma')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horarios
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Horario de Actuaciones',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                )),
                    SizedBox(height: 12),
                    ...cronograma.entries.map((dia) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dia.key,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple),
                            ),
                            ...dia.value.map((hora) => Text('• $hora')),
                            SizedBox(height: 12),
                          ],
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Entradas
            Text('Tipos de Entradas Disponibles',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            ...entradas.map((e) => Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e['tipo']} - ${e['precio']}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(e['beneficio'] ?? ''),
                        SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SimulacionPagoPage(entrada: e),
                                ),
                              );
                            },
                            child: Text('Comprar Entrada'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 24),

            // Puntos de venta
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Puntos de Venta Físicos',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.teal.shade800,
                                  fontWeight: FontWeight.bold,
                                )),
                    SizedBox(height: 12),
                    ...puntosVenta.map((p) => Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.teal.shade700),
                            SizedBox(width: 8),
                            Expanded(child: Text(p)),
                          ],
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
