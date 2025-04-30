// Importació de paquets necessaris
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Pantalla amb estat per editar una oferta de treball
class EditarOfertaScreen extends StatefulWidget {
  final String ofertaId; // ID de l’oferta a editar
  final Map<String, dynamic> data; // Dades actuals de l’oferta

  const EditarOfertaScreen({
    super.key,
    required this.ofertaId,
    required this.data,
  });

  @override
  State<EditarOfertaScreen> createState() => _EditarOfertaScreenState();
}

class _EditarOfertaScreenState extends State<EditarOfertaScreen> {
  final _formKey = GlobalKey<FormState>(); // Clau per validar el formulari

  // Controladors de text pels camps del formulari
  late TextEditingController _titolController;
  late TextEditingController _descripcioController;
  late TextEditingController _requisitsController;
  late TextEditingController _ubicacioController;

  bool _isSaving = false; // Estat per indicar si s’està guardant

  @override
  void initState() {
    super.initState();
    // Inicialització dels controladors amb les dades existents
    _titolController = TextEditingController(text: widget.data['titol']);
    _descripcioController = TextEditingController(text: widget.data['descripcio']);
    _requisitsController = TextEditingController(text: widget.data['requisits']);
    _ubicacioController = TextEditingController(text: widget.data['ubicacio']);
  }

  // Decoració reutilitzable per als inputs
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  // Funció per actualitzar les dades de l’oferta a Firestore
  Future<void> _actualitzarOferta() async {
    if (!_formKey.currentState!.validate()) return; // Valida el formulari

    setState(() => _isSaving = true); // Indica que s’està guardant

    try {
      await FirebaseFirestore.instance
          .collection('ofertes')
          .doc(widget.ofertaId)
          .update({
        'titol': _titolController.text.trim(),
        'descripcio': _descripcioController.text.trim(),
        'requisits': _requisitsController.text.trim(),
        'ubicacio': _ubicacioController.text.trim(),
      });

      if (context.mounted) {
        Navigator.pop(context); // Tanca la pantalla
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oferta actualitzada correctament')),
        );
      }
    } catch (e) {
      // Mostra un error en cas de fallida
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Editar oferta'),
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
              // Camp de títol
              TextFormField(
                controller: _titolController,
                decoration: _inputDecoration('Títol'),
                validator: (v) => v == null || v.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),

              // Camp de descripció
              TextFormField(
                controller: _descripcioController,
                decoration: _inputDecoration('Descripció'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),

              // Camp de requisits (no obligatori)
              TextFormField(
                controller: _requisitsController,
                decoration: _inputDecoration('Requisits'),
              ),
              const SizedBox(height: 16),

              // Camp de ubicació
              TextFormField(
                controller: _ubicacioController,
                decoration: _inputDecoration('Ubicació'),
              ),
              const SizedBox(height: 28),

              // Botó per guardar canvis
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _actualitzarOferta,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Guardant...' : 'Guardar canvis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
