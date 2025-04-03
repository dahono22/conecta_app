class OfferApplicationService {
  final Set<String> _ofertesAplicades = {};

  void aplicarAOferta(String idOferta) {
    _ofertesAplicades.add(idOferta);
  }

  bool jaAplicada(String idOferta) {
    return _ofertesAplicades.contains(idOferta);
  }

  List<String> get idsAplicades => _ofertesAplicades.toList();
}
