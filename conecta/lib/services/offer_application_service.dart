import 'package:flutter/foundation.dart';

class OfferApplicationService with ChangeNotifier {
  final Set<String> _ofertesAplicades = {};

  void aplicarAOferta(String idOferta) {
    _ofertesAplicades.add(idOferta);
    notifyListeners(); // Notifica los cambios
  }

  bool jaAplicada(String idOferta) {
    return _ofertesAplicades.contains(idOferta);
  }

  List<String> get idsAplicades => _ofertesAplicades.toList();

  // Opcional: método para limpiar las aplicaciones (útil en testing)
  void clear() {
    _ofertesAplicades.clear();
    notifyListeners();
  }
}
