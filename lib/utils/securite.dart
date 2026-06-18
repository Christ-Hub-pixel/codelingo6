class Securite {
  static bool estEmailValide(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static String? validerMotDePasse(String password) {
    if (password.length < 8) {
      return "Le mot de passe doit faire au moins 8 caractères.";
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return "Le mot de passe doit contenir au moins une majuscule.";
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return "Le mot de passe doit contenir au moins un chiffre.";
    }
    return null;
  }
}
