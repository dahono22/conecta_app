// lib/utils/constants.dart

/// Catálogo de campos/intereses disponibles para estudiantes y empresas
typedef Campo = String;

class Constants {
  /// Lista de intereses/campos donde hay más demanda de prácticas
  static const List<Campo> camposDisponibles = [
    // Tecnología e Informática
    'Desarrollo de Software',
    'Data Science',
    'Ciberseguridad',
    'Inteligencia Artificial',
    // Negocios y Marketing
    'Marketing Digital',
    'Finanzas',
    'Recursos Humanos',
    'Administración de Empresas',
    // Diseño y Comunicación
    'Diseño Gráfico',
    'Comunicación Audiovisual',
    'Publicidad',
    // Ingenierías
    'Ingeniería Mecánica',
    'Ingeniería Eléctrica',
    'Ingeniería Civil',
    // Ciencias de la Vida y Salud
    'Biotecnología',
    'Medicina y Salud',
    // Otras áreas
    'Logística y Cadena de Suministro',
    'Turismo y Hostelería',
    'Educación',
    'Medio Ambiente y Sostenibilidad',
    'Derecho',
  ];

  /// Modalidades de las ofertas
  static const List<String> modalidadOptions = [
    'Totes',
    'Presencial',
    'Remoto',
    'Hibrido',
  ];

  /// Duraciones disponibles para las ofertas
  static const List<String> duracionOptions = [
    'Tots',
    '0-3 mesos',
    '3-6 mesos',
    '6-12 mesos',
  ];

  /// Jornadas disponibles
  static const List<String> jornadaOptions = [
    'Totes',
    'Matí',
    'Tarda',
  ];

  /// Opciones de fecha de publicación
  static const List<String> fechaPublicacionOptions = [
    'Totes',
    'Últimes 24h',
    'Setmana passada',
    'Mes passat',
  ];

  /// Cursos destinatarios
  static const List<String> cursosOptions = [
    '1r curs',
    '2º curs',
  ];
}