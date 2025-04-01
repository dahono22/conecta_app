import 'package:flutter/material.dart';
import '../../services/offer_service.dart';

class DetailOfertaScreen extends StatelessWidget {
  final OfferService _offerService = OfferService();

  DetailOfertaScreen({super.key});

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
            Text('Ubicació: ${oferta.ubicacio}'),
            const SizedBox(height: 16),
            Text(oferta.descripcio),
          ],
        ),
      ),
    );
  }
}
