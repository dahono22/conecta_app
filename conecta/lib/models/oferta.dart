// lib/models/oferta.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Classe que representa una oferta de pràctiques publicada per una empresa.
/// Aquesta informació es desa i es recupera de la base de dades de Firestore.
class Oferta {
  final String id;               // ID del document a Firestore
  final String empresaId;        // ID únic de l'empresa que publica l'oferta
  final String empresa;          // Nom visible de l'empresa
  final String titol;            // Títol de l'oferta de pràctiques
  final String descripcio;       // Descripció detallada de la feina o projecte ofert
  final String requisits;        // Requisits que ha de complir l'estudiant
  final String ubicacio;         // Ubicació física (o remota) de les pràctiques
  final DateTime dataPublicacio; // Data en què es va publicar l'oferta
  final String estat;            // Estat de validació: 'pendent', 'publicada', 'rebutjada'
  final List<String> tags;       // Tags/interessos predefinits associats a l'oferta

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
    List<String>? tags,
  }) : tags = tags ?? [];

  /// Crea una instància d'Oferta a partir d’un Map de Firestore.
  factory Oferta.fromMap(Map<String, dynamic> data, String id) {
    return Oferta(
      id: id,
      empresaId: data['empresaId'] ?? '',
      empresa: data['empresa'] ?? '',
      titol: data['titol'] ?? '',
      descripcio: data['descripcio'] ?? '',
      requisits: data['requisits'] ?? '',
      ubicacio: data['ubicacio'] ?? '',
      dataPublicacio: (data['dataPublicacio'] as Timestamp).toDate(),
      estat: data['estat'] ?? 'pendent',
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  /// Converteix l’objecte Oferta a un Map per desar-lo a Firestore.
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
      'tags': tags,
    };
  }
}
