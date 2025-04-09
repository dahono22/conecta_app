// ✅ DETAIL_OFERTA_SCREEN CORREGIT (BEMEN3-7.2 amb gestió d'errors)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/offer_service.dart';
import '../../services/offer_application_service.dart';
import '../../services/auth_service.dart';

class DetailOfertaScreen extends StatelessWidget {
  const DetailOfertaScreen({super.key});

  Future<void> _mostrarDialogAplicacio(
    BuildContext context,
    String idOferta,
    String titolOferta,
  ) async {
    final applicationService =
        Provider.of<OfferApplicationService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.usuariActual?.id;

    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No s'ha pogut identificar l'usuari.")),
        );
      }
      return;
    }

    final jaAplicada = await applicationService.jaAplicadaFirestore(
      usuariId: userId,
      ofertaId: idOferta,
    );

    if (jaAplicada) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ja has aplicat a aquesta oferta.")),
        );
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return Consumer<OfferApplicationService>(
            builder: (context, applicationService, _) {
              return AlertDialog(
                title: const Text('Confirmar aplicació'),
                content: Text('Vols aplicar a l\'oferta "$titolOferta"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel·lar'),
                  ),
                  ElevatedButton(
                    onPressed: applicationService.loading
                        ? null
                        : () async {
                            try {
                              applicationService.setLoading(true);
                              await applicationService.aplicarAOferta(
                                userId,
                                idOferta,
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Has aplicat correctament.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              Navigator.of(context).pop(true);
                            } catch (_) {
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
                    child: applicationService.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
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
    final ofertaId = ModalRoute.of(context)!.settings.arguments as String;
    final oferta = Provider.of<OfferService>(context).getOfertaPerId(ofertaId);

    if (oferta == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detall')),
        body: const Center(child: Text('Oferta no trobada.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(oferta.titol)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Empresa: ${oferta.empresa}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Ubicació: ${oferta.ubicacio}'),
            const SizedBox(height: 16),
            Text('Descripció:',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(oferta.descripcio),
            const Spacer(),
            Center(
              child: Consumer<OfferApplicationService>(
                builder: (context, applicationService, _) {
                  final aplicada = applicationService.jaAplicada(oferta.id);
                  return aplicada
                      ? const Column(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 48),
                            SizedBox(height: 8),
                            Text('Ja has aplicat a aquesta oferta',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        )
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('Aplicar'),
                          onPressed: () => _mostrarDialogAplicacio(
                            context,
                            oferta.id,
                            oferta.titol,
                          ),
                        );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
