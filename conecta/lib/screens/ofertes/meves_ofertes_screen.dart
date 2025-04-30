// Importació dels paquets necessaris
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'aplicacions_oferta_screen.dart';
import 'editar_oferta_screen.dart';

// Pantalla sense estat que mostra les ofertes publicades per l'empresa usuària
class MevesOfertesScreen extends StatelessWidget {
  const MevesOfertesScreen({super.key});

  // Funció per confirmar amb l'usuari si vol eliminar una oferta
  void _confirmarEliminacio(BuildContext context, String ofertaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar oferta'),
        content: const Text('Estàs segur que vols eliminar aquesta oferta?'),
        actions: [
          // Botó per cancel·lar l'acció
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar'),
          ),
          // Botó per confirmar i eliminar l'oferta
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context); // Tanca el diàleg
              try {
                await FirebaseFirestore.instance
                    .collection('ofertes')
                    .doc(ofertaId)
                    .delete(); // Elimina l'oferta

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Oferta eliminada correctament.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error en eliminar l\'oferta: $e')),
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
    // Obtenir l'usuari actual a través del proveïdor d'autenticació
    final usuari = context.read<AuthService>().usuariActual;

    // Si no hi ha cap usuari (error greu), es mostra un missatge
    if (usuari == null) {
      return const Scaffold(
        body: Center(child: Text('No s\'ha pogut obtenir l\'usuari actual.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Les meves ofertes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      // StreamBuilder per escoltar canvis en temps real a les ofertes de l'empresa
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ofertes')
            .where('empresaId', isEqualTo: usuari.id) // Només les ofertes de l'usuari actual
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

          // Construcció de la llista de les ofertes
          return ListView.builder(
            itemCount: ofertes.length,
            itemBuilder: (context, index) {
              final doc = ofertes[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Text(
                    data['titol'] ?? 'Sense títol',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('Ubicació: ${data['ubicacio'] ?? 'Desconeguda'}'),
                  // Botons d'edició i eliminació
                  trailing: Wrap(
                    spacing: 4,
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
                  // En tocar la llista, es mostra la pantalla d'aplicacions d'aquesta oferta
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
    );
  }
}
