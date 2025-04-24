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
  bool _isSubmitting = false;

  Future<void> _crearOferta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

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
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Nova oferta'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titolController,
                decoration: _inputDecoration('Títol'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcioController,
                decoration: _inputDecoration('Descripció'),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _requisitsController,
                decoration: _inputDecoration('Requisits'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ubicacioController,
                decoration: _inputDecoration('Ubicació'),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _crearOferta,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Publicant...' : 'Publicar oferta',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
