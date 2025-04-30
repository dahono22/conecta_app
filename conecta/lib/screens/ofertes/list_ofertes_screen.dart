// Importació dels paquets necessaris
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

// Definició de la pantalla d'ofertes (amb estat)
class ListOfertesScreen extends StatefulWidget {
  const ListOfertesScreen({super.key});

  @override
  State<ListOfertesScreen> createState() => _ListOfertesScreenState();
}

class _ListOfertesScreenState extends State<ListOfertesScreen> {
  final TextEditingController _searchController = TextEditingController(); // Controlador pel text de cerca
  String? _selectedUbicacio; // Filtre per ubicació seleccionada

  @override
  void initState() {
    super.initState();
    // Es re-renderitza la pantalla cada vegada que canvia el text de cerca
    _searchController.addListener(() => setState(() {}));
  }

  // Funció per filtrar les ofertes segons la cerca i la ubicació
  List<DocumentSnapshot> _filtrarOfertes(
    List<DocumentSnapshot> ofertes,
    String query,
    String? ubicacio,
  ) {
    return ofertes.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final matchText = query.isEmpty ||
          data['titol'].toString().toLowerCase().contains(query) ||
          data['descripcio'].toString().toLowerCase().contains(query);
      final matchUbicacio = ubicacio == null ||
          ubicacio == 'Totes' ||
          data['ubicacio'].toString().toLowerCase() == ubicacio.toLowerCase();
      return matchText && matchUbicacio;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Alliberar recursos del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase(); // Cerca en minúscules

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Ofertes disponibles'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Camp de cerca per paraula clau
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar per paraula clau',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // Filtre per ubicació (amb menú desplegable)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('ofertes').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox(); // Si no hi ha dades, no es mostra res

                // Obtenim una llista d’ubicacions úniques
                final ubicacions = snapshot.data!.docs
                    .map((doc) => (doc.data() as Map<String, dynamic>)['ubicacio'] as String)
                    .toSet()
                    .toList()
                  ..sort(); // Ordenem les ubicacions alfabèticament

                return DropdownButtonFormField<String>(
                  value: _selectedUbicacio ?? 'Totes', // Valor inicial
                  decoration: InputDecoration(
                    labelText: 'Filtrar per ubicació',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  items: ['Totes', ...ubicacions].map((ubicacio) {
                    return DropdownMenuItem(
                      value: ubicacio,
                      child: Text(ubicacio),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUbicacio = value; // Actualitza el filtre
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Llista d’ofertes (amb filtratge en temps real)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ofertes')
                  .orderBy('dataPublicacio', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hi ha cap oferta.'));
                }

                // Aplicar filtres de cerca i ubicació
                final filtrades = _filtrarOfertes(
                  snapshot.data!.docs,
                  query,
                  _selectedUbicacio,
                );

                if (filtrades.isEmpty) {
                  return const Center(child: Text('No hi ha coincidències.'));
                }

                // Mostrar les ofertes filtrades
                return ListView.builder(
                  itemCount: filtrades.length,
                  itemBuilder: (context, index) {
                    final data = filtrades[index].data() as Map<String, dynamic>;
                    final id = filtrades[index].id;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        title: Text(
                          data['titol'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${data['empresa'] ?? ''} - ${data['ubicacio'] ?? ''}'),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.detallOferta, // Navega al detall de l’oferta
                            arguments: id, // Passa l’ID com argument
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
    );
  }
}
