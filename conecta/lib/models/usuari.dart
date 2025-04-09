enum RolUsuari {
  estudiant,
  empresa,
}

class Usuari {
  final String id;
  final String nom;
  final String email;
  final String contrasenya;
  final RolUsuari rol;
  final String? descripcio;
  final String? cvUrl;

  Usuari({
    required this.id,
    required this.nom,
    required this.email,
    required this.contrasenya,
    required this.rol,
    this.descripcio,
    this.cvUrl,
  });

  Usuari copyWith({
    String? nom,
    String? email,
    String? descripcio,
    String? cvUrl,
  }) {
    return Usuari(
      id: id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      contrasenya: contrasenya,
      rol: rol,
      descripcio: descripcio ?? this.descripcio,
      cvUrl: cvUrl ?? this.cvUrl,
    );
  }
}
