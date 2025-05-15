// lib/screens/ofertes/editar_oferta_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/offer_service.dart';
import '../../utils/constants.dart';

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

  late List<String> _selectedFields;
  String? _fieldsError;

  // Nuevos campos
  String? _selectedModalidad;
  bool _dualIntensiva = false;
  bool _remunerada = false;
  String? _selectedDuracion;
  bool _experienciaRequerida = false;
  String? _selectedJornada;
  bool _curso1 = false;
  bool _curso2 = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.data;
    _titolController = TextEditingController(text: data['titol']);
    _descripcioController = TextEditingController(text: data['descripcio']);
    _requisitsController = TextEditingController(text: data['requisits']);
    _ubicacioController = TextEditingController(text: data['ubicacio']);
    _selectedFields = List<String>.from(data['campos'] ?? []);

    _selectedModalidad = _capitalize(data['modalidad'] as String? ?? 'presencial');
    _dualIntensiva = data['dualIntensiva'] as bool? ?? false;
    _remunerada = data['remunerada'] as bool? ?? false;
    _selectedDuracion = _formatDuracion(data['duracion'] as String? ?? 'meses0_3');
    _experienciaRequerida = data['experienciaRequerida'] as bool? ?? false;
    _selectedJornada = _capitalize(data['jornada'] as String? ?? 'manana');
    final cursos = List<String>.from(data['cursosDestinatarios'] as List<dynamic>? ?? []);
    _curso1 = cursos.contains('1r');
    _curso2 = cursos.contains('2º');
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatDuracion(String raw) {
    switch (raw) {
      case 'meses0_3':
        return '0-3 mesos';
      case 'meses3_6':
        return '3-6 mesos';
      case 'meses6_12':
        return '6-12 mesos';
      default:
        return '0-3 mesos';
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      );

  void _toggleField(String campo) {
    setState(() {
      if (_selectedFields.contains(campo)) {
        _selectedFields.remove(campo);
      } else {
        _selectedFields.add(campo);
      }
    });
  }

  Future<void> _actualitzarOferta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFields.isEmpty) {
      setState(() => _fieldsError = 'Selecciona com a mínim un camp');
      return;
    }
    if (_selectedModalidad == null ||
        _selectedDuracion == null ||
        _selectedJornada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa tots els camps obligatoris')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final cursos = <String>[];
    if (_curso1) cursos.add('1r');
    if (_curso2) cursos.add('2º');

    try {
      await Provider.of<OfferService>(context, listen: false).updateOferta(
        ofertaId: widget.ofertaId,
        titol: _titolController.text.trim(),
        descripcio: _descripcioController.text.trim(),
        requisits: _requisitsController.text.trim(),
        ubicacio: _ubicacioController.text.trim(),
        campos: _selectedFields,
        modalidad: _selectedModalidad!.toLowerCase(),
        dualIntensiva: _dualIntensiva,
        remunerada: _remunerada,
        duracion: _selectedDuracion!.replaceAll(' mesos', '').replaceAll('-', '_meses'),
        experienciaRequerida: _experienciaRequerida,
        jornada: _selectedJornada!.toLowerCase(),
        cursosDestinatarios: cursos,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oferta actualitzada correctament')),
      );
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
              // Títol
              TextFormField(
                controller: _titolController,
                decoration: _inputDecoration('Títol'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),

              // Descripció
              TextFormField(
                controller: _descripcioController,
                decoration: _inputDecoration('Descripció'),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),

              // Requisits
              TextFormField(
                controller: _requisitsController,
                decoration: _inputDecoration('Requisits'),
              ),
              const SizedBox(height: 16),

              // Ubicació
              TextFormField(
                controller: _ubicacioController,
                decoration: _inputDecoration('Ubicació'),
              ),
              const SizedBox(height: 16),

              // Camps relacionats
              const Text(
                'Selecciona els camps relacionats',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: Constants.camposDisponibles.map((campo) {
                  return FilterChip(
                    label: Text(campo),
                    selected: _selectedFields.contains(campo),
                    onSelected: (_) => _toggleField(campo),
                  );
                }).toList(),
              ),
              if (_fieldsError != null) ...[
                const SizedBox(height: 6),
                Text(_fieldsError!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              const SizedBox(height: 24),

              // Modalitat
              DropdownButtonFormField<String>(
                value: _selectedModalidad,
                decoration: _inputDecoration('Modalitat'),
                items: const [
                  'Presencial',
                  'Remoto',
                  'Hibrido',
                ].map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                validator: (v) => v == null ? 'Camp obligatori' : null,
                onChanged: (v) => setState(() => _selectedModalidad = v),
              ),
              const SizedBox(height: 12),

              // Dual intensiva & Remunerada
              CheckboxListTile(
                title: const Text('Dual intensiva'),
                value: _dualIntensiva,
                onChanged: (v) => setState(() => _dualIntensiva = v!),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Remunerada'),
                value: _remunerada,
                onChanged: (v) => setState(() => _remunerada = v!),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),

              // Duració
              DropdownButtonFormField<String>(
                value: _selectedDuracion,
                decoration: _inputDecoration('Duració'),
                items: const [
                  '0-3 mesos',
                  '3-6 mesos',
                  '6-12 mesos',
                ].map((d) {
                  return DropdownMenuItem(value: d, child: Text(d));
                }).toList(),
                validator: (v) => v == null ? 'Camp obligatori' : null,
                onChanged: (v) => setState(() => _selectedDuracion = v),
              ),
              const SizedBox(height: 12),

              // Experiència requerida
              CheckboxListTile(
                title: const Text('Requereix experiència'),
                value: _experienciaRequerida,
                onChanged: (v) =>
                    setState(() => _experienciaRequerida = v!),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),

              // Jornada
              DropdownButtonFormField<String>(
                value: _selectedJornada,
                decoration: _inputDecoration('Jornada'),
                items: const [
                  'Matí',
                  'Tarda',
                ].map((j) {
                  return DropdownMenuItem(value: j, child: Text(j));
                }).toList(),
                validator: (v) => v == null ? 'Camp obligatori' : null,
                onChanged: (v) => setState(() => _selectedJornada = v),
              ),
              const SizedBox(height: 12),

              // Cursos destinataris
              CheckboxListTile(
                title: const Text('1r curs'),
                value: _curso1,
                onChanged: (v) => setState(() => _curso1 = v!),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('2º curs'),
                value: _curso2,
                onChanged: (v) => setState(() => _curso2 = v!),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 28),

              // Botó per guardar
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _actualitzarOferta,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                    _isSaving ? 'Guardant...' : 'Guardar canvis'),
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
