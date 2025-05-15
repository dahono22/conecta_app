// lib/screens/ofertes/crear_oferta_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/offer_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../models/oferta.dart'; // Para enums

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

  // Campos relacionados
  List<String> _selectedFields = [];
  String? _fieldsError;

  // Nuevos filtros/form inputs
  String? _selectedModalidad;
  bool _dualIntensiva = false;
  bool _remunerada = false;
  String? _selectedDuracion;
  bool _experienciaRequerida = false;
  String? _selectedJornada;
  bool _curso1 = false;
  bool _curso2 = false;

  bool _isSubmitting = false;

  void _toggleField(String campo) {
    setState(() {
      if (_selectedFields.contains(campo)) {
        _selectedFields.remove(campo);
      } else {
        _selectedFields.add(campo);
      }
    });
  }

  Future<void> _crearOferta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFields.isEmpty) {
      setState(() => _fieldsError = 'Selecciona com a mínim un camp');
      return;
    }
    if (_selectedModalidad == null ||
        _selectedDuracion == null ||
        _selectedJornada == null) {
      // Puedes afinar mensaje según cada campo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa tots els camps obligatoris')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _fieldsError = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final offerService = Provider.of<OfferService>(context, listen: false);
    final usuari = authService.usuariActual!;
    final cursos = <String>[];
    if (_curso1) cursos.add('1r');
    if (_curso2) cursos.add('2º');

    try {
      await offerService.crearOferta(
        titol: _titolController.text.trim(),
        descripcio: _descripcioController.text.trim(),
        requisits: _requisitsController.text.trim(),
        ubicacio: _ubicacioController.text.trim(),
        empresaId: usuari.id,
        campos: _selectedFields,
        modalidad: _selectedModalidad!.toLowerCase(),
        dualIntensiva: _dualIntensiva,
        remunerada: _remunerada,
        duracion: _selectedDuracion!,
        experienciaRequerida: _experienciaRequerida,
        jornada: _selectedJornada!.toLowerCase(),
        cursosDestinatarios: cursos,
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
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                maxLines: 4,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),
              // Requisits
              TextFormField(
                controller: _requisitsController,
                decoration: _inputDecoration('Requisits'),
                maxLines: 3,
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
                  final selected = _selectedFields.contains(campo);
                  return FilterChip(
                    label: Text(campo),
                    selected: selected,
                    onSelected: (_) => _toggleField(campo),
                  );
                }).toList(),
              ),
              if (_fieldsError != null) ...[
                const SizedBox(height: 6),
                Text(_fieldsError!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 12)),
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
                validator: (v) =>
                    v == null ? 'Camp obligatori' : null,
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
                validator: (v) =>
                    v == null ? 'Camp obligatori' : null,
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
                validator: (v) =>
                    v == null ? 'Camp obligatori' : null,
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
              const SizedBox(height: 24),

              // Botó per publicar
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
