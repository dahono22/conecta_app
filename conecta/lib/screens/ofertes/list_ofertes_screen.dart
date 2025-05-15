// lib/screens/ofertes/list_ofertes_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';

class ListOfertesScreen extends StatefulWidget {
  const ListOfertesScreen({super.key});

  @override
  State<ListOfertesScreen> createState() => _ListOfertesScreenState();
}

class _ListOfertesScreenState extends State<ListOfertesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedUbicacio = 'Totes';
  String? _selectedModalidad = 'Totes';
  bool _dualIntensiva = false;
  bool _remunerada = false;
  String? _selectedCampo = 'Tots';
  String? _selectedDuracion = 'Tots';
  String _selectedFecha = 'Totes';
  bool _experienciaRequerida = false;
  String? _selectedEmpresa = 'Totes';
  String _selectedJornada = 'Totes';
  bool _filterCurso1 = false;
  bool _filterCurso2 = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DocumentSnapshot> _filtrarOfertes(List<DocumentSnapshot> docs) {
    final query = _searchController.text.toLowerCase();
    final now = DateTime.now();
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // 1) búsqueda por texto
      final title = (data['titol'] as String? ?? '').toLowerCase();
      final desc = (data['descripcio'] as String? ?? '').toLowerCase();
      if (query.isNotEmpty && !title.contains(query) && !desc.contains(query)) {
        return false;
      }

      // 2) ubicación
      final ubic = (data['ubicacio'] as String? ?? '').toLowerCase();
      if (_selectedUbicacio != 'Totes' &&
          ubic != _selectedUbicacio!.toLowerCase()) {
        return false;
      }

      // 3) modalidad
      final mod = (data['modalidad'] as String? ?? '').toLowerCase();
      if (_selectedModalidad! != 'Totes' &&
          mod != _selectedModalidad!.toLowerCase()) {
        return false;
      }

      // 4) dual intensiva
      if (_dualIntensiva && !(data['dualIntensiva'] as bool? ?? false)) {
        return false;
      }

      // 5) remunerada
      if (_remunerada && !(data['remunerada'] as bool? ?? false)) {
        return false;
      }

      // 6) campo/tags
      final tags = List<String>.from(data['tags'] as List<dynamic>? ?? []);
      if (_selectedCampo != 'Tots' && !tags.contains(_selectedCampo)) {
        return false;
      }

      // 7) duración — ahora comparamos la propia cadena legible
      final dur = (data['duracion'] as String? ?? '').toLowerCase();
      if (_selectedDuracion != 'Tots' &&
          dur != _selectedDuracion!.toLowerCase()) {
        return false;
      }

      // 8) fecha de publicación
      final pubTs = data['dataPublicacio'] as Timestamp?;
      if (pubTs != null) {
        final pub = pubTs.toDate();
        final diff = now.difference(pub);
        if (_selectedFecha == 'Últimes 24h' && diff.inHours > 24) return false;
        if (_selectedFecha == 'Setmana passada' && diff.inDays > 7) return false;
        if (_selectedFecha == 'Mes passat' && diff.inDays > 30) return false;
      }

      // 9) experiencia requerida
      if (_experienciaRequerida &&
          !(data['experienciaRequerida'] as bool? ?? false)) {
        return false;
      }

      // 10) empresa específica
      final emp = (data['empresa'] as String? ?? '');
      if (_selectedEmpresa != 'Totes' && emp != _selectedEmpresa) {
        return false;
      }

      // 11) jornada
      final jor = (data['jornada'] as String? ?? '').toLowerCase();
      if (_selectedJornada != 'Totes' &&
          jor != _selectedJornada.toLowerCase()) {
        return false;
      }

      // 12) cursos destinatarios
      final cursos =
          List<String>.from(data['cursosDestinatarios'] as List<dynamic>? ?? []);
      if (_filterCurso1 && !cursos.contains('1r')) return false;
      if (_filterCurso2 && !cursos.contains('2º')) return false;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.homeEstudiant),
        ),
        title: const Text('Ofertes', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight),
                // Panel de filtros
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Filtrar ofertes',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // Búsqueda
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Paraula clau',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Ubicación y Modalidad en fila
                        Row(
                          children: [
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('ofertes')
                                    .snapshots(),
                                builder: (c, s) {
                                  final docs = s.data?.docs ?? [];
                                  final ubicacions = docs
                                      .map((d) =>
                                          (d.data() as Map)['ubicacio']
                                              as String)
                                      .toSet()
                                      .toList()
                                    ..sort();
                                  return DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: _selectedUbicacio,
                                    decoration:
                                        _dropdownDecoration('Ubicació'),
                                    items: ['Totes', ...ubicacions]
                                        .map((u) => DropdownMenuItem(
                                              value: u,
                                              child: Text(u),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedUbicacio = v),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedModalidad,
                                decoration:
                                    _dropdownDecoration('Modalitat'),
                                items: Constants.modalidadOptions
                                    .map((m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(m),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(
                                    () => _selectedModalidad = v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Dual intensiva y Remunerada
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Dual intensiva'),
                                value: _dualIntensiva,
                                onChanged: (v) => setState(
                                    () => _dualIntensiva = v!),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Remunerada'),
                                value: _remunerada,
                                onChanged: (v) => setState(
                                    () => _remunerada = v!),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Campo y Duración
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedCampo,
                                decoration: _dropdownDecoration('Camp'),
                                items: ['Tots', ...Constants.camposDisponibles]
                                    .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedCampo = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedDuracion,
                                decoration:
                                    _dropdownDecoration('Duració'),
                                items: Constants.duracionOptions
                                    .map((d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(d),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedDuracion = v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Fecha de publicación
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedFecha,
                          decoration:
                              _dropdownDecoration('Publicació'),
                          items: Constants.fechaPublicacionOptions
                              .map((f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(f),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedFecha = v!),
                        ),
                        const SizedBox(height: 12),
                        // Experiencia requerida
                        CheckboxListTile(
                          title: const Text('Requereix experiència'),
                          value: _experienciaRequerida,
                          onChanged: (v) => setState(
                              () => _experienciaRequerida = v!),
                          controlAffinity:
                              ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 12),
                        // Empresa específica y Jornada
                        Row(
                          children: [
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('ofertes')
                                    .snapshots(),
                                builder: (c, s) {
                                  final docs = s.data?.docs ?? [];
                                  final empresas = docs
                                      .map((d) =>
                                          (d.data() as Map)['empresa']
                                              as String)
                                      .toSet()
                                      .toList()
                                    ..sort();
                                  return DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: _selectedEmpresa,
                                    decoration:
                                        _dropdownDecoration('Empresa'),
                                    items: ['Totes', ...empresas]
                                        .map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setState(
                                        () => _selectedEmpresa = v),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedJornada,
                                decoration:
                                    _dropdownDecoration('Jornada'),
                                items: Constants.jornadaOptions
                                    .map((j) => DropdownMenuItem(
                                          value: j,
                                          child: Text(j),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedJornada = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Curso destinatario
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('1r curs'),
                                value: _filterCurso1,
                                onChanged: (v) => setState(
                                    () => _filterCurso1 = v!),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('2º curs'),
                                value: _filterCurso2,
                                onChanged: (v) => setState(
                                    () => _filterCurso2 = v!),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Listado filtrado
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('ofertes')
                        .orderBy('dataPublicacio', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data?.docs ?? [];
                      final filtrades = _filtrarOfertes(docs);
                      if (filtrades.isEmpty) {
                        return const Center(
                            child: Text('No hi ha coincidències.'));
                      }
                      return ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtrades.length,
                        itemBuilder: (context, index) {
                          final data = filtrades[index]
                              .data() as Map<String, dynamic>;
                          final id = filtrades[index].id;
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16)),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                              title: Text(
                                data['titol'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${data['empresa'] ?? ''} - ${data['ubicacio'] ?? ''}',
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.detallOferta,
                                  arguments: id,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
