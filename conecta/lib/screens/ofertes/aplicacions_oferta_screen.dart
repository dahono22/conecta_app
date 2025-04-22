import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AplicacionsOfertaScreen extends StatelessWidget {
  final String ofertaId;

  const AplicacionsOfertaScreen({super.key, required this.ofertaId});

  Future<List<Map<String, dynamic>>> _carregarEstudiants() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('aplicacions')
        .where('ofertaId', isEqualTo: ofertaId)
        .get();

    final List<String> usuariIds = snapshot.docs
        .map((doc) => doc['usuariId'] as String)
        .toList();

    if (usuariIds.isEmpty) return [];

    final usuarisSnapshot = await FirebaseFirestore.instance
        .collection('usuaris')
        .where(FieldPath.documentId, whereIn: usuariIds)
        .get();

    return usuarisSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'nom': data['nom'],
        'email': data['email'],
        'cvUrl': data['cvUrl'],
      };
    }).toList();
  }

  void _obrirCV(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No s’ha pogut obrir el currículum.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estudiants aplicats')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _carregarEstudiants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final estudiants = snapshot.data ?? [];

          if (estudiants.isEmpty) {
            return const Center(child: Text('Encara no hi ha aplicacions.'));
          }

          return ListView.builder(
            itemCount: estudiants.length,
            itemBuilder: (context, index) {
              final est = estudiants[index];
              final nom = est['nom'] ?? 'Nom desconegut';
              final email = est['email'] ?? 'Email desconegut';
              final cvUrl = est['cvUrl'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(nom),
                  subtitle: Text(email),
                  trailing: cvUrl != null && cvUrl.toString().isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.visibility),
                          tooltip: 'Veure CV',
                          onPressed: () => _obrirCV(context, cvUrl),
                        )
                      : const Text('Sense CV'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
