// lib/modeles/exercice.dart

enum TypeExercice { completerCode, choixMultiple, trierBlos }

class Exercice {
  final String id;
  final String instruction;
  final String codeAvant;
  final String codeApres;
  final List<String> options;
  final String reponseCorrecte;
  final String explication;
  final String indice;
  final int points;

  const Exercice({
    required this.id,
    required this.instruction,
    required this.codeAvant,
    required this.codeApres,
    required this.options,
    required this.reponseCorrecte,
    required this.explication,
    required this.indice,
    this.points = 10,
  });

  factory Exercice.fromJson(Map<String, dynamic> json) {
    return Exercice(
      id: json['id'] as String,
      instruction: json['instruction'] as String,
      codeAvant: json['codeAvant'] as String,
      codeApres: json['codeApres'] as String,
      options: List<String>.from(json['options'] as List),
      reponseCorrecte: json['reponseCorrecte'] as String,
      explication: json['explication'] as String,
      indice: json['indice'] as String,
      points: json['points'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instruction': instruction,
      'codeAvant': codeAvant,
      'codeApres': codeApres,
      'options': options,
      'reponseCorrecte': reponseCorrecte,
      'explication': explication,
      'indice': indice,
      'points': points,
    };
  }
}
