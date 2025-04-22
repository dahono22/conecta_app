import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';

class MevesOfertesScreen extends StatelessWidget {
  const MevesOfertesScreen({super.key});

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
            .orderBy('dataPublicacio', descending: true)
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
              final data = ofertes[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['titol'] ?? 'Sense títol'),
                  subtitle: Text('Ubicació: ${data['ubicacio'] ?? 'Desconeguda'}'),
                  trailing: Text(
                    data['estat']?.toUpperCase() ?? 'PENDENT',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
