// lib/modeles/progression_utilisateur.dart

class ProgressionUtilisateur {
  final String idUtilisateur;
  final int pointsTotal;
  final int streakActuel;
  final int vies;
  final int gemmes;
  final DateTime dernierAcces;
  final Map<String, ProgressionLecon> progressionsLecons;

  const ProgressionUtilisateur({
    required this.idUtilisateur,
    required this.pointsTotal,
    required this.streakActuel,
    this.vies = 5,
    this.gemmes = 0,
    required this.dernierAcces,
    required this.progressionsLecons,
  });

  factory ProgressionUtilisateur.fromJson(Map<String, dynamic> json) {
    return ProgressionUtilisateur(
      idUtilisateur: json['idUtilisateur'] as String,
      pointsTotal: json['pointsTotal'] as int,
      streakActuel: json['streakActuel'] as int,
      vies: json['vies'] as int? ?? 5,
      gemmes: json['gemmes'] as int? ?? 0,
      dernierAcces: DateTime.parse(json['dernierAcces'] as String),
      progressionsLecons: (json['progressionsLecons'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, ProgressionLecon.fromJson(value as Map<String, dynamic>)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUtilisateur': idUtilisateur,
      'pointsTotal': pointsTotal,
      'streakActuel': streakActuel,
      'vies': vies,
      'gemmes': gemmes,
      'dernierAcces': dernierAcces.toIso8601String(),
      'progressionsLecons': progressionsLecons.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class ProgressionLecon {
  final String idLecon;
  final bool estTerminee;
  final int exercicesTermines;
  final int totalExercices;
  final DateTime termineeA;

  const ProgressionLecon({
    required this.idLecon,
    required this.estTerminee,
    required this.exercicesTermines,
    required this.totalExercices,
    required this.termineeA,
  });

  factory ProgressionLecon.fromJson(Map<String, dynamic> json) {
    return ProgressionLecon(
      idLecon: json['idLecon'] as String,
      estTerminee: json['estTerminee'] as bool,
      exercicesTermines: json['exercicesTermines'] as int,
      totalExercices: json['totalExercices'] as int,
      termineeA: DateTime.parse(json['termineeA'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idLecon': idLecon,
      'estTerminee': estTerminee,
      'exercicesTermines': exercicesTermines,
      'totalExercices': totalExercices,
      'termineeA': termineeA.toIso8601String(),
    };
  }
}
