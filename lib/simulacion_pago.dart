import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SimulacionPagoPage extends StatefulWidget {
  final Map<String, String> entrada;

  SimulacionPagoPage({required this.entrada});

  @override
  State<SimulacionPagoPage> createState() => _SimulacionPagoPageState();
}

class _SimulacionPagoPageState extends State<SimulacionPagoPage> {
  final _formKey = GlobalKey<FormState>();
  final _whatsappController = TextEditingController();

  String numero = '';
  String nombre = '';
  String vencimiento = '';
  String codigo = '';
  bool pagado = false;

  Future<Uint8List> generarPDFBytes() async {
    final pdf = pw.Document();

    // Intentara cargar el logo, pero continuar sin él si falla
    pw.ImageProvider? logoImage;
    try {
      final logoData =
          await rootBundle.load('lib/assets/logos/sandrixEIRL.jpg');
      print('Logo cargado correctamente');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      print('Logo no encontrado o error cargando: $e');
    }

    final numeroFinal =
        numero.length >= 4 ? numero.substring(numero.length - 4) : '****';
    final nombreFinal = nombre.isNotEmpty ? nombre : 'Nombre no especificado';
    final tipoEntrada = widget.entrada['tipo'] ?? 'Entrada no definida';
    final precioEntrada = widget.entrada['precio'] ?? '---';
    final beneficioEntrada = widget.entrada['beneficio'] ?? '---';

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logoImage != null)
              pw.Center(child: pw.Image(logoImage, width: 120)),
            pw.SizedBox(height: 16),
            pw.Text(r'$andrix Eventos & Producciones EIRL',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
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

    return pdf.save();
  }

  void mostrarSnackBar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

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
      print('Error al compartir: $e');
    }
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pago con Tarjeta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pagado
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Text('🎉 ¡Pago Exitoso!',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text('Ver/Descargar Comprobante'),
                      onPressed: () async {
                        try {
                          await Printing.layoutPdf(
                            onLayout: (format) => generarPDFBytes(),
                          );
                        } catch (e) {
                          mostrarSnackBar('No se pudo mostrar el comprobante');
                          print('Error mostrando comprobante: $e');
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _whatsappController,
                      decoration: InputDecoration(
                        labelText: 'Número de WhatsApp',
                        prefixIcon: Icon(FontAwesomeIcons.whatsapp,
                            color: Color(0xFF25D366)),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: Icon(Icons.share),
                      label: Text('Compartir por WhatsApp'),
                      onPressed: enviarPDFPorWhatsapp,
                    ),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text('💳 Ingreso de Datos de Tarjeta',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 16),
                    Text('Pago para: ${widget.entrada['tipo']}'),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Número de Tarjeta'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => numero = value ?? '',
                      validator: (value) => value!.length < 16
                          ? 'Debe tener al menos 16 dígitos'
                          : null,
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Nombre del Titular'),
                      onSaved: (value) => nombre = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Ingresá nombre del titular' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Vencimiento (MM/AA)'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => vencimiento = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresá una fecha';
                        }

                        final parts = value.split('/');
                        if (parts.length != 2) {
                          return 'Formato inválido. Usá MM/AA';
                        }

                        final mes = int.tryParse(parts[0]);
                        final anio = int.tryParse(parts[1]);

                        if (mes == null ||
                            anio == null ||
                            mes < 1 ||
                            mes > 12) {
                          return 'Mes o año inválido';
                        }

                        final now = DateTime.now();
                        final fechaIngresada = DateTime(2000 + anio, mes);

                        if (fechaIngresada
                            .isBefore(DateTime(now.year, now.month))) {
                          return 'La fecha ya expiró';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Código de Seguridad'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => codigo = value ?? '',
                      validator: (value) =>
                          value!.length != 3 ? 'Debe tener 3 dígitos' : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            pagado = true;
                          });
                        }
                      },
                      child: Text('Confirmar Pago'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
