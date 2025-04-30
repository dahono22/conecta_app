import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'chat_screen.dart';

// Pantalla que mostra totes les converses actives de l'alumne actual
class ConversesAlumneScreen extends StatelessWidget {
  const ConversesAlumneScreen({super.key});

  // Funció auxiliar per obtenir el nom de l'empresa donat el seu ID
  Future<String> _getNomEmpresa(String empresaId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuaris')
        .doc(empresaId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      return data?['nom'] ?? 'Empresa desconeguda'; // Nom per defecte si no es troba
    } else {
      return 'Empresa eliminada'; // En cas que l'empresa s'hagi eliminat
    }
  }

  @override
  Widget build(BuildContext context) {
    final alumne = Provider.of<AuthService>(context).usuariActual; // Obté l'usuari actual del context
    final alumneId = alumne?.id ?? ''; // ID de l'alumne (buit si null)

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
            .where('alumneId', isEqualTo: alumneId) // Filtra missatges de l’alumne
            .orderBy('timestamp', descending: true) // Missatges més recents primer
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('🔥 Error: ${snapshot.error}');
            return const Center(child: Text('Error carregant converses.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final missatges = snapshot.data!.docs;

          // Agrupació de missatges per clau única: ofertaId + empresaId
          final Map<String, Map<String, dynamic>> conversesMap = {};

          for (final doc in missatges) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['timestamp'] == null) continue; // Evita entrades sense temps

            final key = '${data['ofertaId']}_${data['empresaId']}'; // Clau de conversa

            // Guarda només el primer missatge (el més recent per ordre invers)
            if (!conversesMap.containsKey(key)) {
              conversesMap[key] = {
                'ofertaId': data['ofertaId'],
                'empresaId': data['empresaId'],
                'text': data['text'],
                'timestamp': data['timestamp'],
              };
            }
          }

          final converses = conversesMap.entries.toList(); // Converses agrupades

          if (converses.isEmpty) {
            return const Center(child: Text('Encara no tens cap conversa.'));
          }

          // Mostra la llista de converses amb una targeta per cada una
          return ListView.builder(
            itemCount: converses.length,
            itemBuilder: (context, index) {
              final conv = converses[index].value;
              final ofertaId = conv['ofertaId'];
              final empresaId = conv['empresaId'];
              final text = conv['text'];

              // S’obté el nom de l’empresa de forma asíncrona
              return FutureBuilder<String>(
                future: _getNomEmpresa(empresaId),
                builder: (context, snapshot) {
                  final nomEmpresa =
                      snapshot.connectionState == ConnectionState.done
                          ? snapshot.data ?? 'Empresa'
                          : 'Carregant...'; // Nom provisional mentre es carrega

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      title: Text(
                        'Conversa amb $nomEmpresa',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        text ?? '', // Missatge més recent (resumit)
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Tallar si és massa llarg
                      ),
                      onTap: () {
                        // Navegació cap a la pantalla de xat entre alumne i empresa
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              ofertaId: ofertaId,
                              empresaId: empresaId,
                              alumneId: alumneId,
                              usuariActualId: alumneId, // L’alumne és l’autor en aquest cas
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
