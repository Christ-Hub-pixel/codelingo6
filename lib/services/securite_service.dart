class SecuriteService {
  // Validation d'email
  static bool estEmailValide(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  // Validation de mot de passe (Robuste)
  static bool estMotDePasseRobuste(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  // Anti-Spam / Brute Force
  static int _tentativesEchouees = 0;
  static DateTime? _dernierEchec;

  static bool peutTenterConnexion() {
    if (_dernierEchec == null) return true;
    final delai = DateTime.now().difference(_dernierEchec!);
    if (_tentativesEchouees > 3 && delai.inSeconds < 30) return false;
    return true;
  }

  static void enregistrerEchec() {
    _tentativesEchouees++;
    _dernierEchec = DateTime.now();
  }

  static void resetTentatives() {
    _tentativesEchouees = 0;
    _dernierEchec = null;
  }

  // ANTI-TRICHE
  static DateTime? _debutExercice;
  
  static void demarrerChronoExercice() {
    _debutExercice = DateTime.now();
  }

  static bool estReponseTropRapide() {
    if (_debutExercice == null) return false;
    final duree = DateTime.now().difference(_debutExercice!);
    // Si la réponse arrive en moins de 800ms, c'est probablement un bot ou un copier-coller
    return duree.inMilliseconds < 800;
  }
}
