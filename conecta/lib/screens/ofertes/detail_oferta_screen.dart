import 'package:flutter/material.dart';
import '../../services/offer_service.dart';
import '../../services/offer_application_service.dart';

class DetailOfertaScreen extends StatelessWidget {
  final OfferService _offerService = OfferService();
  final OfferApplicationService _applicationService = OfferApplicationService();

  DetailOfertaScreen({super.key});

  void _mostrarDialogAplicacio(BuildContext context, String idOferta, String titolOferta) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar aplicacio'),
          content: Text('Vols aplicar a l\'oferta "$titolOferta"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel·lar'),
            ),
            TextButton(
              onPressed: () {
                _applicationService.aplicarAOferta(idOferta);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Has aplicat correctament.')),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ofertaId = ModalRoute.of(context)!.settings.arguments as String;
    final oferta = _offerService.getOfertaPerId(ofertaId);

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
            Text('Empresa: ${oferta.empresa}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Ubicacio: ${oferta.ubicacio}'),
            const SizedBox(height: 16),
            Text(oferta.descripcio),
            const Spacer(),
            Center(
              child: _applicationService.jaAplicada(oferta.id)
                  ? const Text('Ja has aplicat a aquesta oferta',
                      style: TextStyle(fontSize: 16, color: Colors.grey))
                  : ElevatedButton(
                      onPressed: () => _mostrarDialogAplicacio(
                          context, oferta.id, oferta.titol),
                      child: const Text('Aplicar'),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}