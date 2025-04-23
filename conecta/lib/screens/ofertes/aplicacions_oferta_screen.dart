import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/auth_service.dart';
import '../chat/chat_screen.dart';

class AplicacionsOfertaScreen extends StatelessWidget {
  final String ofertaId;

  const AplicacionsOfertaScreen({super.key, required this.ofertaId});

  Future<List<Map<String, dynamic>>> _carregarEstudiants() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('aplicacions')
        .where('ofertaId', isEqualTo: ofertaId)
        .get();

    final List<String> usuariIds =
        snapshot.docs.map((doc) => doc['usuariId'] as String).toList();

    if (usuariIds.isEmpty) return [];

    final usuarisSnapshot = await FirebaseFirestore.instance
        .collection('usuaris')
        .where(FieldPath.documentId, whereIn: usuariIds)
        .get();

    return usuarisSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nom': data['nom'],
        'email': data['email'],
        'cvUrl': data['cvUrl'],
      };
    }).toList();
  }

  Future<void> _iniciarXatPerEmpresa(
    BuildContext context, {
    required String ofertaId,
    required String empresaId,
    required String alumneId,
  }) async {
    final aplicacions = await FirebaseFirestore.instance
        .collection('aplicacions')
        .where('ofertaId', isEqualTo: ofertaId)
        .where('usuariId', isEqualTo: alumneId)
        .get();

    if (aplicacions.docs.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            ofertaId: ofertaId,
            empresaId: empresaId,
            alumneId: alumneId,
            usuariActualId: empresaId,
          ),
        ),
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aquest alumne encara no ha aplicat.')),
        );
      }
    }
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
    final empresa = Provider.of<AuthService>(context, listen: false).usuariActual;
    final empresaId = empresa?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Estudiants aplicats'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _carregarEstudiants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final estudiants = snapshot.data ?? [];

          if (estudiants.isEmpty) {
            return const Center(
              child: Text(
                'Encara no hi ha aplicacions.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: estudiants.length,
            itemBuilder: (context, index) {
              final est = estudiants[index];
              final nom = est['nom'] ?? 'Nom desconegut';
              final email = est['email'] ?? 'Email desconegut';
              final cvUrl = est['cvUrl'];
              final alumneId = est['id'] ?? '';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: const Icon(Icons.person, size: 32),
                  title: Text(
                    nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(email),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      if (cvUrl != null && cvUrl.toString().isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          tooltip: 'Veure CV',
                          onPressed: () => _obrirCV(context, cvUrl),
                        ),
                      IconButton(
                        icon: const Icon(Icons.chat, color: Colors.blueAccent),
                        tooltip: 'Iniciar xat',
                        onPressed: () => _iniciarXatPerEmpresa(
                          context,
                          ofertaId: ofertaId,
                          empresaId: empresaId,
                          alumneId: alumneId,
                        ),
                      ),
                    ],
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
