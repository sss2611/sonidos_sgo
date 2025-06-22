import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String vencimiento = '';
  String codigo = '';
  bool pagado = false;

  void generarPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Sandrix Eventos S.A',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Comprobante de Pago'),
            pw.Divider(),
            pw.Text('Entrada: ${widget.entrada['tipo']}'),
            pw.Text('Precio: ${widget.entrada['precio']}'),
            pw.Text('Beneficio: ${widget.entrada['beneficio']}'),
            pw.SizedBox(height: 12),
            pw.Text(
                'Tarjeta: **** **** **** ${numero.substring(numero.length - 4)}'),
            pw.Text('Fecha: ${DateTime.now()}'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void enviarPorWhatsApp() async {
    final nro = _whatsappController.text.trim();
    if (nro.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingresá un número válido')),
      );
      return;
    }

    final mensaje = Uri.encodeComponent('''
🎫 *Comprobante Sandrix Eventos S.A*

Entrada: ${widget.entrada['tipo']}
Precio: ${widget.entrada['precio']}
Beneficio: ${widget.entrada['beneficio']}
Tarjeta: **** ${numero.substring(numero.length - 4)}
Fecha: ${DateTime.now()}
''');

    final url = 'https://wa.me/$nro?text=$mensaje';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
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
      appBar: AppBar(title: Text('Simulación de Pago')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pagado
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✅ ¡Pago Exitoso!',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Text('Entrada: ${widget.entrada['tipo']}'),
                    Text('Precio: ${widget.entrada['precio']}'),
                    Text('Beneficio: ${widget.entrada['beneficio']}'),
                    Divider(height: 32),
                    Text('Comprobante generado:'),
                    Text(
                        '• Tarjeta: **** **** **** ${numero.substring(numero.length - 4)}'),
                    Text('• Fecha: ${DateTime.now()}'),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text('Descargar Comprobante PDF'),
                      onPressed: generarPDF,
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: _whatsappController,
                      decoration: InputDecoration(
                        labelText: 'Número de WhatsApp (ej: 549381123456)',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: Icon(Icons.send),
                      label: Text('Enviar por WhatsApp'),
                      onPressed: enviarPorWhatsApp,
                    ),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  children: [
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
                          InputDecoration(labelText: 'Vencimiento (MM/AA)'),
                      onSaved: (value) => vencimiento = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Ingresá una fecha' : null,
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
