// Importaciones necesarias
import 'package:flutter/material.dart'; // UI de Flutter
import 'package:pdf/widgets.dart' as pw; // Para generar documentos PDF
import 'package:printing/printing.dart'; // Para imprimir o compartir PDF
import 'package:flutter/services.dart' show rootBundle; // Para cargar archivos locales
import 'dart:typed_data'; // Para manipular datos binarios como el PDF
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Íconos personalizados como el de WhatsApp

// Widget principal que representa la pantalla de simulación de pago
class SimulacionPagoPage extends StatefulWidget {
  final Map<String, String> entrada; // Información de la entrada (tipo, precio, beneficio)

  SimulacionPagoPage({required this.entrada});

  @override
  State<SimulacionPagoPage> createState() => _SimulacionPagoPageState();
}

// Estado de la pantalla (porque hay interactividad y cambios visuales)
class _SimulacionPagoPageState extends State<SimulacionPagoPage> {
  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para campos de texto
  final _whatsappController = TextEditingController();
  final _vencimientoController = TextEditingController();

  // Variables para guardar datos de la tarjeta
  String numero = '';
  String nombre = '';
  String vencimiento = '';
  String codigo = '';
  bool pagado = false; // Indica si el pago fue "realizado"

  // Se ejecuta al iniciar la pantalla
  @override
  void initState() {
    super.initState();

    // Escucha cambios en el campo de vencimiento y agrega automáticamente el "/"
    _vencimientoController.addListener(() {
      final text = _vencimientoController.text;
      if (text.length == 2 && !text.contains('/')) {
        _vencimientoController.value = TextEditingValue(
          text: '$text/',
          selection: TextSelection.collapsed(offset: 3),
        );
      }
    });
  }

  // Genera el comprobante de pago como PDF
  Future<Uint8List> generarPDFBytes() async {
    final pdf = pw.Document(); // Crea documento PDF

    // Carga el logo del evento desde los assets
    pw.ImageProvider? logoImage;
    try {
      final logoData = await rootBundle.load('lib/assets/logos/sandrixEIRL.jpg');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      print('Logo no encontrado o error cargando: $e');
    }

    // Prepara los datos para mostrar en el comprobante
    final numeroFinal = numero.length >= 4 ? numero.substring(numero.length - 4) : '****';
    final nombreFinal = nombre.isNotEmpty ? nombre : 'Nombre no especificado';
    final tipoEntrada = widget.entrada['tipo'] ?? 'Entrada no definida';
    final precioEntrada = widget.entrada['precio'] ?? '---';
    final beneficioEntrada = widget.entrada['beneficio'] ?? '---';

    // Agrega una página con la información al PDF
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logoImage != null)
              pw.Center(child: pw.Image(logoImage, width: 120)),
            pw.SizedBox(height: 16),
            pw.Text(r'$andrix Eventos & Producciones EIRL',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Comprobante de Pago'),
            pw.Divider(),
            pw.Text('Entrada: $tipoEntrada'),
            pw.Text('Precio: $precioEntrada'),
            pw.Text('Beneficio: $beneficioEntrada'),
            pw.SizedBox(height: 12),
            pw.Text('Tarjeta: **** **** **** $numeroFinal'),
            pw.Text('Nombre del Titular: $nombreFinal'),
            pw.Text('Fecha: ${DateTime.now()}'),
          ],
        ),
      ),
    );

    return pdf.save(); // Devuelve los bytes del PDF generado
  }

  // Muestra un mensaje en pantalla (snack bar)
  void mostrarSnackBar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // Comparte el PDF por WhatsApp (o lo que permita el dispositivo)
  void enviarPDFPorWhatsapp() async {
    final nro = _whatsappController.text.trim();
    if (nro.isEmpty) {
      mostrarSnackBar('Ingresá un número válido');
      return;
    }

    try {
      final bytes = await generarPDFBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: r'comprobante_$andrix.pdf',
      );
      mostrarSnackBar('Compartido exitosamente por WhatsApp');
    } catch (e) {
      mostrarSnackBar('Ocurrió un error al generar o compartir el PDF');
    }
  }

  // Se llama al cerrar la pantalla para liberar memoria
  @override
  void dispose() {
    _whatsappController.dispose();
    _vencimientoController.dispose();
    super.dispose();
  }

  // Crea el diseño visual de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pago con Tarjeta')),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Si ya se realizó el pago, se muestra un mensaje de éxito
        child: pagado
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Text('🎉 ¡Pago Exitoso!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),

                    // Botón para ver/descargar el comprobante
                    ElevatedButton.icon(
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text('Ver/Descargar Comprobante'),
                      onPressed: () async {
                        try {
                          await Printing.layoutPdf(onLayout: (format) => generarPDFBytes());
                        } catch (e) {
                          mostrarSnackBar('No se pudo mostrar el comprobante');
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // Campo para ingresar número de WhatsApp
                    TextField(
                      controller: _whatsappController,
                      decoration: InputDecoration(
                        labelText: 'Número de WhatsApp',
                        prefixIcon: Icon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366)),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12),

                    // Botón para compartir el PDF
                    ElevatedButton.icon(
                      icon: Icon(Icons.share),
                      label: Text('Compartir por WhatsApp'),
                      onPressed: enviarPDFPorWhatsapp,
                    ),
                  ],
                ),
              )

            // Si el pago aún no fue hecho, muestra el formulario
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text('💳 Ingreso de Datos de Tarjeta',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 16),
                    Text('Pago para: ${widget.entrada['tipo']}'),
                    SizedBox(height: 16),

                    // Campo número de tarjeta
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Número de Tarjeta'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => numero = value ?? '',
                      validator: (value) =>
                          value!.length < 16 ? 'Debe tener al menos 16 dígitos' : null,
                    ),

                    // Campo nombre del titular
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Nombre del Titular'),
                      onSaved: (value) => nombre = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Ingresá nombre del titular' : null,
                    ),

                    // Campo vencimiento con validación de formato MM/AA
                    TextFormField(
                      controller: _vencimientoController,
                      decoration: const InputDecoration(labelText: 'Vencimiento (MM/AA)'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => vencimiento = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresá una fecha';

                        final parts = value.split('/');
                        if (parts.length != 2) return 'Formato inválido. Usá MM/AA';

                        final mes = int.tryParse(parts[0]);
                        final anio = int.tryParse(parts[1]);

                        if (mes == null || anio == null || mes < 1 || mes > 12)
                          return 'Mes o año inválido';

                        final now = DateTime.now();
                        final fechaIngresada = DateTime(2000 + anio, mes);

                        if (fechaIngresada.isBefore(DateTime(now.year, now.month)))
                          return 'La fecha ya expiró';

                        return null;
                      },
                    ),

                    //