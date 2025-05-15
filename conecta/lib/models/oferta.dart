// lib/models/oferta.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Modalidades disponibles para la oferta
enum Modalidad { presencial, remoto, hibrido }

/// Duraciones predefinidas
enum DuracionOferta { meses0_3, meses3_6, meses6_12 }

/// Jornada de la oferta
enum Jornada { manana, tarde }

/// Clase que representa una oferta de prácticas publicada por una empresa.
/// Esta información se guarda y se recupera de Firestore.
class Oferta {
  final String id;                       // ID del documento en Firestore
  final String empresaId;                // ID de la empresa
  final String empresa;                  // Nombre visible de la empresa
  final String titol;                    // Título de la oferta
  final String descripcio;               // Descripción detallada
  final String requisits;                // Requisitos para el estudiante
  final String ubicacio;                 // Ubicación física o remota
  final DateTime dataPublicacio;         // Fecha de publicación
  final String estat;                    // 'pendent', 'publicada', 'rebutjada'
  final List<String> tags;               // Tags/intereses asociados
  final Modalidad modalidad;             // Modalidad (presencial/remoto/híbrido)
  final bool dualIntensiva;              // ¿Es dual intensiva?
  final bool remunerada;                 // ¿Tiene remuneración?
  final DuracionOferta duracion;         // Duración de la oferta
  final bool experienciaRequerida;       // ¿Requiere experiencia?
  final Jornada jornada;                 // Jornada (mañana/tarde)
  final List<String> cursosDestinatarios;// Cursos a los que va dirigida (1r, 2º, ...)

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
    required this.modalidad,
    required this.dualIntensiva,
    required this.remunerada,
    required this.duracion,
    required this.experienciaRequerida,
    required this.jornada,
    List<String>? cursosDestinatarios,
  })  : tags = tags ?? [],
        cursosDestinatarios = cursosDestinatarios ?? [];

  factory Oferta.fromMap(Map<String, dynamic> data, String id) {
    String _getString(Map<String, dynamic> d, String key, String def) =>
        (d[key] as String?)?.toLowerCase() ?? def;

    Modalidad modalidad = Modalidad.values.firstWhere(
      (e) => e.toString().split('.').last == _getString(data, 'modalidad', 'presencial'),
      orElse: () => Modalidad.presencial,
    );

    DuracionOferta duracion = DuracionOferta.values.firstWhere(
      (e) => e.toString().split('.').last == _getString(data, 'duracion', 'meses0_3'),
      orElse: () => DuracionOferta.meses0_3,
    );

    Jornada jornada = Jornada.values.firstWhere(
      (e) => e.toString().split('.').last == _getString(data, 'jornada', 'manana'),
      orElse: () => Jornada.manana,
    );

    return Oferta(
      id: id,
      empresaId: data['empresaId'] as String? ?? '',
      empresa: data['empresa'] as String? ?? '',
      titol: data['titol'] as String? ?? '',
      descripcio: data['descripcio'] as String? ?? '',
      requisits: data['requisits'] as String? ?? '',
      ubicacio: data['ubicacio'] as String? ?? '',
      dataPublicacio: (data['dataPublicacio'] as Timestamp).toDate(),
      estat: data['estat'] as String? ?? 'pendent',
      tags: List<String>.from(data['tags'] as List<dynamic>? ?? []),
      modalidad: modalidad,
      dualIntensiva: data['dualIntensiva'] as bool? ?? false,
      remunerada: data['remunerada'] as bool? ?? false,
      duracion: duracion,
      experienciaRequerida: data['experienciaRequerida'] as bool? ?? false,
      jornada: jornada,
      cursosDestinatarios:
          List<String>.from(data['cursosDestinatarios'] as List<dynamic>? ?? []),
    );
  }

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
      'modalidad': modalidad.toString().split('.').last,
      'dualIntensiva': dualIntensiva,
      'remunerada': remunerada,
      'duracion': duracion.toString().split('.').last,
      'experienciaRequerida': experienciaRequerida,
      'jornada': jornada.toString().split('.').last,
      'cursosDestinatarios': cursosDestinatarios,
    };
  }
}
