// lib/models/oferta.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Oferta {
  final String id;
  final String empresaId;
  final String titol;
  final String descripcio;
  final String requisits;
  final String ubicacio;
  final DateTime dataPublicacio;
  final String estat; // pendent, publicada, rebutjada

  Oferta({
    required this.id,
    required this.empresaId,
    required this.titol,
    required this.descripcio,
    required this.requisits,
    required this.ubicacio,
    required this.dataPublicacio,
    required this.estat,
  });

  factory Oferta.fromMap(Map<String, dynamic> data, String id) {
    return Oferta(
      id: id,
      empresaId: data['empresaId'] ?? '',
      titol: data['titol'] ?? '',
      descripcio: data['descripcio'] ?? '',
      requisits: data['requisits'] ?? '',
      ubicacio: data['ubicacio'] ?? '',
      dataPublicacio: (data['dataPublicacio'] as Timestamp).toDate(),
      estat: data['estat'] ?? 'pendent',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'titol': titol,
      'descripcio': descripcio,
      'requisits': requisits,
      'ubicacio': ubicacio,
      'dataPublicacio': dataPublicacio,
      'estat': estat,
    };
  }
}
