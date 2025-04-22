import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/offer_service.dart';
import '../../services/auth_service.dart';

class CrearOfertaScreen extends StatefulWidget {
  const CrearOfertaScreen({super.key});

  @override
  State<CrearOfertaScreen> createState() => _CrearOfertaScreenState();
}

class _CrearOfertaScreenState extends State<CrearOfertaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titolController = TextEditingController();
  final _descripcioController = TextEditingController();
  final _requisitsController = TextEditingController();
  final _ubicacioController = TextEditingController();

  Future<void> _crearOferta() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final offerService = Provider.of<OfferService>(context, listen: false);
    final usuari = authService.usuariActual;

    if (usuari == null) return;

    try {
      await offerService.crearOferta(
        titol: _titolController.text.trim(),
        descripcio: _descripcioController.text.trim(),
        requisits: _requisitsController.text.trim(),
        ubicacio: _ubicacioController.text.trim(),
        empresaId: usuari.id,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oferta creada correctament')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en crear l\'oferta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova oferta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titolController,
                decoration: const InputDecoration(labelText: 'Títol'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcioController,
                decoration: const InputDecoration(labelText: 'Descripció'),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _requisitsController,
                decoration: const InputDecoration(labelText: 'Requisits'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ubicacioController,
                decoration: const InputDecoration(labelText: 'Ubicació'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _crearOferta,
                child: const Text('Publicar oferta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
