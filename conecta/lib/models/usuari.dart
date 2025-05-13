// lib/models/usuari.dart

// Enum per representar el rol de l'usuari dins la plataforma
enum RolUsuari {
  estudiant, // Usuari que busca ofertes
  empresa,   // Usuari que publica ofertes
}

// Classe que representa un usuari dins de l'aplicació
class Usuari {
  final String id;               // ID únic de l'usuari (Firestore)
  final String nom;              // Nom de l'usuari
  final String email;            // Correu electrònic
  final String contrasenya;      // Contrasenya (no recomanat guardar en text pla)
  final RolUsuari rol;           // Rol dins de l'aplicació
  final String? descripcio;      // Descripció personal o corporativa
  final String? cvUrl;           // URL del CV (només estudiants)
  final String? fotoPerfilUrl;   // URL de la foto de perfil (opcional)
  final List<String> interessos; // Interessos predefinits seleccionats per l'usuari

  // Constructor principal
  Usuari({
    required this.id,
    required this.nom,
    required this.email,
    required this.contrasenya,
    required this.rol,
    this.descripcio,
    this.cvUrl,
    this.fotoPerfilUrl,
    List<String>? interessos,
  }) : interessos = interessos ?? [];

  /// Crea una nova instància modificant només alguns camps
  Usuari copyWith({
    String? nom,
    String? email,
    String? descripcio,
    String? cvUrl,
    String? fotoPerfilUrl,
    List<String>? interessos,
  }) {
    return Usuari(
      id: id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      contrasenya: contrasenya,
      rol: rol,
      descripcio: descripcio ?? this.descripcio,
      cvUrl: cvUrl ?? this.cvUrl,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
      interessos: interessos ?? this.interessos,
    );
  }
}
