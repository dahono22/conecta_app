import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';

class MevesOfertesScreen extends StatelessWidget {
  const MevesOfertesScreen({super.key});

  void _confirmarEliminacio(BuildContext context, String ofertaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar oferta'),
        content: const Text('Estàs segur que vols eliminar aquesta oferta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context); // Tancar el diàleg
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
                  SnackBar(content: Text('Error en eliminar l\'oferta: $e')),
                );
              }
            },
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
      appBar: AppBar(title: const Text('Les meves ofertes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ofertes')
            .where('empresaId', isEqualTo: usuari.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Encara no has publicat cap oferta.'));
          }

          final ofertes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ofertes.length,
            itemBuilder: (context, index) {
              final doc = ofertes[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['titol'] ?? 'Sense títol'),
                  subtitle: Text('Ubicació: ${data['ubicacio'] ?? 'Desconeguda'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar oferta',
                    onPressed: () => _confirmarEliminacio(context, doc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
