import 'package:flutter/material.dart';
import '../../models/oferta.dart';
import '../../services/offer_service.dart';
import '../../routes/app_routes.dart';

class ListOfertesScreen extends StatefulWidget {
  const ListOfertesScreen({super.key});

  @override
  State<ListOfertesScreen> createState() => _ListOfertesScreenState();
}

class _ListOfertesScreenState extends State<ListOfertesScreen> {
  final OfferService _offerService = OfferService();
  final TextEditingController _searchController = TextEditingController();
  List<Oferta> _filtered = [];
  String? _selectedUbicacio;

  @override
  void initState() {
    super.initState();
    _filtered = _offerService.ofertes;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    final ubicacio = _selectedUbicacio;

    setState(() {
      _filtered = _offerService.ofertes.where((oferta) {
        final matchText = oferta.titol.toLowerCase().contains(query) ||
                         oferta.descripcio.toLowerCase().contains(query);
        final matchUbicacio = ubicacio == null || 
                             ubicacio == 'Totes' || 
                             oferta.ubicacio == ubicacio;
        return matchText && matchUbicacio;
      }).toList();
    });
  }

  List<String> getUbicacions() {
    final ubicacions = _offerService.ofertes
        .map((e) => e.ubicacio)
        .toSet()
        .toList();
    ubicacions.sort();
    return ['Totes', ...ubicacions];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ofertes disponibles')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar per paraula clau',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedUbicacio ?? 'Totes',
              decoration: const InputDecoration(
                labelText: 'Filtrar per ubicació',
                border: OutlineInputBorder(),
              ),
              items: getUbicacions().map((ubicacio) {
                return DropdownMenuItem(
                  value: ubicacio,
                  child: Text(ubicacio),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUbicacio = value;
                });
                _onSearch();
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
              ? const Center(child: Text('No hi ha ofertes que coincideixin.'))
              : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final oferta = _filtered[index];
                    return ListTile(
                      title: Text(oferta.titol),
                      subtitle: Text('${oferta.empresa} - ${oferta.ubicacio}'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.detallOferta,
                          arguments: oferta.id,
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}