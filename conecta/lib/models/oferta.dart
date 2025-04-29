import 'package:cloud_firestore/cloud_firestore.dart';

class Oferta {
  final String id; // ID del document a Firestore
  final String empresaId; // ID de l'empresa que publica l'oferta
  final String empresa; // Nom de l'empresa (afegit recentment)
  final String titol; // Títol de l'oferta
  final String descripcio; // Descripció de l'oferta
  final String requisits; // Requisits que ha de complir el candidat
  final String ubicacio; // Lloc on es desenvoluparà el treball
  final DateTime dataPublicacio; // Data de publicació de l'oferta
  final String estat; // Estat de l'oferta: 'pendent', 'publicada', 'rebutjada'

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

  // Fàbrica per crear una instància a partir d'un Map (Firestore -> Oferta)
  factory Oferta.fromMap(Map<String, dynamic> data, String id) {
    return Oferta(
      id: id,
      empresaId: data['empresaId'] ?? '', // Si falta, queda buit (potser millor llançar error)
      empresa: data['empresa'] ?? '', // Nom de l'empresa
      titol: data['titol'] ?? '', // Títol de l'oferta
      descripcio: data['descripcio'] ?? '', // Descripció de l'oferta
      requisits: data['requisits'] ?? '', // Requisits mínims
      ubicacio: data['ubicacio'] ?? '', // Lloc de treball
      dataPublicacio: (data['dataPublicacio'] as Timestamp).toDate(), // Conversió des de Firestore
      estat: data['estat'] ?? 'pendent', // Valor per defecte si no s'especifica
    );
  }

  // Converteix l'objecte a Map per desar-lo a Firestore (Oferta -> Firestore)
  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'empresa': empresa,
      'titol': titol,
      'descripcio': descripcio,
      'requisits': requisits,
      'ubicacio': ubicacio,
      'dataPublicacio': dataPublicacio,
      'estat': estat,
      // Nota: no inclou l'ID perquè normalment és la clau del document
    };
  }
}
