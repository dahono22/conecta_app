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

  Usuari({
    required this.id,
    required this.nom,
    required this.email,
    required this.contrasenya,
    required this.rol,
  });
}
