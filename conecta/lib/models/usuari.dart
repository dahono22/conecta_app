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
  final List<String> intereses;  // Llista d'interessos (fins a 3) per estudiants

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
    required this.intereses,
  });

  /// Crea una nova instància modificant només alguns camps
  Usuari copyWith({
    String? nom,
    String? email,
    String? descripcio,
    String? cvUrl,
    String? fotoPerfilUrl,
    List<String>? intereses,  // Permet actualitzar interessos
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
      intereses: intereses ?? this.intereses,
    );
  }

  /// Converteix un map de Firestore a Usuari
  factory Usuari.fromMap(Map<String, dynamic> map, String documentId) {
    return Usuari(
      id: documentId,
      nom: map['nom'] as String,
      email: map['email'] as String,
      contrasenya: '', // Per seguretat no es desa la contrasenya
      rol: map['rol'] == 'empresa' ? RolUsuari.empresa : RolUsuari.estudiant,
      descripcio: map['descripcio'] as String?,
      cvUrl: map['cvUrl'] as String?,
      fotoPerfilUrl: map['fotoPerfilUrl'] as String?,
      intereses: List<String>.from(map['intereses'] ?? <String>[]),
    );
  }

  /// Converteix Usuari a map per Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'rol': rol.toString().split('.').last,
      'descripcio': descripcio,
      'cvUrl': cvUrl,
      'fotoPerfilUrl': fotoPerfilUrl,
      'intereses': intereses,
    };
  }
}
