import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditarOfertaScreen extends StatefulWidget {
  final String ofertaId;
  final Map<String, dynamic> data;

  const EditarOfertaScreen({
    super.key,
    required this.ofertaId,
    required this.data,
  });

  @override
  State<EditarOfertaScreen> createState() => _EditarOfertaScreenState();
}

class _EditarOfertaScreenState extends State<EditarOfertaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titolController;
  late TextEditingController _descripcioController;
  late TextEditingController _requisitsController;
  late TextEditingController _ubicacioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titolController = TextEditingController(text: widget.data['titol']);
    _descripcioController = TextEditingController(text: widget.data['descripcio']);
    _requisitsController = TextEditingController(text: widget.data['requisits']);
    _ubicacioController = TextEditingController(text: widget.data['ubicacio']);
  }

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

  Future<void> _actualitzarOferta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oferta actualitzada correctament')),
        );
      }
    } catch (e) {
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
              TextFormField(
                controller: _titolController,
                decoration: _inputDecoration('Títol'),
                validator: (v) => v == null || v.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcioController,
                decoration: _inputDecoration('Descripció'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _requisitsController,
                decoration: _inputDecoration('Requisits'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ubicacioController,
                decoration: _inputDecoration('Ubicació'),
              ),
              const SizedBox(height: 28),
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
