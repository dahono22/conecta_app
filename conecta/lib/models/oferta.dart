import 'package:cloud_firestore/cloud_firestore.dart';

/// Classe que representa una oferta de pràctiques publicada per una empresa.
/// Aquesta informació es desa i es recupera de la base de dades de Firestore.
class Oferta {
  final String id; // ID del document a Firestore
  final String empresaId; // ID únic de l'empresa que publica l'oferta
  final String empresa; // Nom visible de l'empresa
  final String titol; // Títol de l'oferta de pràctiques
  final String descripcio; // Descripció detallada de la feina o projecte ofert
  final String requisits; // Requisits que ha de complir l'estudiant
  final String ubicacio; // Ubicació física (o remota) de les pràctiques
  final DateTime dataPublicacio; // Data en què es va publicar l'oferta
  final String estat; // Estat de validació de l’oferta: 'pendent', 'publicada', 'rebutjada'

  /// Constructor de la classe Oferta
  Oferta({
    required this.id,
    required this.empresaId,
    required this.empresa,
    required this.titol,
    required this.descripcio,
    required this.requisits,
    required this.ubicacio,
    required this.dataPublicacio,
    required this.estat,
  });

  /// Mètode de fàbrica per crear una instància d'Oferta a partir d’un Map
  /// Aquest Map ve directament de Firestore i conté les dades desades.
  factory Oferta.fromMap(Map<String, dynamic> data, String id) {
    return Oferta(
      id: id,
      empresaId: data['empresaId'] ?? '', // Valor per defecte buit si no existeix
      empresa: data['empresa'] ?? '', // Nom de l'empresa (pot ser opcional inicialment)
      titol: data['titol'] ?? '', // Títol de l’oferta
      descripcio: data['descripcio'] ?? '', // Descripció de l’oferta
      requisits: data['requisits'] ?? '', // Requisits per al candidat
      ubicacio: data['ubicacio'] ?? '', // Localització de les pràctiques
      dataPublicacio: (data['dataPublicacio'] as Timestamp).toDate(), // Conversió de Timestamp (Firestore) a DateTime (Dart)
      estat: data['estat'] ?? 'pendent', // Estat per defecte si no s'ha definit
    );
  }

  /// Converteix l’objecte Oferta a un Map per tal de poder-lo desar a Firestore.
  /// Aquest Map representa el contingut del document, excepte l'ID que és la clau.
  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'empresa': empresa,
      'titol': titol,
      'descripcio': descripcio,
      'requisits': requisits,
      'ubicacio': ubicacio,
      'dataPublicacio': dataPublicacio, // Firestore l’entén com Timestamp
      'estat': estat,
    };
  }
}
