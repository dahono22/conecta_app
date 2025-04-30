// Enum per representar el rol de l'usuari dins la plataforma
enum RolUsuari {
  estudiant, // Usuari que busca ofertes
  empresa,   // Usuari que publica ofertes
}

// Classe que representa un usuari dins l'aplicació
class Usuari {
  final String id; // ID únic de l'usuari (Firestore)
  final String nom; // Nom de l'usuari
  final String email; // Correu electrònic
  final String contrasenya; // Contrasenya (nota: per seguretat, no es recomana guardar-la en text pla)
  final RolUsuari rol; // Rol dins de l'aplicació (estudiant o empresa)
  final String? descripcio; // Descripció personal (en estudiants) o corporativa (en empreses)
  final String? cvUrl; // URL al CV (només aplicable en estudiants)

  // Constructor principal de la classe Usuari
  Usuari({
    required this.id,
    required this.nom,
    required this.email,
    required this.contrasenya,
    required this.rol,
    this.descripcio,
    this.cvUrl,
  });

  // Mètode per crear una nova instància modificant només alguns camps
  // Útil per actualitzar dades parcials sense reescriure tot l'objecte
  Usuari copyWith({
    String? nom,
    String? email,
    String? descripcio,
    String? cvUrl,
  }) {
    return Usuari(
      id: id, // Manté l'ID original
      nom: nom ?? this.nom, // Nom nou si s'especifica, sinó manté l'actual
      email: email ?? this.email, // Idem amb el correu
      contrasenya: contrasenya, // Manté la contrasenya actual (no permet modificar-la aquí)
      rol: rol, // Manté el rol actual
      descripcio: descripcio ?? this.descripcio,
      cvUrl: cvUrl ?? this.cvUrl,
    );
  }
}
