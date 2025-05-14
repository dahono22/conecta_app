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
}
