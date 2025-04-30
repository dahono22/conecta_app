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

    final List<String> usuariIds = snapshot.docs.map((doc) => doc['usuariId'] as String).toList();

    if (usuariIds.isEmpty) return [];

    final usuarisSnapshot = await FirebaseFirestore.instance
        .collection('usuaris')
        .where(FieldPath.documentId, whereIn: usuariIds)
        .get();

    Map<String, Map<String, dynamic>> usuarisData = {
      for (var doc in usuarisSnapshot.docs) doc.id: doc.data()
    };

    return snapshot.docs.map((doc) {
      final usuariId = doc['usuariId'];
      final usuariData = usuarisData[usuariId] ?? {};
      return {
        'aplicacioId': doc.id,
        'usuariId': usuariId,
        'estat': doc['estat'] ?? 'Nou',
        'nom': usuariData['nom'],
        'email': usuariData['email'],
        'cvUrl': usuariData['cvUrl'],
      };
    }).toList();
  }

  Future<void> _canviarEstatAplicacio(BuildContext context, String aplicacioId, String nouEstat) async {
    try {
      await FirebaseFirestore.instance.collection('aplicacions').doc(aplicacioId).update({
        'estat': nouEstat,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estat actualitzat a "$nouEstat"')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en actualitzar l\'estat')),
        );
      }
    }
  }

  Future<void> _mostrarSelectorEstat(BuildContext context, String aplicacioId) async {
    final estats = ['Nou', 'En procés', 'Acceptat', 'Rebutjat'];

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: estats.map((estat) {
            return ListTile(
              title: Text(estat),
              onTap: () {
                Navigator.pop(context);
                _canviarEstatAplicacio(context, aplicacioId, estat);
              },
            );
          }).toList(),
        );
      },
    );
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
              final alumneId = est['usuariId'] ?? '';
              final aplicacioId = est['aplicacioId'] ?? '';
              final estat = est['estat'] ?? 'Nou';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: const Icon(Icons.person, size: 32),
                  title: Text(
                    nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('$email\nEstat: $estat'),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Canviar estat',
                        onPressed: () => _mostrarSelectorEstat(context, aplicacioId),
                      ),
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
