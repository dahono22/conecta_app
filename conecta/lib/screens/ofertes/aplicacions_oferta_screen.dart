// lib/screens/ofertes/aplicacions_oferta_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/auth_service.dart';
import '../chat/chat_screen.dart';

/// Pantalla d'estudiants aplicats amb estil coherent a HomeEmpresaScreen
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

    Map<String, Map<String, dynamic>> usuarisData = {
      for (var doc in usuarisSnapshot.docs) doc.id: doc.data()
    };

    return snapshot.docs.map((doc) {
      final uId = doc['usuariId'];
      final data = usuarisData[uId] ?? {};
      return {
        'aplicacioId': doc.id,
        'usuariId': uId,
        'estat': doc['estat'] ?? 'Nou',
        'nom': data['nom'],
        'email': data['email'],
        'cvUrl': data['cvUrl'],
      };
    }).toList();
  }

  Future<void> _canviarEstat(
      BuildContext ctx, String id, String nouEstat) async {
    try {
      await FirebaseFirestore.instance
          .collection('aplicacions')
          .doc(id)
          .update({'estat': nouEstat});
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Estat actualitzat a "$nouEstat"')));
      }
    } catch (_) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Error en actualitzar l\'estat')));
      }
    }
  }

  Future<void> _mostrarSelectorEstat(
      BuildContext ctx, String aplicId) async {
    final estats = ['Nou', 'En procés', 'Acceptat', 'Rebutjat'];
    await showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shrinkWrap: true,
          children: estats.map((e) => ListTile(
                title: Text(e, style: const TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(ctx);
                  _canviarEstat(ctx, aplicId, e);
                },
              )).toList(),
        );
      },
    );
  }

  Future<void> _obrirCV(BuildContext ctx, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('No s’ha pogut obrir el currículum.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresa = Provider.of<AuthService>(context, listen: false).usuariActual;
    final empresaId = empresa?.id ?? '';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.5)),
          SafeArea(
            child: Column(
              children: [
                // AppBar alternatiu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estudiants Aplicats',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _carregarEstudiants(),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: Colors.white,
                        ));
                      }
                      final list = snap.data ?? [];
                      if (list.isEmpty) {
                        return const Center(
                          child: Text('Encara no hi ha aplicacions.',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500)),
                        );
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          children: list.map((e) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              elevation: 8,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                                  child: const Icon(Icons.person,
                                      size: 28, color: Colors.blueAccent),
                                ),
                                title: Text(e['nom'] ?? 'Nom desconegut',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  '${e['email'] ?? '-'}\nEstat: ${e['estat']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                isThreeLine: true,
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.orangeAccent),
                                      onPressed: () =>
                                          _mostrarSelectorEstat(
                                              ctx, e['aplicacioId']),
                                    ),
                                    if (e['cvUrl'] != null)
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () =>
                                            _obrirCV(ctx, e['cvUrl']),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.chat,
                                          color: Colors.purpleAccent),
                                      onPressed: () {
                                        Navigator.push(
                                          ctx,
                                          MaterialPageRoute(
                                            builder: (_) => ChatScreen(
                                              ofertaId: ofertaId,
                                              empresaId: empresaId,
                                              alumneId: e['usuariId'],
                                              usuariActualId: empresaId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
}