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

  @override
  void initState() {
    super.initState();
    _titolController = TextEditingController(text: widget.data['titol']);
    _descripcioController = TextEditingController(text: widget.data['descripcio']);
    _requisitsController = TextEditingController(text: widget.data['requisits']);
    _ubicacioController = TextEditingController(text: widget.data['ubicacio']);
  }

  Future<void> _actualitzarOferta() async {
    if (!_formKey.currentState!.validate()) return;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar oferta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titolController,
                decoration: const InputDecoration(labelText: 'Títol'),
                validator: (v) => v == null || v.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcioController,
                decoration: const InputDecoration(labelText: 'Descripció'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _requisitsController,
                decoration: const InputDecoration(labelText: 'Requisits'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ubicacioController,
                decoration: const InputDecoration(labelText: 'Ubicació'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _actualitzarOferta,
                child: const Text('Guardar canvis'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
