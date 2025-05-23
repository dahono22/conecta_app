// Importació dels paquets necessaris
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import 'aplicacions_oferta_screen.dart';
import 'editar_oferta_screen.dart';

/// Pantalla de "Les meves ofertes" amb estil inspirat en HomeEmpresaScreen
class MevesOfertesScreen extends StatelessWidget {
  const MevesOfertesScreen({super.key});

  // Diàleg de confirmació per eliminar una oferta
  void _confirmarEliminacio(BuildContext context, String ofertaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar oferta'),
        content: const Text('Estàs segur que vols eliminar aquesta oferta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('ofertes')
                    .doc(ofertaId)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Oferta eliminada correctament.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error en eliminar l\'oferta: \$e')),
                );
              }
            },
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuari = context.read<AuthService>().usuariActual;
    if (usuari == null) {
      return const Scaffold(
        body: Center(child: Text('No s\'ha pogut obtenir l\'usuari actual.')),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fons amb imatge i capa d'opacitat
          Image.asset('assets/background.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.6)),

          SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Títol principal
                    const Center(
                      child: Text(
                        'Les meves ofertes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Llista d'ofertes
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('ofertes')
                            .where('empresaId', isEqualTo: usuari.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'Encara no has publicat cap oferta.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            );
                          }
                          final ofertes = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: ofertes.length,
                            itemBuilder: (context, index) {
                              final doc = ofertes[index];
                              final data = doc.data() as Map<String, dynamic>;
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 6,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  title: Text(
                                    data['titol'] ?? 'Sense títol',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  subtitle: Text('Ubicació: ${data['ubicacio'] ?? 'Desconeguda'}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                        tooltip: 'Editar oferta',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditarOfertaScreen(
                                                ofertaId: doc.id,
                                                data: data,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        tooltip: 'Eliminar oferta',
                                        onPressed: () => _confirmarEliminacio(context, doc.id),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AplicacionsOfertaScreen(ofertaId: doc.id),
                                      ),
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
            ),
          ),
        ],
      ),
    );
  }
}
