// lib/modeles/realisation.dart

class Realisation {
  final String id;
  final String nom;
  final String description;
  final String icone;
  final int pointsRequis;

  const Realisation({
    required this.id,
    required this.nom,
    required this.description,
    required this.icone,
    required this.pointsRequis,
  });

  factory Realisation.fromJson(Map<String, dynamic> json) {
    return Realisation(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String,
      icone: json['icone'] as String,
      pointsRequis: json['pointsRequis'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'icone': icone,
      'pointsRequis': pointsRequis,
    };
  }
}
