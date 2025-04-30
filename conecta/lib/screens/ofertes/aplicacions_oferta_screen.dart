// Importaciones necesarias para Firebase, Flutter, Provider y abrir URLs externas
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Importación de servicios y pantalla de chat
import '../../services/auth_service.dart';
import '../chat/chat_screen.dart';

// Pantalla que muestra las aplicacions d'estudiants a una oferta concreta
class AplicacionsOfertaScreen extends StatelessWidget {
  final String ofertaId; // ID de l'oferta per la qual veurem les aplicacions

  const AplicacionsOfertaScreen({super.key, required this.ofertaId});

  // Funció per carregar estudiants que han aplicat a l'oferta
  Future<List<Map<String, dynamic>>> _carregarEstudiants() async {
    // Obté totes les aplicacions per aquesta oferta
    final snapshot = await FirebaseFirestore.instance
        .collection('aplicacions')
        .where('ofertaId', isEqualTo: ofertaId)
        .get();

    // Recull tots els IDs d’usuaris que han aplicat
    final List<String> usuariIds = snapshot.docs.map((doc) => doc['usuariId'] as String).toList();

    // Si no hi ha aplicacions, retorna una llista buida
    if (usuariIds.isEmpty) return [];

    // Obté dades dels usuaris a partir dels seus IDs
    final usuarisSnapshot = await FirebaseFirestore.instance
        .collection('usuaris')
        .where(FieldPath.documentId, whereIn: usuariIds)
        .get();

    // Construeix un map de dades dels usuaris per accés ràpid
    Map<String, Map<String, dynamic>> usuarisData = {
      for (var doc in usuarisSnapshot.docs) doc.id: doc.data()
    };

    // Combina les dades de l'aplicació amb les dades de l'usuari
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

  // Funció per canviar l'estat d'una aplicació
  Future<void> _canviarEstatAplicacio(BuildContext context, String aplicacioId, String nouEstat) async {
    try {
      // Actualitza el document de l'aplicació a Firestore
      await FirebaseFirestore.instance.collection('aplicacions').doc(aplicacioId).update({
        'estat': nouEstat,
      });

      // Mostra un missatge de confirmació si el context encara existeix
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estat actualitzat a "$nouEstat"')),
        );
      }
    } catch (e) {
      // En cas d'error, mostra un missatge d’error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en actualitzar l\'estat')),
        );
      }
    }
  }

  // Mostra un selector (bottom sheet) per triar un nou estat
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
                Navigator.pop(context); // Tanca el bottom sheet
                _canviarEstatAplicacio(context, aplicacioId, estat); // Actualitza l’estat
              },
            );
          }).toList(),
        );
      },
    );
  }

  // Inicia un xat entre l'empresa i un alumne
  Future<void> _iniciarXatPerEmpresa(
    BuildContext context, {
    required String ofertaId,
    required String empresaId,
    required String alumneId,
  }) async {
    // Comprova si l'alumne ha aplicat realment a l'oferta
    final aplicacions = await FirebaseFirestore.instance
        .collection('aplicacions')
        .where('ofertaId', isEqualTo: ofertaId)
        .where('usuariId', isEqualTo: alumneId)
        .get();

    if (aplicacions.docs.isNotEmpty) {
      // Si sí, obre la pantalla del xat
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
      // Si no ha aplicat, mostra un missatge d'error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aquest alumne encara no ha aplicat.')),
        );
      }
    }
  }

  // Obre l’URL del CV en el navegador
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
    // Obté l'empresa actual des del Provider d’autenticació
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
        future: _carregarEstudiants(), // Carrega les aplicacions
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Mostra loader mentre es carrega
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

          // Mostra la llista d'estudiants aplicats
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

              // Card per cada aplicació
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
                      // Botó per canviar estat
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Canviar estat',
                        onPressed: () => _mostrarSelectorEstat(context, aplicacioId),
                      ),
                      // Botó per veure el CV si hi ha URL
                      if (cvUrl != null && cvUrl.toString().isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          tooltip: 'Veure CV',
                          onPressed: () => _obrirCV(context, cvUrl),
                        ),
                      // Botó per iniciar un xat
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
