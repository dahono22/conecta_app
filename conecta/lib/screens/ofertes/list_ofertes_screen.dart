import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class ListOfertesScreen extends StatefulWidget {
  const ListOfertesScreen({super.key});

  @override
  State<ListOfertesScreen> createState() => _ListOfertesScreenState();
}

class _ListOfertesScreenState extends State<ListOfertesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedUbicacio;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('ofertes').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final ubicacions = snapshot.data!.docs
                    .map((doc) => (doc.data() as Map<String, dynamic>)['ubicacio'] as String)
                    .toSet()
                    .toList()
                  ..sort();

                return DropdownButtonFormField<String>(
                  value: _selectedUbicacio ?? 'Totes',
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
                      _selectedUbicacio = value;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
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

                final filtrades = _filtrarOfertes(
                  snapshot.data!.docs,
                  query,
                  _selectedUbicacio,
                );

                if (filtrades.isEmpty) {
                  return const Center(child: Text('No hi ha coincidències.'));
                }

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
    );
  }
}
