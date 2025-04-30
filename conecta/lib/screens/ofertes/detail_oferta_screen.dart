// Importacions necessàries
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/offer_application_service.dart';
import '../../services/auth_service.dart';
import '../../models/usuari.dart';

// Widget sense estat per mostrar el detall d'una oferta
class DetailOfertaScreen extends StatelessWidget {
  const DetailOfertaScreen({super.key});

  // Mostra un diàleg de confirmació per aplicar a una oferta
  Future<void> _mostrarDialogAplicacio(
    BuildContext context,
    String idOferta,
    String titolOferta,
  ) async {
    // Obté els serveis d'aplicacions i d'autenticació
    final applicationService =
        Provider.of<OfferApplicationService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final usuari = authService.usuariActual;

    // Si l'usuari no està identificat, mostra un error
    if (usuari == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No s'ha pogut identificar l'usuari.")),
        );
      }
      return;
    }

    // Comprova si l'usuari ja ha aplicat a l'oferta (consultant Firestore)
    final jaAplicada = await applicationService.jaAplicadaFirestore(
      usuariId: usuari.id,
      ofertaId: idOferta,
    );

    // Si ja ha aplicat, mostra missatge informatiu
    if (jaAplicada) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ja has aplicat a aquesta oferta.")),
        );
      }
      return;
    }

    // Si no ha aplicat, mostra diàleg de confirmació
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return Consumer<OfferApplicationService>(
            builder: (context, applicationService, _) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Confirmar aplicació'),
                content: Text('Vols aplicar a l\'oferta "$titolOferta"?'),
                actions: [
                  // Botó de cancel·lació
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel·lar'),
                  ),
                  // Botó per confirmar l'aplicació
                  ElevatedButton(
                    onPressed: applicationService.loading
                        ? null
                        : () async {
                            try {
                              applicationService.setLoading(true);
                              // Aplica a l’oferta amb l’ID de l’usuari i el seu CV
                              await applicationService.aplicarAOferta(
                                usuari.id,
                                idOferta,
                                cvUrl: usuari.cvUrl,
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context); // Tanca el diàleg
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Has aplicat correctament.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              Navigator.of(context).pop(true); // Torna enrere
                            } catch (_) {
                              // En cas d’error, mostra missatge
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(applicationService.error ??
                                        'Error inesperat.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              applicationService.setLoading(false);
                            }
                          },
                    // Mostra un indicador si està carregant
                    child: applicationService.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirmar'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obté l'ID de l'oferta passat com a argument
    final ofertaId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Detall de l\'oferta'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // Escolta canvis en temps real de l'oferta
        stream: FirebaseFirestore.instance
            .collection('ofertes')
            .doc(ofertaId)
            .snapshots(),
        builder: (context, snapshot) {
          // Mostra indicador de càrrega
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si no hi ha dades o l’oferta no existeix
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Oferta no trobada.'));
          }

          // Extreu les dades de l’oferta
          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Empresa
                Text('Empresa: ${data['empresa']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 8),

                // Ubicació
                Text('Ubicació: ${data['ubicacio']}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),

                // Descripció
                const Text(
                  'Descripció:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['descripcio'],
                  style: const TextStyle(fontSize: 15),
                ),

                const Spacer(),

                // Secció per aplicar a l’oferta
                Center(
                  child: Consumer<OfferApplicationService>(
                    builder: (context, applicationService, _) {
                      final aplicada =
                          applicationService.jaAplicada(ofertaId);

                      // Si ja s'ha aplicat, mostra icona i text
                      return aplicada
                          ? const Column(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 48),
                                SizedBox(height: 8),
                                Text(
                                  'Ja has aplicat a aquesta oferta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : ElevatedButton.icon(
                              // Botó per aplicar
                              icon: const Icon(Icons.send),
                              label: const Text('Aplicar'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () => _mostrarDialogAplicacio(
                                context,
                                ofertaId,
                                data['titol'],
                              ),
                            );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
