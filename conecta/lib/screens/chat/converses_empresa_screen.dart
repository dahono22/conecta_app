import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'chat_screen.dart';

class ConversesEmpresaScreen extends StatelessWidget {
  const ConversesEmpresaScreen({super.key});

  Future<String> _getNomAlumne(String alumneId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuaris')
        .doc(alumneId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      return data?['nom'] ?? 'Alumne desconegut';
    } else {
      return 'Alumne eliminat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresa = Provider.of<AuthService>(context).usuariActual;
    final empresaId = empresa?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Converses actives'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF4F7FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('missatges_xat')
            .where('empresaId', isEqualTo: empresaId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final missatges = snapshot.data!.docs;

          final Map<String, Map<String, dynamic>> conversesMap = {};

          for (final doc in missatges) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['timestamp'] == null) continue;

            final key = '${data['ofertaId']}_${data['alumneId']}';

            if (!conversesMap.containsKey(key)) {
              conversesMap[key] = {
                'ofertaId': data['ofertaId'],
                'alumneId': data['alumneId'],
                'text': data['text'],
                'timestamp': data['timestamp'],
              };
            }
          }

          final converses = conversesMap.entries.toList();

          if (converses.isEmpty) {
            return const Center(child: Text('No hi ha converses actives.'));
          }

          return ListView.builder(
            itemCount: converses.length,
            itemBuilder: (context, index) {
              final conv = converses[index].value;
              final ofertaId = conv['ofertaId'];
              final alumneId = conv['alumneId'];
              final text = conv['text'];

              return FutureBuilder<String>(
                future: _getNomAlumne(alumneId),
                builder: (context, snapshot) {
                  final nomAlumne =
                      snapshot.connectionState == ConnectionState.done
                          ? snapshot.data ?? 'Alumne'
                          : 'Carregant...';

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12), 
                      title: Text(
                        'Conversa amb $nomAlumne',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        text ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
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
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
