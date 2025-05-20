// lib/screens/ofertes/converses_empresa_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'chat_screen.dart';

/// Pantalla que mostra totes les converses actives de l'empresa amb l'estil de l'app
class ConversesEmpresaScreen extends StatelessWidget {
  const ConversesEmpresaScreen({super.key});

  // Obté el nom de l'alumne pel seu ID
  Future<String> _getNomAlumne(String alumneId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuaris')
        .doc(alumneId)
        .get();
    if (snapshot.exists) {
      return snapshot.data()?['nom'] as String? ?? 'Alumne desconegut';
    } else {
      return 'Alumne eliminat';
    }
  }

  // Obté la clau d'avatar de l'alumne
  Future<String?> _fetchAlumneAvatar(String alumneId) async {
    final doc = await FirebaseFirestore.instance
        .collection('usuaris')
        .doc(alumneId)
        .get();
    return doc.data()?['avatar'] as String?;
  }

  // Construeix un CircleAvatar amb la clau normalitzada
  Widget _buildAlumneAvatar(String alumneId, {double radius = 24}) {
    return FutureBuilder<String?>(
      future: _fetchAlumneAvatar(alumneId),
      builder: (context, snap) {
        // 1) Ruta per defecte
        String asset = 'assets/avatars/default.png';
        // 2) Si tenim clau, la netegem i reconstruïm
        if (snap.hasData && (snap.data?.isNotEmpty ?? false)) {
          var raw = snap.data!;
          // Si ve amb carpeta, ens quedem només amb el nom
          if (raw.contains('/')) raw = raw.split('/').last;
          // Eliminem qualsevol ".png" extra (case-insensitive)
          raw = raw.replaceAll(RegExp(r'\.png$', caseSensitive: false), '');
          asset = 'assets/avatars/$raw.png';
        }
        return CircleAvatar(
          radius: radius,
          backgroundImage: AssetImage(asset),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final empresa = Provider.of<AuthService>(context, listen: false).usuariActual;
    final empresaId = empresa?.id ?? '';

    return Scaffold(
      // Afegim un AppBar amb botó per tornar enrere
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Converses actives',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
          SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('missatges_xat')
                            .where('empresaId', isEqualTo: empresaId)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error carregant converses.'),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final docs = snapshot.data!.docs;
                          // Agrupa per oferta+alumne i agafa el més recent
                          final Map<String, Map<String, dynamic>> convMap = {};
                          for (var doc in docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            if (data['timestamp'] == null) continue;
                            final key = '${data['ofertaId']}_${data['alumneId']}';
                            if (!convMap.containsKey(key)) {
                              convMap[key] = data;
                            }
                          }

                          final converses = convMap.values.toList();
                          if (converses.isEmpty) {
                            return const Center(
                              child: Text('No hi ha converses actives.'),
                            );
                          }

                          return ListView.builder(
                            itemCount: converses.length,
                            itemBuilder: (context, index) {
                              final conv = converses[index];
                              final ofertaId = conv['ofertaId'] as String;
                              final alumneId = conv['alumneId'] as String;
                              final text = conv['text'] as String? ?? '';

                              return FutureBuilder<String>(
                                future: _getNomAlumne(alumneId),
                                builder: (context, snapNom) {
                                  final nomAlumne = snapNom.connectionState == ConnectionState.done
                                      ? (snapNom.data ?? 'Alumne')
                                      : 'Carregant...';

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      leading: _buildAlumneAvatar(alumneId),
                                      title: Text(
                                        'Conversa amb $nomAlumne',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        text,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.orangeAccent,
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
